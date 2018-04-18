//
//  Author.swift
//  KinWallet
//
//  Copyright © 2018 KinFoundation. All rights reserved.
//

import Foundation

struct Author: Codable {
    let name: String
    let imageURL: URL

    enum CodingKeys: String, CodingKey {
        case name
        case imageURL = "image_url"
    }
}
