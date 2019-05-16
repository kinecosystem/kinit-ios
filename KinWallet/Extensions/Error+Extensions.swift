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
    var isInternetError: Bool {
        return (self as NSError).isInternetError
    }
}

extension NSError {
    var isInternetError: Bool {
        return domain == NSURLErrorDomain && internetErrorCodes.contains(code)
    }
}
