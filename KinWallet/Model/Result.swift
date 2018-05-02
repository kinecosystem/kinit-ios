//
//  Result.swift
//  KinWallet
//
//  Copyright © 2018 KinFoundation. All rights reserved.
//

import Foundation

struct Result: Codable {
    let identifier: String
    let text: String?
    let imageURL: URL?

    enum CodingKeys: String, CodingKey {
        case identifier = "id"
        case text
        case imageURL = "image_url"
    }
}

extension Result: Equatable {
    static func == (lhs: Result, rhs: Result) -> Bool {
        return lhs.identifier == rhs.identifier
    }
}

extension Result {
    func hasOnlyImage() -> Bool {
        return imageURL != nil && text.isEmpty
    }
}
