//
//  TaskAnswers.swift
//  Kinit
//

import Foundation

struct TaskResults: Codable, Persistable {
    let identifier: String
    let results: [SelectedResult]
    let address: String?

    init(identifier: String, results: [SelectedResult], address: String? = nil) {
        self.identifier = identifier
        self.results = results
        self.address = address
    }

    enum CodingKeys: String, CodingKey {
        case identifier = "id"
        case results
        case address
    }
}

extension TaskResults {
    func applyingAddress(_ address: String) -> TaskResults {
        return TaskResults(identifier: identifier,
                           results: results,
                           address: address)
    }
}
