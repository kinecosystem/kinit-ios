//
//  Array+KinWallet.swift
//  KinWallet
//
//  Copyright © 2018 KinFoundation. All rights reserved.
//

import Foundation

extension Collection {
    var isNotEmpty: Bool {
        return !isEmpty
    }
}

extension Array where Element == String {
    var asString: String {
        return joined(separator: ", ")
    }
}
