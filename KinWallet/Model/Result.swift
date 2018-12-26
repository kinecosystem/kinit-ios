//
//  Result.swift
//  Kinit
//

import Foundation

struct Result: Codable {
    let identifier: String
    let imageURL: URL?
    let text: String?
    let tipAmount: Int?

    enum CodingKeys: String, CodingKey {
        case identifier = "id"
        case imageURL = "image_url"
        case text
        case tipAmount = "tip_value"
    }
}

extension Result: Equatable {
    static func == (lhs: Result, rhs: Result) -> Bool {
        return lhs.identifier == rhs.identifier
    }
}

extension Result {
    func hasImage() -> Bool {
        return imageURL != nil
    }

    func hasOnlyImage() -> Bool {
        return hasImage() && text.isNilOrEmpty
    }
}
