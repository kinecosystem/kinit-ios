//
//  UIApplication+KinWallet.swift
//  KinWallet
//
//  Copyright © 2018 KinFoundation. All rights reserved.
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
}
