//
//  Author.swift
//  Kinit
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
