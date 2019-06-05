//
//  With.swift
//  KinWallet
//
//  Copyright © 2019 KinFoundation. All rights reserved.
//

import Foundation

@discardableResult
public func with<T>(_ value: T, _ builder: (T) -> Void) -> T {
    builder(value)
    return value
}

@discardableResult
public func with<T>(_ value: T, _ builder: (T) throws -> Void ) rethrows -> T {
    try builder(value)
    return value
}
