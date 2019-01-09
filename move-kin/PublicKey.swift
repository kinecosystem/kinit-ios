//
//  PublicKey.swift
//  KinWallet
//
//  Copyright © 2019 KinFoundation. All rights reserved.
//

import StellarKit

public struct PublicAddress {
    let key: Data
}

extension PublicAddress {
    public var asString: String {
        return rawValue
    }
}

extension PublicAddress: RawRepresentable {
    public typealias RawValue = String

    public init?(rawValue: String) {
        key = KeyUtils.key(base32: rawValue)
    }

    public var rawValue: String {
        return KeyUtils.base32(publicKey: key)
    }
}

extension PublicAddress: CustomStringConvertible {
    public var description: String {
        return asString
    }
}
