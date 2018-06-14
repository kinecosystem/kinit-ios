//
//  QuestionTests.swift
//  Kinit
//

import Foundation

import XCTest
@testable import KinWallet

class QuestionTests: XCTestCase {
    func testInitWithCorrectJSONSucceeds() {
        let jsonString =
        """
            {
              "id" : "185",
              "results" : [
                {
                  "id" : "32654",
                  "text" : "To kill some time"
                },
                {
                  "id" : "92353",
                  "text" : "I'm looking for a new experience"
                },
                {
                  "id" : "22985",
                  "text" : "I want to earn cryptocurrency"
                },
                {
                  "id" : "34567",
                  "text" : "Not sure yet, still exploring"
                },
                {
                  "id" : "2653",
                  "text" : "Get gift cards for free"
                }
              ],
              "type" : "text",
              "text" : "Why do you want to use the Kin app?"
            }
        """

        let jsonData = jsonString.data(using: .utf8)!
        let question = try? JSONDecoder().decode(Question.self, from: jsonData)
        XCTAssertNotNil(question)
    }
}
