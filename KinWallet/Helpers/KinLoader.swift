//
//  TaskFetcher.swift
//  Kinit
//

import Foundation
import KinUtil

private let nextTaskIdentifier = "Kinit-NextTask"

enum FetchResult<T> {
    case none(Error?)
    case some(T)
}

class KinLoader {
    static let shared = KinLoader()
    fileprivate var delegates = [WeakBox]()
    let currentTask = Observable<FetchResult<Task>>()
        .stateful()
    let offers = Observable<FetchResult<[Offer]>>(.none(nil))
        .stateful()
    let transactions = Observable<FetchResult<[KinitTransaction]>>(.none(nil))
        .stateful()
    let redeemedItems = Observable<FetchResult<[RedeemTransaction]>>(.none(nil))
        .stateful()

    init() {

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(applicationWillEnterForeground),
                                               name: .UIApplicationWillEnterForeground,
                                               object: nil)
    }

    @objc func applicationWillEnterForeground() {
        guard User.current != nil else {
            return
        }

        loadAllData()
    }

    func deleteCachedAndFetchNextTask() {
        currentTask.next(.none(nil))

        SimpleDatastore.delete(objectOf: Task.self,
                               with: nextTaskIdentifier).finally {
            KinLoader.shared.loadNextTask()
        }
    }

    func loadAllData() {
        loadNextTask()
        loadOffers()
        loadTransactions()
        loadRedeemedItems()
    }

    func loadNextTask() {
        let cachedTask: Task? = SimpleDatastore.loadObject(nextTaskIdentifier)

        if let task = cachedTask {
            currentTask.next(.some(task))
        }

        let completion: ([Task]?, Error?) -> Void = { tasks, error in
            if let tasks = tasks, let task = tasks.first {
                let shouldPersistAndUpdate: Bool

                if let cached = cachedTask, cached.identifier == task.identifier {
                    shouldPersistAndUpdate = task.updatedAt > cached.updatedAt
                } else {
                    shouldPersistAndUpdate = true
                }

                if shouldPersistAndUpdate {
                    SimpleDatastore.persist(task, with: nextTaskIdentifier)
                    self.currentTask.next(.some(task))
                }
            } else {
                self.currentTask.next(.none(error))
            }
        }

        let request = WebRequests.nextTasks().withCompletion(completion)
        KinWebService.shared.load(request)
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
}
