//
//  AppDelegate+Extensions.swift
//  KinWallet
//
//  Copyright © 2018 KinFoundation. All rights reserved.
//

import UIKit

extension AppDelegate {
    class var shared: AppDelegate {
        //swiftlint:disable:next force_cast
        return UIApplication.shared.delegate as! AppDelegate
    }

    func applyAppearance() {
        window?.tintColor = UIColor.kin.appTint

        UINavigationBar.appearance().setBackgroundImage(navigationBarGradientImage(), for: .default)
        UIBarButtonItem.appearance(whenContainedInInstancesOf: [UINavigationBar.self]).tintColor = .white
        UINavigationBar.appearance().titleTextAttributes = [.foregroundColor: UIColor.white,
                                                            .font: FontFamily.Roboto.regular.font(size: 16)]
    }

    private func navigationBarGradientImage() -> UIImage {
        let gradientView = GradientView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 1))
        gradientView.direction = .horizontal
        gradientView.colors = UIColor.navigationBarGradientColors

        return gradientView.drawAsImage()
            .resizableImage(withCapInsets: .zero, resizingMode: .stretch)
    }

    func requestNotifications(with completion: ((Bool) -> Void)? = nil) {
        notificationHandler?.requestNotificationPermissions { granted in
            Analytics.setUserProperty(Events.UserProperties.pushEnabled, with: granted)
            completion?(granted)
        }
    }

    func logNotificationOpened(with userInfo: [AnyHashable: Any]) {

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
            pushText = "N/A"
        }

        if
            let kin = userInfo["kin"] as? [String: Any],
            let kinPushId = kin["push_id"] as? String {
            pushId = kinPushId
        } else {
            pushId = "N/A"
        }

        Events.Analytics
            .ClickEngagementPush(pushId: pushId, pushText: pushText)
            .send()
    }
}

extension AppDelegate: WebServiceProvider {
    func userId() -> String? {
        return User.current?.userId
    }

    func deviceId() -> String? {
        return User.current?.deviceId
    }

    func appVersion() -> String? {
        return Bundle.appVersion
    }
}
