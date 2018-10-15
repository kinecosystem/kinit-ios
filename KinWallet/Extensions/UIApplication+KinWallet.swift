//
//  UIApplication+KinWallet.swift
//  Kinit
//

import UIKit

extension UIApplication {
    var fullscreenshot: UIImage? {
        UIGraphicsBeginImageContextWithOptions(UIScreen.main.bounds.size, false, 0)

        for window in UIApplication.shared.windows {
            window.drawHierarchy(in: window.bounds, afterScreenUpdates: true)
        }

        defer {
            UIGraphicsEndImageContext()
        }

        return UIGraphicsGetImageFromCurrentImageContext()
    }

    static func update() {
        if #available(iOS 10.0, *) {
            let appStoreURL = URL(string: "itms-apps://itunes.apple.com/app/id1401266070")!
            UIApplication.shared.open(appStoreURL)
        } else {
            let appStoreURL = URL(string: "https://itunes.apple.com/us/app/kinit/id1401266070")!
            UIApplication.shared.openURL(appStoreURL)
        }
    }
}
