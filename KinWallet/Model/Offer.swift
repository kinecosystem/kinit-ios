//
//  Offer.swift
//  Kinit
//

import Foundation

struct Offer: Codable {
    let address: String
    let author: Author
    let description: String
    let domain: String
    let identifier: String
    let imageURL: URL
    let title: String
    let type: String
    let typeImageUrl: URL
    let price: UInt64
    let unavailableReason: String?
    let cannotBuyReason: String?

    enum CodingKeys: String, CodingKey {
        case address
        case author = "provider"
        case description = "desc"
        case domain
        case identifier = "id"
        case imageURL = "image_url"
        case title
        case type
        case typeImageUrl = "type_image_url"
        case price
        case unavailableReason = "unavailable_reason"
        case cannotBuyReason = "cannot_buy_reason"
    }
}

extension Offer {
    var isAvailable: Bool {
        return unavailableReason == nil
    }

    func shouldDisplayPrice() -> Bool {
        return true
    }

    func actionViewController() -> SpendOfferActionViewController {
        let standardOfferActionViewController = StoryboardScene.Spend.standardOfferActionViewController.instantiate()
        standardOfferActionViewController.offer = self
        return standardOfferActionViewController
    }
}
