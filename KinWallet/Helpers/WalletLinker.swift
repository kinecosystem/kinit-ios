//
//  WalletLinker.swift
//  KinWallet
//
//  Copyright © 2019 KinFoundation. All rights reserved.
//

import Foundation
import KinSDK

enum WalletLinkerError: Error {
    case noAccount
}

enum KinEnvironment {
    static let network: KinSDK.Network = {
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

class WalletLinker {
    private static var kinClient: KinClient {
        let appId = try! AppId(KinEnvironment.kinitAppId) //swiftlint:disable:this force_try

        return KinClient(with: KinEnvironment.nodeURL,
                         network: KinEnvironment.network,
                         appId: appId)
    }

    static func isWalletAvailable() -> Bool {
        return kinClient.accounts.isNotEmpty
    }

    static func createLinkingAccountsTransaction(to publicAddress: String,
                                                 appBundleIdentifier: String) -> Promise<TransactionEnvelope> {
        guard let account = kinClient.accounts.last else {
            return .init(WalletLinkerError.noAccount)
        }

        return account.linkAccount(to: publicAddress, appBundleIdentifier: appBundleIdentifier)
    }
}
