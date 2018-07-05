//
//  Questionnaire.swift
//  Kinit
//

import Foundation

enum TaskType: String, Codable {
    case questionnaire
    case videoQuestionnaire = "video_questionnaire"
    case trueX = "truex"
}

struct Task: Codable {
    let author: Author
    let identifier: String
    let kinReward: UInt
    let memo: String
    let minutesToComplete: Float
    let questions: [Question]
    let startAt: TimeInterval
    let subtitle: String
    let tags: [String]
    let title: String
    let type: TaskType
    let updatedAt: TimeInterval
    let videoURL: URL?

    enum CodingKeys: CodingKey, String {
        case author = "provider"
        case identifier = "id"
        case kinReward = "price"
        case memo = "memo"
        case minutesToComplete = "min_to_complete"
        case questions = "items"
        case startAt = "start_date"
        case subtitle = "desc"
        case tags
        case title
        case type
        case updatedAt = "updated_at"
        case videoURL = "video_url"
    }
}

extension Task {
    var startDate: Date {
        return Date(timeIntervalSince1970: startAt)
    }

    private static let dateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "MMM dd"
        return f
    }()

    func prefetchImages() {
        let answersImageURLs = questions
            .filter { $0.type == .textAndImage }
            .flatMap { $0.results }
            .compactMap {
                $0.imageURL
        }

        let questionsImageURLs = questions.compactMap {
            $0.imageURL
        }

        (questionsImageURLs + answersImageURLs).map {
            $0.kinImagePathAdjustedForDevice()
        }.forEach(ResourceDownloader.shared.requestResource)
    }

    func daysToUnlock() -> UInt {
        let now = Date()

        if now > startDate {
            return 0
        }

        let midnight = now.endOfDay().timeIntervalSince1970
        return UInt(1 + (startDate - midnight).timeIntervalSince1970 / secondsInADay)
    }

    func nextAvailableDay() -> String {
        let toUnlock = daysToUnlock()
        guard toUnlock > 0 else {
            assertionFailure("nextAvailableDay should never be called in a Task whose daysToUnlock equals to 0")
            return "Now"
        }

        if toUnlock == 1 {
            return "tomorrow"
        }

        let unlockDate = Date().addingTimeInterval(TimeInterval(toUnlock) * secondsInADay)
        return "on \(Task.dateFormatter.string(from: unlockDate))"
    }
}

extension Task: Equatable {
    static func == (lhs: Task, rhs: Task) -> Bool {
        return lhs.identifier == rhs.identifier
    }
}

extension TaskType {
    func toBITaskType() -> Events.TaskType {
        switch self {
        case .questionnaire:
            return .questionnaire
        case .videoQuestionnaire:
            return .videoQuestionnaire
        case .trueX:
            return .truex
        }
    }
}
