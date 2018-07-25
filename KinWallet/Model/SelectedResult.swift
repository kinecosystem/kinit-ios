//
//  SelectedAnswer.swift
//  Kinit
//

import Foundation

struct SelectedResult: Codable {
    let questionId: String
    let resultIds: [String]

    enum CodingKeys: String, CodingKey {
        case questionId = "qid"
        case resultIds = "aid"
    }
}
