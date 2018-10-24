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
    }
}

enum SpecialOffer {
    case sendKin

    var actionTitle: String {
        switch self {
        case .sendKin:
            return "Send Kin"
        }
    }

    var isEnabled: Bool {
        switch self {
        case .sendKin:
            guard let config = RemoteConfig.current else {
                return false
            }

            return config.peerToPeerEnabled.boolValue
        }
    }

    fileprivate func actionViewController() -> SpendOfferActionViewController {
        switch self {
        case .sendKin:
            return StoryboardScene.Spend.sendKinOfferActionViewController.instantiate()
        }
    }
}

extension Offer {
    func specialOffer() -> SpecialOffer? {
        if title == "Send Kin to a friend" {
            return .sendKin
        }

        return nil
    }

    func shouldDisplayPrice() -> Bool {
        if specialOffer() == .sendKin {
            return false
        }

        return true
    }

    func actionViewController() -> SpendOfferActionViewController {
        if let specialOffer = specialOffer() {
            let viewController = specialOffer.actionViewController()
            viewController.offer = self
            return viewController
        }

        let standardOfferActionViewController = StoryboardScene.Spend.standardOfferActionViewController.instantiate()
        standardOfferActionViewController.offer = self
        return standardOfferActionViewController
    }
}
