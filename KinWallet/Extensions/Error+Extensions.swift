//
//  Error+Extensions.swift
//  KinWallet
//
//  Copyright © 2019 KinFoundation. All rights reserved.
//

import Foundation

let internetErrorCodes = [
    NSURLErrorCannotConnectToHost,
    NSURLErrorNetworkConnectionLost,
    NSURLErrorDNSLookupFailed,
    NSURLErrorResourceUnavailable,
    NSURLErrorNotConnectedToInternet,
    NSURLErrorBadServerResponse,
    NSURLErrorInternationalRoamingOff,
    NSURLErrorCallIsActive,
    NSURLErrorFileDoesNotExist,
    NSURLErrorNoPermissionsToReadFile
]

extension Error {
    var isTimeout: Bool {
        return (self as NSError).isTimeout
    }

    var isInternetError: Bool {
        return (self as NSError).isInternetError
    }
}

extension NSError {
    var isTimeout: Bool {
        return domain == NSURLErrorDomain && code == NSURLErrorTimedOut
    }

    var isInternetError: Bool {
        return domain == NSURLErrorDomain && internetErrorCodes.contains(code)
    }
}
