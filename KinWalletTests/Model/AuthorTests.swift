//
//  AuthorTests.swift
//  Kinit
//

import Foundation

import XCTest
@testable import KinWallet

class AuthorTests: XCTestCase {
    func testInitWithCorrectJSONSucceeds() {
        let jsonString =
        """
            {
                "name": "Kin Team",
                "image_url": "http://domain.com/path/"
            }
        """

        let jsonData = jsonString.data(using: .utf8)!
        let author = try? JSONDecoder().decode(Author.self, from: jsonData)
        XCTAssertNotNil(author)
    }
}
