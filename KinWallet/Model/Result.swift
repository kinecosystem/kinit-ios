//
//  Result.swift
//  Kinit
//

import Foundation

struct TaskResult: Codable {
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

extension TaskResult: Equatable {
    static func == (lhs: TaskResult, rhs: TaskResult) -> Bool {
        return lhs.identifier == rhs.identifier
    }
}

extension TaskResult {
    func hasImage() -> Bool {
        return imageURL != nil
    }

    func hasOnlyImage() -> Bool {
        return hasImage() && text.isNilOrEmpty
    }
}
