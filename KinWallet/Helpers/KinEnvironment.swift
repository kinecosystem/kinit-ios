//
//  KinEnvironment.swift
//  KinWallet
//
//  Copyright © 2019 KinFoundation. All rights reserved.
//

import Foundation

import KinSDK
import KinMigrationModule

enum KinEnvironment {
    static let kinSDKNetwork: KinSDK.Network = {
        #if DEBUG || RELEASE_STAGE
        return .testNet
        #else
        return .mainNet
        #endif
    }()

    static let network: KinMigrationModule.Network = {
        #if DEBUG || RELEASE_STAGE
        return .testNet
        #else
        return .mainNet
        #endif
    }()

    static let nodeURL: URL = {
        #if DEBUG || RELEASE_STAGE
        return URL(string: "https://horizon-testnet.kininfrastructure.com")!
        #else
        return URL(string: "https://horizon.kinfederation.com")!
        #endif
    }()

    static let kinitAppId = "kit"
}
