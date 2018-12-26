//
//  Optional+KinWallet.swift
//  Kinit
//

import Foundation

protocol OptionalType {
    associatedtype Wrapped
    var asOptional: Wrapped? { get }
}

extension Optional: OptionalType {
    var asOptional: Wrapped? {
        return self
    }
}

extension Optional where Wrapped == Bool {
    var boolValue: Bool {
        if let unwrapped = self {
            return unwrapped
        }

        return false
    }
}

extension Optional where Wrapped: Collection {
    var isNilOrEmpty: Bool {
        guard let collection = self else {
            return true
        }
        return collection.isEmpty
    }

    var isNotEmpty: Bool {
        return !isNilOrEmpty
    }

    var count: Int {
        if let unwrapped = self {
            return unwrapped.count
        }

        return 0
    }
}
