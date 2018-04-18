//
//  SelectedAnswer.swift
//  KinWallet
//
//  Copyright © 2018 KinFoundation. All rights reserved.
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
