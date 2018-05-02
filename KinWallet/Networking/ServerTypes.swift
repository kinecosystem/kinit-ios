//
//  ServerTypes.swift
//  KinWallet
//
//  Copyright © 2018 KinFoundation. All rights reserved.
//

import Foundation

protocol StatusResponse: Codable {
    var status: String { get }
}

struct SimpleStatusResponse: StatusResponse, Codable {
    let status: String
}

struct MemoStatusResponse: StatusResponse, Codable {
    let status: String
    let memo: String
}

struct TasksResponse: Codable {
    let tasks: [Task]
}

struct OffersResponse: Codable {
    let offers: [Offer]
}

struct BookOfferResponse: StatusResponse, Codable {
    let status: String
    let orderId: String?
    let reason: String?

    enum CodingKeys: CodingKey, String {
        case status
        case orderId = "order_id"
        case reason
    }
}

enum BookOfferResult {
    case success(String)
    case noGoods
    case coolDown
}

struct OfferInfo: Codable {
    let identifier: String

    enum CodingKeys: CodingKey, String {
        case identifier = "id"
    }
}

struct PaymentReceipt: Codable {
    let txHash: String

    enum CodingKeys: CodingKey, String {
        case txHash = "tx_hash"
    }
}

struct RedeemGood: Codable {
    let type: String
    let value: String
}

struct RedeemResponse: StatusResponse, Codable {
    let status: String
    let goods: [RedeemGood]
}

struct TransactionHistoryResponse: StatusResponse, Codable {
    let status: String
    let transactions: [KinitTransaction]

    enum CodingKeys: CodingKey, String {
        case status
        case transactions = "txs"
    }
}

struct RedeemedItemsResponse: StatusResponse, Codable {
    let status: String
    let items: [RedeemTransaction]

    enum CodingKeys: CodingKey, String {
        case status
        case items = "redeemed"
    }
}

struct RemoteConfigStatusResponse: StatusResponse, Codable {
    let status: String
    let config: RemoteConfig?
}
