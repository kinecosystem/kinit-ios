//
//  ServerTypes.swift
//  Kinit
//

import Foundation

struct EmptyResponse: Codable {}

protocol StatusResponse: Codable {
    var status: String { get }
}

struct SimpleStatusResponse: StatusResponse, Codable {
    let status: String
}

struct CategoriesHeaderMessage: Codable {
    let title: String
    let subtitle: String
}

struct TaskCategoriesResponse: Codable {
    let categories: [TaskCategory]
    let headerMessage: CategoriesHeaderMessage

    enum CodingKeys: String, CodingKey {
        case categories
        case headerMessage = "header_message"
    }
}

struct CategoryTasksResponse: Codable {
    let tasks: [Task]
    let availableTasksCount: Int

    enum CodingKeys: String, CodingKey {
        case tasks
        case availableTasksCount = "available_tasks_count"
    }
}

struct TasksByCategoryResponse: Codable {
    let tasks: [String: [Task]]
}

struct OffersResponse: Codable {
    let offers: [Offer]
}

struct ContactSearchStatusResponse: StatusResponse, Codable {
    let status: String
    let address: String?
    let error: String?
}

struct BookOfferResponse: StatusResponse, Codable {
    let status: String
    let orderId: String?
    let reason: String?

    enum CodingKeys: String, CodingKey {
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

    enum CodingKeys: String, CodingKey {
        case identifier = "id"
    }
}

struct PaymentReceipt: Codable {
    let txHash: String

    enum CodingKeys: String, CodingKey {
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

struct TransactionReportStatusResponse: StatusResponse, Codable {
    let status: String
    let transaction: KinitTransaction

    enum CodingKeys: String, CodingKey {
        case status
        case transaction = "tx"
    }
}

struct TransactionHistoryResponse: StatusResponse, Codable {
    let status: String
    let transactions: [KinitTransaction]

    enum CodingKeys: String, CodingKey {
        case status
        case transactions = "txs"
    }
}

struct RedeemedItemsResponse: StatusResponse, Codable {
    let status: String
    let items: [RedeemTransaction]

    enum CodingKeys: String, CodingKey {
        case status
        case items = "redeemed"
    }
}

struct RemoteConfigStatusResponse: StatusResponse, Codable {
    let status: String
    let config: RemoteConfig?
}

struct BlacklistedAreaCodes: Codable {
    let areaCodes: [String]

    enum CodingKeys: String, CodingKey {
        case areaCodes = "areacodes"
    }
}

struct AvailableBackupHint: Codable {
    let text: String
    let id: Int
}

struct AvailableBackupHintList: Codable {
    let hints: [AvailableBackupHint]
}

struct ChosenBackupHints: Codable {
    let hints: [Int]
}

struct PhoneVerificationStatusResponse: StatusResponse, Codable {
    let status: String
    let hints: [Int]
}

struct SelectedHintIds: Codable {
    let hints: [Int]
}

struct RestoreUserIdResponse: Codable {
    let userId: String?

    enum CodingKeys: String, CodingKey {
        case userId = "user_id"
    }
}

struct ReportMoveKinToAppBody: Codable {
    let address: String
    let txHash: String
    let amount: UInt
    let destinationAppSid: Int

    enum CodingKeys: String, CodingKey {
        case address = "destination_address"
        case txHash = "tx_hash"
        case amount
        case destinationAppSid = "destination_app_sid"
    }
}
