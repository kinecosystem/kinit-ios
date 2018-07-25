//
//  Question.swift
//  Kinit
//

import Foundation

enum QuestionType: String, Codable {
    case text
    case textAndImage = "textimage"
    case multipleText = "textmultiple"
    case textEmoji = "textemoji"
    case tip = "tip"
    case dualImage = "dual_image"
}

struct Question: Codable {
    let identifier: String
    let imageURL: URL?
    let quizData: QuizData?
    let text: String
    let type: QuestionType
    let results: [Result]

    enum CodingKeys: String, CodingKey {
        case identifier = "id"
        case imageURL = "image_url"
        case quizData = "quiz_data"
        case text
        case type
        case results
    }
}

extension Question {
    var allowsMultipleSelection: Bool {
        return type == .multipleText
    }
}

extension Question: Equatable {
    static func == (lhs: Question, rhs: Question) -> Bool {
        return lhs.identifier == rhs.identifier
    }
}
