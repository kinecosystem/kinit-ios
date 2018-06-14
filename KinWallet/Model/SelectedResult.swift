//
//  SelectedAnswer.swift
//  Kinit
//

import Foundation

struct SelectedResult: Codable {
    let taskId: String
    let resultIds: [String]

    enum CodingKeys: String, CodingKey {
        case taskId = "qid"
        case resultIds = "aid"
    }
}
