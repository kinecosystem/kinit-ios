//
//  RemoteConfig.swift
//  Kinit
//

import Foundation

let defaultTosURL = URL(string: "http://www.kinitapp.com/terms-and-privacy-policy")!

struct RemoteConfig: Codable {
    let authTokenEnabled: Bool?
    let peerToPeerEnabled: Bool?
    let peerToPeerMaxKin: UInt?
    let peerToPeerMinKin: UInt?
    let peerToPeerMinTasks: UInt?
    let termsOfService: URL?
    let backupNag: Bool?
    let faqUrl: URL?
    let isUpdateAvailable: Bool?
    var forceUpdate: Bool?

    enum CodingKeys: String, CodingKey {
        case authTokenEnabled = "auth_token_enabled"
        case peerToPeerEnabled = "p2p_enabled"
        case peerToPeerMaxKin = "p2p_max_kin"
        case peerToPeerMinKin = "p2p_min_kin"
        case peerToPeerMinTasks = "p2p_min_tasks"
        case termsOfService = "tos"
        case backupNag = "backup_nag"
        case faqUrl = "faq_url"
        case isUpdateAvailable = "is_update_available"
        case forceUpdate = "force_update"
    }

    private static var _current: RemoteConfig?
}

extension NSNotification.Name {
    static let RemoteConfigUpdated = NSNotification.Name(rawValue: "RemoteConfigUpdated")
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

        //do not store the forceUpdate bool
        var configCopy = config
        configCopy.forceUpdate = nil
        SimpleDatastore.persist(configCopy, with: currentConfigIdentifier)

        DispatchQueue.main.async {
            NotificationCenter.default.post(name: .RemoteConfigUpdated, object: nil)
        }
    }
}
