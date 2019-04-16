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
    var deviceToken: String?
    let os = "iOS"
    var phoneNumber: String?
    var publicAddress: String?
    var timeZone: String
    var userId: String

    private enum CodingKeys: String, CodingKey {
        case appVersion = "app_ver"
        case bundleId = "package_id"
        case deviceId = "device_id"
        case deviceModel = "device_model"
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
    static var userAgent: String?

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
                    deviceToken: nil,
                    phoneNumber: nil,
                    publicAddress: nil,
                    timeZone: TimeZone.current.fromGMT,
                    userId: UUID().uuidString)
            .withUpdatedValues()
    }

    func repeatRegistrationIfNeeded() {
        let copy = self.withUpdatedValues()
        if copy.timeZone == timeZone {
            return
        }

        WebRequests.userRegistrationRequest(for: copy)
            .withCompletion { result in
                if result.error == nil {
                    copy.save()
                }
            }.load(with: KinWebService.shared)
    }

    func withUpdatedValues() -> User {
        var updatedUser = self
        updatedUser.timeZone = TimeZone.current.fromGMT

        return updatedUser
    }

    func save() {
        User._current = self
        SimpleDatastore.persist(self, with: User.CurrentUserStorageIdentifier)
    }

    static func reset() {
        User._current = nil
        SimpleDatastore.delete(objectOf: User.self, with: CurrentUserStorageIdentifier)
    }
}

extension User {
    func updateDeviceTokenIfNeeded(_ token: String) {
        guard token != deviceToken else {
            return
        }

        WebRequests.updateDeviceToken(token).withCompletion { result in
            guard case let Result.success(success) = result, success else {
                KLogVerbose("Failed to update device token.")
                return
            }

            KLogVerbose("Updated device token.")

            var copiedSelf = self
            copiedSelf.deviceToken = token
            copiedSelf.save()
        }.load(with: KinWebService.shared)
    }
}
