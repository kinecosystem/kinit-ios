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
    case peerToPeerReceived = "p2p_received"
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
        case KinPushType.peerToPeerReceived.rawValue:
            peerToPeerReceived(with: kinData)
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

    private class func peerToPeerReceived(with kinData: [String: Any]) {
        guard
            let tx = kinData["tx"] as? [String: Any],
            let asData = try? JSONSerialization.data(withJSONObject: tx, options: []),
            let transaction = try? JSONDecoder().decode(KinitTransaction.self, from: asData)
            else {
                KinLoader.shared.loadTransactions()
                return
        }

        KinLoader.shared.prependTransaction(transaction)
    }
}