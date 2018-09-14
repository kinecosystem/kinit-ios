//
//  Kin.swift
//  Kinit
//

import Foundation
import KinCoreSDK
import StellarErrors
import StellarKit

//swiftlint:disable force_try

private let kinHorizonStageURL = URL(string: "https://horizon-playground.kininfrastructure.com/")!

private let kinHorizonProductionURL = URL(string: "https://horizon-ecosystem.kininfrastructure.com/")!
private let kinHorizonProductionIssuer = "GDF42M3IPERQCBLWFEZKQRK77JQ65SCKTU3CW36HZVCX7XX5A5QXZIVK"
private let kinHorizonProductionName = "Public Global Kin Ecosystem Network ; June 2018"

private let balanceUserDefaultsKey = "org.kinfoundation.kinwallet.currentBalance"
private let accountStatusUserDefaultsKey = "org.kinfoundation.kinwallet.accountStatus"
private let accountStatusPerformedBackupKey = "org.kinfoundation.kinwallet.performedBackup"

protocol BalanceDelegate: class {
    func balanceDidUpdate(balance: UInt64)
}

class Kin {
    static let shared = Kin()
    let client: KinClient

    private(set) var account: KinAccount
    let linkBag = LinkBag()
    private var onboardingPromise: Promise<Bool>?
    var accountStatus: AccountStatus = {
        let fromDefaults = UserDefaults.standard.integer(forKey: accountStatusUserDefaultsKey)
        return AccountStatus(rawValue: fromDefaults) ?? .notCreated
    }()

    fileprivate var balanceDelegates = [WeakBox]()
    var publicAddress: String {
        return account.publicAddress
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    init() {
        let url: URL
        let kinNetworkId: KinCoreSDK.NetworkId

        #if DEBUG || RELEASE_STAGE
        url = kinHorizonStageURL
        kinNetworkId = .playground
        #else
        url = kinHorizonProductionURL
        kinNetworkId = .custom(issuer: kinHorizonProductionIssuer, stellarNetworkId: .custom(kinHorizonProductionName))
        #endif

        let client = try! KinClient(with: url, networkId: kinNetworkId)

        self.account = try! client.accounts.last ?? client.addAccount()
        self.client = client

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(applicationWillEnterForeground),
                                               name: .UIApplicationWillEnterForeground,
                                               object: nil)
    }

    @objc func applicationWillEnterForeground() {
        Kin.shared.refreshBalance()
    }
}

// MARK: Account cleanup
extension Kin {
    func resetKeyStore() {
        UserDefaults.standard.set(AccountStatus.notCreated.rawValue,
                                  forKey: accountStatusUserDefaultsKey)
        Kin.setPerformedBackup(false)
        client.deleteKeystore()
        self.account = try! client.addAccount()
    }
}

enum MyError: Error {
    case meh
}

// MARK: Account backup
extension Kin {
    func exportWallet(with passphrase: String) throws -> String {
        return try account.export(passphrase: passphrase)
    }

    func importWallet(_ encryptedWallet: String, with passphrase: String) throws {
        account = try client.importAccount(encryptedWallet, passphrase: passphrase)
        _ = performOnboardingIfNeeded()
    }

    static func setPerformedBackup(_ performed: Bool = true) {
        UserDefaults.standard.set(performed, forKey: accountStatusPerformedBackupKey)
    }

    static func performedBackup() -> Bool {
        return UserDefaults.standard.bool(forKey: accountStatusPerformedBackupKey)
    }
}

// MARK: Account activation
extension Kin {
    func performOnboardingIfNeeded() -> Promise<Bool> {
        if let onboardingPromise = onboardingPromise {
            return onboardingPromise
        }

        onboardingPromise = Promise<Bool>()

        refreshBalance { balance, error in
            if let balance = balance {
                UserDefaults.standard.set(AccountStatus.activated.rawValue,
                                          forKey: accountStatusUserDefaultsKey)
                KLogVerbose("Already on-boarded account \(self.account.publicAddress). Balance is \(balance) KIN")
                self.onboardingPromise?.signal(true)
                self.onboardingPromise = nil
                return
            }

            guard
                let error = error as? KinError,
                case let KinError.balanceQueryFailed(stellarError) = error
                else {
                    self.onboardingPromise?.signal(false)
                    self.onboardingPromise = nil

                    return
            }

            if case StellarError.missingAccount = stellarError {
                UserDefaults.standard.set(AccountStatus.notCreated.rawValue,
                                          forKey: accountStatusUserDefaultsKey)
                self.onboardAndActivateAccount().then {
                    self.onboardingPromise?.signal($0)
                    self.onboardingPromise = nil
                }
            } else if case StellarError.missingBalance = stellarError {
                UserDefaults.standard.set(AccountStatus.notActivated.rawValue,
                                          forKey: accountStatusUserDefaultsKey)
                self.activateAccount().then {
                    self.onboardingPromise?.signal($0)
                    self.onboardingPromise = nil
                }
            } else {
                self.onboardingPromise?.signal(false)
                self.onboardingPromise = nil
            }
        }

        return onboardingPromise!
    }

    private func onboardAndActivateAccount() -> Promise<Bool> {
        let p = Promise<Bool>()

        WebRequests.createAccount(with: account.publicAddress)
            .withCompletion { success, error in
                if let error = error {
                    KLogError("Error creating account: \(error)")
                    Events.Log
                        .StellarAccountCreationFailed(failureReason: error.localizedDescription)
                        .send()
                    p.signal(false)
                    return
                }

                KLogVerbose("Success onboarding account? \(success.boolValue)")
                Events.Log.StellarAccountCreationSucceeded().send()
                self.activateAccount().then {
                    p.signal($0)
                }
            }.load(with: KinWebService.shared)

        return p
    }

    private func activateAccount() -> Promise<Bool> {
        let p = Promise<Bool>()

        account.activate()
            .then { _ in
                UserDefaults.standard.set(AccountStatus.activated.rawValue,
                                          forKey: accountStatusUserDefaultsKey)
                KLogVerbose("Account activated")
                Events.Business.WalletCreated().send()
                Events.Log.StellarKinTrustlineSetupSucceeded().send()
                self.balanceUpdated(0)

                p.signal(true)
            }.error { error in
                KLogError("Error activating account: \(error)")
                Events.Log
                    .StellarKinTrustlineSetupFailed(failureReason: error.localizedDescription)
                    .send()

                p.signal(false)
            }

        return p
    }
}

// MARK: Watching operations
extension Kin {
    func watch(cursor: String?) throws -> KinCoreSDK.PaymentWatch {
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

    func refreshBalance(completion: BalanceCompletion? = nil) {
        account.balance { [weak self] balance, error in
            defer {
                completion?(balance, error)
            }

            if let error = error, Kin.shared.accountStatus == .activated {
                KLogError("Error fetching balance")
                Events.Log
                    .BalanceUpdateFailed(failureReason: error.localizedDescription)
                    .send()

                return
            }

            self?.balanceUpdated(balance ?? 0)
        }
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
              to address: String,
              memo: String? = nil,
              completion: @escaping KinCoreSDK.TransactionCompletion) {
        account.sendTransaction(to: address, kin: Decimal(amount), memo: memo) { txHash, error in
            completion(txHash, error)

            if let error = error {
                Events.Business
                    .KINTransactionFailed(failureReason: error.localizedDescription,
                                          kinAmount: Float(amount),
                                          transactionType: .spend)
                    .send()

                return
            }

            if let txHash = txHash {
                Events.Business
                    .KINTransactionSucceeded(kinAmount: Float(amount),
                                             transactionId: txHash,
                                             transactionType: .spend)
                    .send()
            }

            Kin.shared.refreshBalance()

            Analytics.incrementSpendCount()
            Analytics.incrementTransactionCount()
            Analytics.incrementTotalSpent(by: Int(amount))
        }
    }
}
