//
//  EcosystemApp.swift
//  KinWallet
//
//  Copyright © 2018 KinFoundation. All rights reserved.
//

import Foundation

struct AppMetadata: Codable {
    let cardImageURL: URL
    let categoryName: String
    let description: String
    let iconURL: URL
    let imageURL1: URL?
    let imageURL2: URL?
    let imageURL: URL
    let kinUsage: String
    let shortDescription: String
    let url: URL

    enum CodingKeys: String, CodingKey {
        case cardImageURL = "card_image_url"
        case categoryName = "category_name"
        case description
        case iconURL = "icon_url"
        case imageURL = "image_url_0"
        case imageURL1 = "image_url_1"
        case imageURL2 = "image_url_2"
        case kinUsage = "kin_usage"
        case shortDescription = "short_description"
        case url = "app_url"
    }
}

struct EcosystemApp: Codable {
    let bundleId: String
    let categoryId: Int
    let isActive: Bool
    let metadata: AppMetadata
    let name: String

    enum CodingKeys: String, CodingKey {
        case bundleId = "identifier"
        case categoryId = "category_id"
        case isActive = "is_active"
        case metadata = "meta_data"
        case name
    }
}

struct EcosystemAppCategory: Codable {
    let apps: [EcosystemApp]
    let id: Int
    let name: String

    enum CodingKeys: String, CodingKey {
        case apps
        case id = "category_id"
        case name = "category_name"
    }
}
