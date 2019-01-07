//
//  GetAddressFlowTypes.swift
//  KinWallet
//
//  Copyright © 2019 KinFoundation. All rights reserved.
//

import Foundation

struct GetAddressFlowTypes {
    enum Result {
        case success(PublicAddress)
        case cancelled
        case error(Error)
    }

    enum Error: Swift.Error {
        case invalidURLScheme
        case appLaunchFailed(MoveKinApp)
        case bundleIdMismatch
        case invalidHandleURL
        case invalidAddress
        case timeout
    }

    enum State {
        case idle
        case launchingApp
        case waitingForAddress(bundleId: String)
        case error(Error)
        case success(PublicAddress)
        case cancelled
    }
}

extension GetAddressFlowTypes.Error: Equatable {
    static func == (lhs: GetAddressFlowTypes.Error, rhs: GetAddressFlowTypes.Error) -> Bool {
        switch (lhs, rhs) {
        case (.invalidURLScheme, .invalidURLScheme),
             (.bundleIdMismatch, .bundleIdMismatch),
             (.invalidHandleURL, .invalidHandleURL),
             (.invalidAddress, .invalidAddress),
             (.timeout, .timeout):
            return true
        case (.appLaunchFailed(let lApp), .appLaunchFailed(let rApp)):
            return lApp == rApp
        default:
            return false
        }
    }
}

extension GetAddressFlowTypes.State: Equatable {
    static func == (lhs: GetAddressFlowTypes.State, rhs: GetAddressFlowTypes.State) -> Bool {
        switch (lhs, rhs) {
        case (.idle, .idle), (.launchingApp, .launchingApp), (.cancelled, .cancelled): return true
        case (.success(let la), .success(let ra)): return ra.asString == la.asString
        case (.waitingForAddress(let lb), .waitingForAddress(let rb)): return lb == rb
        case (.error(let le), .error(let re)): return le == re
        default: return false
        }
    }
}

extension GetAddressFlowTypes.State {
    var toResult: GetAddressFlowTypes.Result? {
        switch self {
        case .success(let address):
            return .success(address)
        case .error(let error):
            return .error(error)
        case .cancelled:
            return .cancelled
        case .idle, .launchingApp, .waitingForAddress:
            return nil
        }
    }
}
