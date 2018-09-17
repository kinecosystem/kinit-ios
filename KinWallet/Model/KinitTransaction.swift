//
//  KinitTransaction.swift
//  Kinit
//

import Foundation

struct KinitTransaction: Codable {
    let amount: Int
    let author: Author
    private let _date: TimeInterval
    let clientReceived: Bool
    let title: String
    let txHash: String
    let type: String

    enum CodingKeys: String, CodingKey {
        case amount
        case author = "provider"
        case _date = "date"
        case clientReceived = "client_received"
        case title
        case txHash = "tx_hash"
        case type
    }
}

extension KinitTransaction: Equatable {
    static func == (lhs: KinitTransaction, rhs: KinitTransaction) -> Bool {
        return lhs.txHash == rhs.txHash
    }
}

extension KinitTransaction {
    var date: Date {
        return Date(timeIntervalSince1970: _date)
    }
}
