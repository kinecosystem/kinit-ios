//
//  Configuration.swift
//  Kinit
//

import Foundation

struct Configuration: Codable {
    let amplitudeKeyDebug: String?
    let amplitudeKeyProd: String?
    let moreScreenTapsPassword: String
    let serverHostStage: String
    let serverHostProd: String
    let testFairyKey: String?

    enum CodingKeys: String, CodingKey {
        case amplitudeKeyDebug = "amplitude-key-debug"
        case amplitudeKeyProd = "amplitude-key-prod"
        case moreScreenTapsPassword = "more-screen-taps-password"
        case serverHostProd = "server-host-prod"
        case serverHostStage = "server-host-stage"
        case testFairyKey = "testfairy-key"
    }

    static let shared: Configuration = {
        //swiftlint:disable:next force_try
        return try! JSONDecoder()
            .decode(Configuration.self,
                    from: Data(contentsOf: Bundle.main.url(forResource: "config",
                                                           withExtension: "json")!))
    }()
}
