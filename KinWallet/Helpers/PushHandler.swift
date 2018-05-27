//
//  PushHandler.swift
//  KinWallet
//
//  Copyright © 2018 KinFoundation. All rights reserved.
//

import UIKit

private let kinDataPushKey = "kin"
private let kinDataPushTypeKey = "push_type"

private enum KinPushType: String {
    case auth
}

class PushHandler {
    class func handlePush(with userInfo: [AnyHashable: Any]) {
        logNotificationOpenedIfNeeded(with: userInfo)

        guard
            let kinData = userInfo[kinDataPushKey] as? [String: Any],
            let pushType = kinData[kinDataPushTypeKey] as? String else {
            return
        }

        switch pushType {
        case KinPushType.auth.rawValue:
            ackAuthToken(with: kinData)
        default:
            break
        }
    }

    private class func logNotificationOpenedIfNeeded(with userInfo: [AnyHashable: Any]) {
        guard UIApplication.shared.applicationState == .inactive else {
            KLogVerbose("Received push while in foreground, not logging opened")
            return
        }

        guard let aps = userInfo["aps"] as? [String: Any] else {
            return
        }

        let pushText: String
        let pushId: String

        if let alertText = aps["alert"] as? String {
            pushText = alertText
        } else if let alertDictionary = aps["alert"] as? [String: String] {
            let textParts = [alertDictionary["title"],
                             alertDictionary["subtitle"],
                             alertDictionary["body"]]
            pushText = textParts
                .compactMap { $0 }
                .joined(separator: "\n")
        } else {
            return
        }

        if
            let kinData = userInfo[kinDataPushKey] as? [String: Any],
            let kinPushId = kinData["push_id"] as? String {
            pushId = kinPushId
        } else {
            pushId = "N/A"
        }

        Events.Analytics
            .ClickEngagementPush(pushId: pushId, pushText: pushText)
            .send()
    }

    private class func ackAuthToken(with kinData: [String: Any]) {
        guard
            let authData = kinData["auth_data"] as? [String: String],
            let token = authData["auth_token"] else {
            return
        }

        WebRequests.ackAuthToken(token).load(with: KinWebService.shared)
    }
}
