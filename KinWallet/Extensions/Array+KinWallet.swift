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

extension Array where Element: CustomStringConvertible {
    var asString: String {
        return map { String(describing: $0) }
            .joined(separator: ", ")
    }
}

extension Array {
    func chunked(into size: Int) -> [[Element]] {
        return stride(from: 0, to: count, by: size).map {
            Array(self[$0 ..< Swift.min($0 + size, count)])
        }
    }
}
