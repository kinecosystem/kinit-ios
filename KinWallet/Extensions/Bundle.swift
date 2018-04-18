//
//  Bundle.swift
//  KinWallet
//
//  Copyright © 2018 KinFoundation. All rights reserved.
//

import Foundation

extension Bundle {
    static var appVersion: String {
        return main.infoDictionary!["CFBundleShortVersionString"] as! String //swiftlint:disable:this force_cast
    }

    static var buildNumber: String {
        return main.infoDictionary!["CFBundleVersion"] as! String //swiftlint:disable:this force_cast
    }
}
