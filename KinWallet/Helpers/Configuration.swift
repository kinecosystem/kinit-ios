//
//  Configuration.swift
//  Kinit
//

import Foundation

struct Configuration: Codable {
    let amplitudeKeyDebug: String?
    let amplitudeKeyProd: String?
    let testFairyKey: String?
    let serverEndpointStage: URL
    let serverEndpointProd: URL
    let moreScreenTapsPassword: String

    enum CodingKeys: String, CodingKey {
        case amplitudeKeyDebug = "amplitude-key-debug"
        case amplitudeKeyProd = "amplitude-key-prod"
        case serverEndpointStage = "server-endpoint-stage"
        case serverEndpointProd = "server-endpoint-prod"
        case moreScreenTapsPassword = "more-screen-taps-password"
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
