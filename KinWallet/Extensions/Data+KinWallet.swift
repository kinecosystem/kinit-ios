//
//  Data+KinWallet.swift
//  Kinit
//

import Foundation

extension Data {
    var hexString: String {
        return reduce("", {$0 + String(format: "%02X", $1)})
    }
}
