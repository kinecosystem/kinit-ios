//
//  NotificationHandler.swift
//  KinWallet
//
//  Copyright © 2018 KinFoundation. All rights reserved.
//

import UIKit
import UserNotifications

enum NotificationAuthorizationStatus {
    case notDetermined
    case authorized
    case denied
}

@available(iOS 10.0, *)
extension NotificationAuthorizationStatus {
    init(status: UNAuthorizationStatus) {
        switch status {
        case .notDetermined: self = .notDetermined
        case .authorized: self = .authorized
        case .denied: self = .denied
        }
    }
}

protocol NotificationHandler {
    func authorizationStatus(with completion: @escaping (NotificationAuthorizationStatus) -> Void)
    func hasUserBeenAskedAboutPushNotifications(with completion: @escaping (Bool) -> Void)
    func requestNotificationPermissions(with completion: ((Bool) -> Void)?)
    func arePermissionsGranted(_ permissionsGranted: @escaping (Bool) -> Void)
}

extension NotificationHandler {
    func hasUserBeenAskedAboutPushNotifications(with completion: @escaping (Bool) -> Void) {
        authorizationStatus { status in
            DispatchQueue.main.async {
                completion(status != .notDetermined)
            }
        }
    }

    func arePermissionsGranted(_ permissionsGranted: @escaping (Bool) -> Void) {
        authorizationStatus { status in
            DispatchQueue.main.async {
                permissionsGranted(status == .authorized)
            }
        }
    }
}

@available(iOS 10.0, *)
//swiftlint:disable:next type_name
class iOS10NotificationHandler: NotificationHandler {
    func authorizationStatus(with completion: @escaping (NotificationAuthorizationStatus) -> Void) {
        UNUserNotificationCenter.current()
            .getNotificationSettings { settings in
                completion(NotificationAuthorizationStatus(status: settings.authorizationStatus))
        }
    }

    func requestNotificationPermissions(with completion: ((Bool) -> Void)?) {
        UNUserNotificationCenter.current()
            .requestAuthorization(options: [.alert, .sound, .badge]) { granted, _ in
                if let completion = completion {
                    DispatchQueue.main.async {
                        completion(granted)
                    }
                }
        }
    }
}
