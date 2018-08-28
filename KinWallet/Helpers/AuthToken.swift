//
//  AuthToken.swift
//  KinWallet
//
//  Copyright © 2018 KinFoundation. All rights reserved.
//

import Foundation
import KinCoreSDK

private let authTokenKeychainKey = "AuthToken"

class AuthToken {
    static private var _current: String?
    static let keychain = KeychainSwift(keyPrefix: "org.kinecosystem.kinit")

    static func prepare() {
        _current = keychain.get(authTokenKeychainKey)
    }

    static var current: String? {
        return _current
    }

    static func setCurrent(_ token: String) {
        _current = token
        keychain.set(token, forKey: authTokenKeychainKey)
    }
}
