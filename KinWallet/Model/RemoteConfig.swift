//
//  RemoteConfig.swift
//  Kinit
//

import Foundation

struct RemoteConfig: Codable {
    let authTokenEnabled: Bool?
    let peerToPeerEnabled: Bool?
    let peerToPeerMaxKin: UInt?
    let peerToPeerMinKin: UInt?
    let peerToPeerMinTasks: UInt?
    let phoneVerificationEnabled: Bool?
    let termsOfService: URL?

    enum CodingKeys: CodingKey, String {
        case authTokenEnabled = "auth_token_enabled"
        case peerToPeerEnabled = "p2p_enabled"
        case peerToPeerMaxKin = "p2p_max_kin"
        case peerToPeerMinKin = "p2p_min_kin"
        case peerToPeerMinTasks = "p2p_min_tasks"
        case phoneVerificationEnabled = "phone_verification_enabled"
        case termsOfService = "tos"
    }

    private static var _current: RemoteConfig?
}

extension RemoteConfig {
    private static let currentConfigIdentifier = "Current"
    static var current: RemoteConfig? {
        if _current == nil {
            _current = SimpleDatastore.loadObject(currentConfigIdentifier)
        }

        return _current
    }

    static func updateCurrent(with config: RemoteConfig) {
        _current = config
        SimpleDatastore.persist(config, with: currentConfigIdentifier)
    }
}
