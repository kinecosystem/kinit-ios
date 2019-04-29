//
//  Kin.swift
//  Kinit
//

import Foundation
import KinMigrationModule
import StellarErrors

//swiftlint:disable force_try

extension Notification.Name {
    static let KinMigrationStarted = Notification.Name("KinMigrationStarted")
    static let KinMigrationFailed = Notification.Name("KinMigrationFailed")
    static let KinMigrationSucceeded = Notification.Name("KinMigrationSucceeded")
}

private let kinitAppId = "kit"

private let balanceUserDefaultsKey = "org.kinfoundation.kinwallet.currentBalance"
private let accountStatusPerformedBackupKey = "org.kinfoundation.kinwallet.performedBackup"

protocol BalanceDelegate: class {
    func balanceDidUpdate(balance: UInt64)
}

enum TxSignatureError: Error {
    case encodingFailed
    case decodingFailed
}

class Kin: NSObject {
    static let shared = Kin()
    private var client: KinClientProtocol
    fileprivate var migratingWalletWindow: UIWindow?
    private let migrationManager: KinMigrationManager
    private(set) var account: KinAccountProtocol
    let linkBag = LinkBag()
    private var onboardingPromise: Promise<OnboardingResult>?

    fileprivate var balanceDelegates = [WeakBox]()
    var publicAddress: String {
        return account.publicAddress
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    override init() {
        let kinNetwork: Network

        #if DEBUG || RELEASE_STAGE
        kinNetwork = .testNet
        #else
        kinNetwork = .mainNet
        #endif

        let provider = try! ServiceProvider(network: kinNetwork,
                                            migrateBaseURL: URL(string: "https://stage.kinitapp.com/user"),
                                             queryItems: [URLQueryItem(name: "user_id", value: User.current?.userId)])
        let appId = try! AppId(kinitAppId)
        migrationManager = KinMigrationManager(serviceProvider: provider, appId: appId)

        let kin2Client = migrationManager.kinClient(version: .kinCore)
        let kin3Client = migrationManager.kinClient(version: .kinSDK)
        let hasPhoneNumber = User.current?.phoneNumber != nil

        if hasPhoneNumber,
            let existingAccount = kin2Client.accounts.last,
            !migrationManager.isAccountMigrated(publicAddress: existingAccount.publicAddress) {
            client = kin2Client
            account = existingAccount

            super.init()

            startMigration()
        } else {
            account = try! kin3Client.accounts.last ?? kin3Client.addAccount()
            client = kin3Client

            super.init()
        }

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(applicationDidBecomeActive),
                                               name: UIApplication.didBecomeActiveNotification,
                                               object: nil)
    }

    @objc func applicationDidBecomeActive() {
        refreshBalance()
    }
}

// MARK: Account cleanup
extension Kin {
    func resetKeyStore() {
        Kin.setPerformedBackup(false)

        migrationManager.deleteKeystore()
        self.account = try! client.addAccount()
    }
}

// MARK: Account backup
extension Kin {
    func exportWallet(with passphrase: String) throws -> String {
        return try account.export(passphrase: passphrase)
    }

    func importWallet(_ encryptedWallet: String, with passphrase: String) throws {
        client = migrationManager.kinClient(version: .kinCore)
        account = try client.importAccount(encryptedWallet, passphrase: passphrase)
        startMigration()
    }

    static func setPerformedBackup(_ performed: Bool = true) {
        UserDefaults.standard.set(performed, forKey: accountStatusPerformedBackupKey)
    }

    static func performedBackup() -> Bool {
        return UserDefaults.standard.bool(forKey: accountStatusPerformedBackupKey)
    }
}

extension Kin {
    func startMigration() {
        migrationManager.delegate = self
        try! migrationManager.start(with: account.publicAddress)
        //TODO: Add migration started event
    }
}

enum OnboardingResult {
    case success
    case failure(String)
}

// MARK: Account activation
extension Kin {
    @discardableResult
    func performOnboardingIfNeeded() -> Promise<OnboardingResult> {
        if let onboardingPromise = onboardingPromise {
            return onboardingPromise
        }

        onboardingPromise = Promise<OnboardingResult>()

        if User.current?.publicAddress != nil {
            refreshBalance()
            return onboardingPromise!
        }

        refreshBalance { result in
            switch result {
            case .success(let balance):
                KLogVerbose("Already on-boarded account \(self.account.publicAddress). Balance is \(balance) KIN")
                self.onboardingPromise?.signal(.success)
                self.onboardingPromise = nil
            case .failure(let error):
                guard
                    let kError = error as? KinMigrationModule.KinError,
                    case KinMigrationModule.KinError.missingAccount = kError
                    else {
                        self.onboardingPromise?.signal(.failure(String(describing: error)))
                        self.onboardingPromise = nil

                        return
                }

                self.onboardAccount().then {
                    self.onboardingPromise?.signal($0)
                    self.onboardingPromise = nil
                }
            }
        }

        return onboardingPromise!
    }

    private func onboardAccount() -> Promise<OnboardingResult> {
        let p = Promise<OnboardingResult>()

        WebRequests.createAccount(with: account.publicAddress)
            .withCompletion { result in
                if let error = result.error {
                    KLogError("Error creating account: \(error)")
                    Events.Log
                        .StellarAccountCreationFailed(failureReason: error.localizedDescription)
                        .send()
                    p.signal(.failure(error.localizedDescription))
                    return
                }

                KLogVerbose("Success onboarding account? \(result.value.boolValue)")
                Events.Log.StellarAccountCreationSucceeded().send()
                Events.Business.WalletCreated().send()
                self.balanceUpdated(0)
                p.signal(.success)
            }.load(with: KinWebService.shared)

        return p
    }
}

// MARK: Watching operations
extension Kin {
    func watch(cursor: String?) throws -> PaymentWatchProtocol {
        return try account.watchPayments(cursor: cursor)
    }
}

// MARK: Balance operations
extension Kin {
    var balance: UInt64 {
        return UInt64(UserDefaults.standard.integer(forKey: balanceUserDefaultsKey))
    }

    func addBalanceDelegate(_ delegate: BalanceDelegate) {
        balanceDelegates.append(WeakBox(value: delegate))
    }

    func removeBalanceDelegate(_ delegate: BalanceDelegate) {
        if let index = balanceDelegates.index(where: { $0.value === delegate }) {
            balanceDelegates.remove(at: index)
        }
    }

    func refreshBalance(completion: ((Result<Decimal, Error>) -> Void)? = nil) {
        account.balance()
            .then({ [weak self] balance in
                self?.balanceUpdated(balance)
                completion?(.success(balance))
            }).error({ error in
                KLogError("Error fetching balance")
                let errorDescription: String

                if case let KinError.balanceQueryFailed(underlyingStellarError) = error {
                    errorDescription = underlyingStellarError.localizedDescription
                } else {
                    errorDescription = error.localizedDescription
                }

                Events.Log
                    .BalanceUpdateFailed(failureReason: errorDescription)
                    .send()
                completion?(.failure(error))
            })
    }

    private func balanceUpdated(_ balance: Decimal) {
        KLogVerbose("Balance is now \(balance)")
        let balanceAsUInt = (balance as NSDecimalNumber).uint64Value
        UserDefaults.standard.set(balanceAsUInt, forKey: balanceUserDefaultsKey)
        Analytics.balance = balanceAsUInt

        self.balanceDelegates
            .compactMap { $0.value as? BalanceDelegate }
            .forEach { $0.balanceDidUpdate(balance: balanceAsUInt) }
    }
}

// MARK: Performing transactions
extension Kin {
    func send(_ amount: UInt64,
              orderId: String,
              to address: String,
              memo: String? = nil,
              type: SendTransactionType,
              completion: @escaping (Result<TransactionId, Error>) -> Void) {
        let senderAddress = account.publicAddress
        account.sendTransaction(to: address, kin: Decimal(amount), memo: memo, fee: 0) { txEnv in
            let p = Promise<TransactionEnvelope>()
            guard let txBase64 = txEnv.asBase64String else {
                return p.signal(TxSignatureError.encodingFailed)
            }

            let transaction = SignableTransaction(id: orderId,
                                                  senderAddress: senderAddress,
                                                  recipientAddress: address,
                                                  amount: Int(amount),
                                                  transaction: txBase64)
            WebRequests.addSignature(to: transaction)
                .withCompletion { result in
                    guard
                        let signedTxString = result.value,
                        let signedEnv = TransactionEnvelope.fromBase64String(string: signedTxString) else {
                            p.signal(result.error ?? TxSignatureError.decodingFailed)
                            return
                    }

                    p.signal(signedEnv)
            }.load(with: KinWebService.shared)
            return p
            }.then { txId in
                Kin.shared.refreshBalance()

                Analytics.incrementSpendCount()
                Analytics.incrementTransactionCount()
                Analytics.incrementTotalSpent(by: Int(amount))
                completion(.success(txId))
            }.error { error in
                Events.Business
                    .KINTransactionFailed(failureReason: error.localizedDescription,
                                          kinAmount: Int(amount),
                                          transactionType: type.toBIEventType)
                    .send()
                completion(.failure(error))
        }
    }
}

enum SendTransactionType {
    case spend
    case crossApp

    var toBIEventType: Events.TransactionType {
        switch self {
        case .spend: return .spend
        case .crossApp: return .crossApp
        }
    }
}

extension Kin: KinMigrationManagerDelegate {
    func kinMigrationManagerNeedsVersion(_ kinMigrationManager: KinMigrationManager) -> Promise<KinVersion> {
        return Promise(.kinSDK)
    }

    func kinMigrationManagerDidStart(_ kinMigrationManager: KinMigrationManager) {
        KLogVerbose("Migration started")

        DispatchQueue.main.async {
            let migratingWalletViewController = MigratingWalletViewController()

            self.migratingWalletWindow = UIWindow()
            self.migratingWalletWindow!.rootViewController = migratingWalletViewController
            self.migratingWalletWindow!.makeKeyAndVisible()
        }

        NotificationCenter.default.post(name: .KinMigrationStarted, object: nil)

        Events.Business.MigrationStarted().send()
    }

    func kinMigrationManager(_ kinMigrationManager: KinMigrationManager, readyWith client: KinClientProtocol) {
        KLogVerbose("Client is ready, and migration succeeded, yay!!")

        self.client = client
        self.account = client.accounts.last!
        refreshBalance()

        NotificationCenter.default.post(name: .KinMigrationSucceeded, object: nil)

        DispatchQueue.main.async {
            guard let window = self.migratingWalletWindow else {
                return
            }

            UIView.animate(withDuration: 0.25, animations: {
                window.transform = .init(translationX: 0, y: window.frame.height)
            }, completion: { _ in
                self.migratingWalletWindow = nil
            })
        }

        Events.Business.MigrationSucceeded().send()
    }

    func kinMigrationManager(_ kinMigrationManager: KinMigrationManager, error: Error) {
        KLogError("Migration failed: \(error)")

        DispatchQueue.main.async {
            let migrateViewController = self.migratingWalletWindow?.rootViewController as? MigratingWalletViewController
            migrateViewController?.migrationFailed()
        }

        NotificationCenter.default.post(name: .KinMigrationFailed, object: nil)

        Events.Log.MigrationFailed(failureReason: String(describing: error)).send()
    }
}
