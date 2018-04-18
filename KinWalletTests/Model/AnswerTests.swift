//
//  AnswerTests.swift
//  KinWallet
//
//  Copyright © 2018 KinFoundation. All rights reserved.
//

import Foundation

import XCTest
@testable import KinWallet

class ResultTests: XCTestCase {
    func testInitWithCorrectJSONSucceeds() {
        let jsonString =
        """
            {
                "id": "abc123",
                "text": "some answer",
                "image_url": "http://domain.com/path/"
            }
        """

        let jsonData = jsonString.data(using: .utf8)!
        let answer = try? JSONDecoder().decode(Result.self, from: jsonData)
        XCTAssertNotNil(answer)

        XCTAssertEqual(answer?.imageURL, URL(string: "http://domain.com/path/"))
    }
}
