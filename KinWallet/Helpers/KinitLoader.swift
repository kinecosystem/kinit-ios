//
//  KinitLoader.swift
//  Kinit
//

import Foundation
import KinUtil

let nextTaskIdentifier = "Kinit-NextTask"
let availableBackupList = "Kinit-AvailableBackupList"

enum FetchResult<T> {
    case none(Error?)
    case some(T)
}

class KinitLoader {
    fileprivate var delegates = [WeakBox]()
    let offers = Observable<FetchResult<[Offer]>>(.none(nil))
        .stateful()
    let transactions = Observable<FetchResult<[KinitTransaction]>>(.none(nil))
        .stateful()
    let redeemedItems = Observable<FetchResult<[RedeemTransaction]>>(.none(nil))
        .stateful()

    init() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(applicationWillEnterForeground),
                                               name: UIApplication.willEnterForegroundNotification,
                                               object: nil)
    }

    @objc func applicationWillEnterForeground() {
        guard User.current != nil else {
            return
        }

        loadAllData()
    }

    func loadAllData() {
        loadOffers()
        loadTransactions()
        loadRedeemedItems()
        fetchAvailableBackupHints()
    }

    func loadOffers() {
        loadItems(request: WebRequests.offers(), observable: offers)
    }

    func loadTransactions() {
        loadItems(request: WebRequests.transactionsHistory(), observable: transactions)
    }

    func loadRedeemedItems() {
        loadItems(request: WebRequests.redeemedItems(), observable: redeemedItems)
    }

    func loadItems<A, B>(request: WebRequest<A, B>, observable: Observable<FetchResult<B>>) where B: Collection {
        request.withCompletion { result, error in
            if let result = result, result.isNotEmpty {
                observable.next(.some(result))
            } else {
                observable.next(.none(error))
            }
        }.load(with: KinWebService.shared)
    }

    func prependTransaction(_ transaction: KinitTransaction) {
        guard let fetchResult = transactions.value else {
            return
        }

        var newTransactions = [KinitTransaction]()
        if case let FetchResult.some(current) = fetchResult {
            if !current.contains(transaction) {
                newTransactions.append(transaction)
            }
            newTransactions.append(contentsOf: current)
        } else {
            newTransactions.append(transaction)
        }

        transactions.next(.some(newTransactions))
    }

    func fetchAvailableBackupHints(skipCache: Bool = false, completion: (([AvailableBackupHint]) -> Void)? = nil) {
        if !skipCache,
            let cachedList: AvailableBackupHintList = SimpleDatastore.loadObject(availableBackupList) {
                completion?(cachedList.hints)
                return
        }

        WebRequests.Backup.availableHints()
            .withCompletion { list, _ in
                guard let list = list, list.hints.count > 0 else {
                    return
                }

                SimpleDatastore.persist(list, with: availableBackupList)
                completion?(list.hints)
            }.load(with: KinWebService.shared)
    }
}
