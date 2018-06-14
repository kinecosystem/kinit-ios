//
//  RedeemTransaction.swift
//  Kinit
//

import Foundation

struct RedeemTransaction: Codable {
    let date: Date
    let description: String
    let identifier: String
    let provider: Author
    let title: String
    let type: String
    let value: String

    enum CodingKeys: CodingKey, String {
        case date
        case description = "desc"
        case identifier = "offer_id"
        case provider
        case title
        case type
        case value
    }
}

extension RedeemTransaction: Equatable {
    static func == (lhs: RedeemTransaction, rhs: RedeemTransaction) -> Bool {
        return lhs.date == rhs.date && lhs.identifier == rhs.identifier
    }
}
