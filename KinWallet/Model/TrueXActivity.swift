//
//  TrueXActivity.swift
//  KinWallet
//
//  Copyright © 2018 KinFoundation. All rights reserved.
//

import Foundation

struct TrueXActivity: Codable {
    let activityId: Int
    let campaignId: Int
    let currencyAmount: Int
    let displayText: String?
    let imageURL: URL
    let name: String
    let networkUserId: String
    let partnerId: Int
    let revenueAmount: String
    let sessionId: String
    let url: URL
    let windowHeight: Int
    let windowWidth: Int

    enum CodingKeys: String, CodingKey {
        case activityId = "id"
        case campaignId = "campaign_id"
        case currencyAmount = "currency_amount"
        case displayText = "display_text"
        case imageURL = "image_url"
        case name
        case networkUserId = "network_user_id"
        case partnerId = "partner_id"
        case revenueAmount = "revenue_amount"
        case sessionId = "session_id"
        case url = "window_url"
        case windowHeight = "window_height"
        case windowWidth = "window_width"
    }
}

//swiftlint:disable all
extension TrueXActivity {
    func toJSON() -> [String: Any] {
        let asData = try! JSONEncoder().encode(self)
        return try! JSONSerialization.jsonObject(with: asData, options: []) as! [String: Any]
    }
}
