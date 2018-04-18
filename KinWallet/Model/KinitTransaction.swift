//
//  KinitTransaction.swift
//  KinWallet
//
//  Copyright © 2018 KinFoundation. All rights reserved.
//

import Foundation

struct KinitTransaction: Codable {
    let amount: Int
    let author: Author
    private let _date: TimeInterval
    let serverReceived: Bool
    let title: String
    let txHash: String

    enum CodingKeys: CodingKey, String {
        case amount
        case author = "provider"
        case _date = "date"
        case serverReceived = "server_received"
        case title
        case txHash = "tx_hash"
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

    var isEarn: Bool {
        return !isSpend
    }

    var isSpend: Bool {
        return serverReceived
    }
}
