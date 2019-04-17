//
//  Result.swift
//  KinWallet
//
//  Copyright © 2019 KinFoundation. All rights reserved.
//

import Foundation

//Remove this when migrating to Swift 5
enum Result<T, Error> {
    case success(T)
    case failure(Error)
}

extension Result {
    var error: Error? {
        if case let Result.failure(error) = self {
            return error
        }

        return nil
    }

    var value: T? {
        if case let Result.success(value) = self {
            return value
        }

        return nil
    }
}
