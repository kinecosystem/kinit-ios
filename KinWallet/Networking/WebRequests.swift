//
//  WebResources.swift
//  Kinit
//

import Foundation

typealias Success = Bool
typealias TransactionId = String
typealias PublicAddress = String

private struct WebResourceHandlers {
    static func isJSONStatusOk(response: StatusResponse?) -> Bool? {
        return response?.status == "ok"
    }

    static func isRemoteStatusOk(response: RemoteConfigStatusResponse?) -> RemoteConfig? {
        guard
            let response = response,
            WebResourceHandlers.isJSONStatusOk(response: response).boolValue else {
                return nil
        }

        if let config = response.config {
            RemoteConfig.updateCurrent(with: config)
        }

        return response.config
    }
}

struct WebRequests {}

// MARK: User methods

extension WebRequests {
    static func userRegistrationRequest(for user: User) -> WebRequest<RemoteConfigStatusResponse, RemoteConfig> {
        return WebRequest<RemoteConfigStatusResponse, RemoteConfig>(POST: "/user/register",
                                                               body: user,
                                                               transform: WebResourceHandlers.isRemoteStatusOk)
    }

    static func updateDeviceToken(_ newToken: String) -> WebRequest<SimpleStatusResponse, Success> {
        return WebRequest<SimpleStatusResponse, Success>(POST: "/user/push/update-token",
                                                         body: ["token": newToken],
                                                         transform: WebResourceHandlers.isJSONStatusOk)
    }

    static func ackAuthToken(_ authToken: String) -> WebRequest<SimpleStatusResponse, Success> {
        return WebRequest<SimpleStatusResponse, Success>(POST: "/user/auth/ack",
                                                         body: ["token": authToken],
                                                         transform: WebResourceHandlers.isJSONStatusOk)
    }

    static func updateUserIdToken(_ idToken: String) -> WebRequest<SimpleStatusResponse, Success> {
        return WebRequest<SimpleStatusResponse, Success>(POST: "/user/firebase/update-id-token",
                                                         body: ["token": idToken],
                                                         transform: WebResourceHandlers.isJSONStatusOk)
    }

    static func appLaunch() -> WebRequest<RemoteConfigStatusResponse, RemoteConfig> {
        return WebRequest<RemoteConfigStatusResponse, RemoteConfig>(POST: "/user/app-launch",
                                                         body: ["app_ver": Bundle.appVersion],
                                                         transform: WebResourceHandlers.isRemoteStatusOk)
    }

    static func searchPhoneNumber(_ phoneNumber: String) -> WebRequest<ContactSearchStatusResponse, PublicAddress> {
        return WebRequest<ContactSearchStatusResponse, PublicAddress>(POST: "/user/contact",
                                                               body: ["phone_number": phoneNumber],
                                                               transform: { response -> PublicAddress? in
            guard let response = response,
                WebResourceHandlers.isJSONStatusOk(response: response).boolValue,
                let address = response.address else {
                    return nil
            }

            return address
        })
    }
}

// MARK: Kin Onboard
extension WebRequests {
    static func createAccount(with publicAddress: String) -> WebRequest<SimpleStatusResponse, Success> {
        return WebRequest<SimpleStatusResponse, Success>(POST: "/user/onboard",
                                                         body: ["public_address": publicAddress],
                                                         transform: WebResourceHandlers.isJSONStatusOk)
    }
}

// MARK: Earn
extension WebRequests {
    static func nextTasks() -> WebRequest<TasksResponse, [Task]> {
        return WebRequest<TasksResponse, [Task]>(GET: "/user/tasks",
                                                 transform: { $0?.tasks })
    }

    static func submitTaskResults(_ results: TaskResults) -> WebRequest<SimpleStatusResponse, Success> {
        return WebRequest<SimpleStatusResponse, Success>(POST: "/user/task/results",
                                                      body: results,
                                                      transform: WebResourceHandlers.isJSONStatusOk)
    }
}

// MARK: Spend
extension WebRequests {
    static func offers() -> WebRequest<OffersResponse, [Offer]> {
        return WebRequest<OffersResponse, [Offer]>(GET: "/user/offers",
                                                   transform: { $0?.offers })
    }

    static func bookOffer(_ offer: Offer) -> WebRequest<BookOfferResponse, BookOfferResult> {
        let transform: (BookOfferResponse?) -> BookOfferResult? = { bookOfferReponse -> BookOfferResult? in
            guard
                let response = bookOfferReponse,
                WebResourceHandlers.isJSONStatusOk(response: bookOfferReponse).boolValue,
                let orderId = response.orderId else {
                return nil
            }

            return .success(orderId)
        }

        return WebRequest<BookOfferResponse, BookOfferResult>(POST: "/offer/book",
                                                     body: OfferInfo(identifier: offer.identifier),
                                                     transform: transform)
    }

    static func redeemOffer(with paymentReceipt: PaymentReceipt) -> WebRequest<RedeemResponse, [RedeemGood]> {
        let transform: (RedeemResponse?) -> [RedeemGood]? = {
            guard
                let response = $0,
                WebResourceHandlers.isJSONStatusOk(response: response).boolValue else {
                    return nil
            }

            return response.goods
        }

        return WebRequest<RedeemResponse, [RedeemGood]>(POST: "/offer/redeem",
                                                        body: paymentReceipt,
                                                        transform: transform)
    }

    static func reportTransaction(with txId: String,
                                  amount: UInt64,
                                  to address: String) -> WebRequest<TransactionReportStatusResponse, Success> {
        //swiftlint:disable:next nesting
        struct PeerToPeerReport: Codable {
            let tx_hash: String
            let amount: UInt64
            let destination_address: String
        }

        let transform: (TransactionReportStatusResponse?) -> Success? = {
            guard let response = $0,
                WebResourceHandlers.isJSONStatusOk(response: response).boolValue else {
                return false
            }

            let tx = response.transaction
            KinLoader.shared.prependTransaction(tx)

            return true
        }

        let body = PeerToPeerReport(tx_hash: txId, amount: amount, destination_address: address)
        return WebRequest<TransactionReportStatusResponse, Success>(POST: "/user/transaction/p2p",
                                                                    body: body,
                                                                    transform: transform)
    }
}

extension WebRequests {
    static func transactionsHistory() -> WebRequest<TransactionHistoryResponse, [KinitTransaction]> {
        let transform: (TransactionHistoryResponse?) -> [KinitTransaction]? = {
            guard
                let response = $0,
                WebResourceHandlers.isJSONStatusOk(response: response).boolValue else {
                return nil
            }

            return response.transactions
        }

        return WebRequest<TransactionHistoryResponse, [KinitTransaction]>(GET: "/user/transactions",
                                                                          transform: transform)
    }

    static func redeemedItems() -> WebRequest<RedeemedItemsResponse, [RedeemTransaction]> {
        let transform: (RedeemedItemsResponse?) -> [RedeemTransaction]? = {
            guard
                let response = $0,
                WebResourceHandlers.isJSONStatusOk(response: response).boolValue else {
                    return nil
            }

            return response.items
        }

        return WebRequest<RedeemedItemsResponse, [RedeemTransaction]>(GET: "/user/redeemed",
                                                                          transform: transform)
    }
}

// MARK: Blacklists

extension WebRequests {
    struct Blacklists {
        static func areaCodes() -> WebRequest<BlacklistedAreaCodes, [String]> {
            return WebRequest<BlacklistedAreaCodes, [String]>(GET: "/blacklist/areacodes",
                                                              transform: { $0?.areaCodes })
        }
    }
}
