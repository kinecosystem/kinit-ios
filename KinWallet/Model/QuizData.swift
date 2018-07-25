//
//  QuizData.swift
//  KinWallet
//
//  Copyright © 2018 KinFoundation. All rights reserved.
//

import Foundation

struct QuizData: Codable {
    let correctAnswerId: String
    let explanation: String
    let reward: UInt

    enum CodingKeys: CodingKey, String {
        case correctAnswerId = "answer_id"
        case explanation
        case reward
    }
}
