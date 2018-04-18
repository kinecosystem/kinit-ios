//
//  Data+KinWallet.swift
//  KinWallet
//
//  Copyright © 2018 KinFoundation. All rights reserved.
//

import Foundation

extension Data {
    var hexString: String {
        return reduce("", {$0 + String(format: "%02X", $1)})
    }
}
