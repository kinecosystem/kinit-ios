//
//  Array+KinWallet.swift
//  Kinit
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
