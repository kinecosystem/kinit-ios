//
//  QuestionnaireTests.swift
//  KinWallet
//
//  Copyright © 2018 KinFoundation. All rights reserved.
//

import Foundation

import XCTest
@testable import KinWallet

class TaskTests: XCTestCase {
    func testInitWithCorrectJSONSucceeds() {
        let bundle = Bundle(for: TaskTests.self)
        guard
            let fileURL = bundle.url(forResource: "InitialTasks", withExtension: "json"),
            let jsonData = try? Data(contentsOf: fileURL) else {
            XCTAssertTrue(false, "InitialQuestionnaire.json couldn't be loaded")
            return
        }

        guard let tasksResponse = try? JSONDecoder().decode(TasksResponse.self, from: jsonData) else {
            XCTAssertTrue(false, "TasksResponse couldn't be initialized from json")
            return
        }

        guard let task = tasksResponse.tasks.first else {
            XCTAssertTrue(false, "Task couldn't be initialized from json")
            return
        }

        XCTAssertEqual(task.questions.count, 13)
    }
}
