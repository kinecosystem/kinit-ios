//
//  KinEnvironment.swift
//  KinWallet
//
//  Copyright © 2019 KinFoundation. All rights reserved.
//

import Foundation

#if BUILDING_FOR_APP_EXTENSION
import KinSDK
#else
import KinMigrationModule
#endif

enum KinEnvironment {
    #if BUILDING_FOR_APP_EXTENSION
    static let network: KinSDK.Network = {
        #if DEBUG || RELEASE_STAGE
        return .testNet
        #else
        return .mainNet
        #endif
    }()
    #else
    static let network: KinMigrationModule.Network = {
        #if DEBUG || RELEASE_STAGE
        return .testNet
        #else
        return .mainNet
        #endif
    }()
    #endif

    static let nodeURL: URL = {
        #if DEBUG || RELEASE_STAGE
        return URL(string: "https://horizon-testnet.kininfrastructure.com")!
        #else
        return URL(string: "https://horizon.kinfederation.com")!
        #endif
    }()

    static let kinitAppId = "kit"
}
