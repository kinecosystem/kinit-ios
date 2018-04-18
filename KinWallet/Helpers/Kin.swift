//
//  Kin.swift
//  KinWallet
//
//  Copyright © 2018 KinFoundation. All rights reserved.
//

import Foundation
import KinSDK
import StellarErrors
import KinUtil

//swiftlint:disable force_try

private let stellarTestNetURL = URL(string: "https://horizon-testnet.stellar.org")!
private let balanceUserDefaultsKey = "org.kinfoundation.kinwallet.currentBalance"
private let accountStatusUserDefaultsKey = "org.kinfoundation.kinwallet.accountStatus"

protocol BalanceDelegate: class {
    func balanceDidUpdate(balance: UInt64)
}

class Kin {
    static let shared = Kin()
    let client: KinClient

    private(set) var account: KinAccount
    let linkBag = LinkBag()
    var balanceWatch: BalanceWatch?
    private var onboardingPromise: Promise<Bool>?
    var accountStatus: AccountStatus = {
        let fromDefaults = UserDefaults.standard.integer(forKey: accountStatusUserDefaultsKey)
        return AccountStatus(rawValue: fromDefaults) ?? .notCreated
    }()

    fileprivate var balanceDelegates = [WeakBox]()
    var publicAddress: String {
        return account.publicAddress
    }

    init() {
        let client = try! KinClient(with: stellarTestNetURL, networkId: .testNet)
        self.account = try! client.accounts.last ?? client.addAccount()
        self.client = client
    }
}

// MARK: Account cleanup
extension Kin {
    func resetKeyStore() {
        client.deleteKeystore()
        self.account = try! client.addAccount()
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
                self.createBalanceWatch(initialBalance: balance)
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
            }
        }

        return onboardingPromise!
    }

    private func onboardAndActivateAccount() -> Promise<Bool> {
        let p = Promise<Bool>()

        KinWebService.shared.load(WebRequests
            .createAccount(with: account.publicAddress)
            .withCompletion { success, error in
                if let error = error {
                    KLogError("Error creating account: \(error)")
                    let event = Events.Log.StellarAccountCreationFailed(failureReason: error.localizedDescription)
                    Analytics.logEvent(event)
                    p.signal(false)
                    return
                }

                KLogVerbose("Success onboarding account? \(success.boolValue)")
                Analytics.logEvent(Events.Log.StellarAccountCreationSucceeded())
                self.activateAccount().then {
                    p.signal($0)
                }
        })

        return p
    }

    private func activateAccount() -> Promise<Bool> {
        let p = Promise<Bool>()

        account.activate()
            .then({ _ in
                UserDefaults.standard.set(AccountStatus.activated.rawValue,
                                          forKey: accountStatusUserDefaultsKey)
                KLogVerbose("Account activated")
                Analytics.logEvent(Events.Business.WalletCreated())
                Analytics.logEvent(Events.Log.StellarKinTrustlineSetupSucceeded())
                self.createBalanceWatch(initialBalance: 0)

                p.signal(true)
            }).error({ error in
                KLogError("Error activating account: \(error)")
                let event = Events.Log.StellarKinTrustlineSetupFailed(failureReason: error.localizedDescription)
                Analytics.logEvent(event)

                p.signal(false)
            })

        return p
    }
}

// MARK: Watching operations
extension Kin {
    func watch(cursor: String?) throws -> KinSDK.PaymentWatch {
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

    private func createBalanceWatch(initialBalance: Decimal) {
        guard let watch = try? account.watchBalance(initialBalance) else {
            return
        }

        watch.emitter
            .on(next: { [weak self] balance in
                self?.balanceUpdated(balance)
            }).add(to: linkBag)

        balanceWatch = watch
    }

    func refreshBalance(completion: BalanceCompletion? = nil) {
        account.balance { [weak self] balance, error in
            defer {
                completion?(balance, error)
            }

            if let error = error {
                KLogError("Error fetching balance")
                let logEvent = Events.Log.BalanceUpdateFailed(failureReason: error.localizedDescription)
                Analytics.logEvent(logEvent)

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
              completion: @escaping KinSDK.TransactionCompletion) {
        account.sendTransaction(to: address, kin: Decimal(amount), memo: memo) { txHash, error in
            completion(txHash, error)

            if let error = error {
                let event = Events.Business.KINTransactionFailed(failureReason: error.localizedDescription,
                                                                 kinAmount: Float(amount),
                                                                 transactionType: .spend)
                Analytics.logEvent(event)

                return
            }

            if let txHash = txHash {
                let event = Events.Business.KINTransactionSucceeded(kinAmount: Float(amount),
                                                                    transactionId: txHash,
                                                                    transactionType: .spend)
                Analytics.logEvent(event)
            }

            Analytics.incrementSpendCount()
            Analytics.incrementTransactionCount()
            Analytics.incrementTotalSpent(by: Int(amount))
        }
    }
}
