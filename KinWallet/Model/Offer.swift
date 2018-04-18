//
//  Offer.swift
//  KinWallet
//
//  Copyright © 2018 KinFoundation. All rights reserved.
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

    enum CodingKeys: CodingKey, String {
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
