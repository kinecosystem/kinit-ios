//
//  User.swift
//  Kinit
//

import UIKit

struct User: Codable {
    let appVersion: String
    let bundleId = Bundle.main.bundleIdentifier!
    let deviceId: String
    let deviceModel: String
    var deviceScreenHeight: CGFloat?
    var deviceScreenScale: CGFloat?
    var deviceScreenWidth: CGFloat?
    var deviceToken: String?
    let os = "iOS"
    var phoneNumber: String?
    var publicAddress: String?
    var timeZone: String
    let userId: String

    private enum CodingKeys: String, CodingKey {
        case appVersion = "app_ver"
        case bundleId = "package_id"
        case deviceId = "device_id"
        case deviceModel = "device_model"
        case deviceScreenHeight = "screen_h"
        case deviceScreenScale = "screen_d"
        case deviceScreenWidth = "screen_w"
        case deviceToken = "token"
        case os
        case phoneNumber
        case publicAddress = "public_address"
        case timeZone = "time_zone"
        case userId = "user_id"
    }
}

extension User {
    private static let CurrentUserStorageIdentifier = "Current"
    private static var _current: User?

    static var current: User? {
        if let currentUser = _current {
            return currentUser
        }

        if let onDisk: User = SimpleDatastore.loadObject(CurrentUserStorageIdentifier) {
            _current = onDisk
            return onDisk
        }

        return nil
    }

    static func createNew() -> User {
        return User(appVersion: Bundle.appVersion,
                    deviceId: (UIDevice.current.identifierForVendor ?? UUID()).uuidString,
                    deviceModel: UIDevice.current.modelMarketingName,
                    deviceScreenHeight: nil,
                    deviceScreenScale: nil,
                    deviceScreenWidth: nil,
                    deviceToken: nil,
                    phoneNumber: nil,
                    publicAddress: nil,
                    timeZone: TimeZone.current.fromGMT,
                    userId: UUID().uuidString)
            .withUpdatedValues()
    }

    func withUpdatedValues() -> User {
        var updatedUser = self
        updatedUser.deviceScreenHeight = UIScreen.main.bounds.height
        updatedUser.deviceScreenScale = UIScreen.main.scale
        updatedUser.deviceScreenWidth = UIScreen.main.bounds.width

        return updatedUser
    }

    func save() {
        User._current = self
        SimpleDatastore.persist(self, with: User.CurrentUserStorageIdentifier)
    }
}

extension User {
    func updateDeviceTokenIfNeeded(_ token: String) {
        guard token != deviceToken else {
            return
        }

        WebRequests.updateDeviceToken(token).withCompletion { success, _ in
            KLogVerbose("Updated device token: \(success.boolValue)")
            guard success.boolValue else {
                return
            }

            var copiedSelf = self
            copiedSelf.deviceToken = token
            copiedSelf.save()
        }.load(with: KinWebService.shared)
    }
}
