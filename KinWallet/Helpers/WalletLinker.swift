//
//  WalletLinker.swift
//  KinWallet
//
//  Copyright © 2019 KinFoundation. All rights reserved.
//

import Foundation
import KinSDK

typealias WalletLinkingResult = (Promise<TransactionEnvelope>, String?)

enum WalletLinkerError: Error {
    case noAccount
}

class WalletLinker {
    private static var kinClient: KinClient {
        let appId = try! AppId(KinEnvironment.kinitAppId) //swiftlint:disable:this force_try

        return KinClient(with: KinEnvironment.nodeURL,
                         network: KinEnvironment.kinSDKNetwork,
                         appId: appId)
    }

    static func isWalletAvailable() -> Bool {
        return kinClient.accounts.isNotEmpty && User.current?.publicAddress != nil
    }

    static func isAddressAllowedToLink(_ address: String) -> Bool {
        guard let account = kinClient.accounts.last else {
            return false
        }

        return account.publicAddress != address
    }

    static func createLinkingAccountsTransaction(to publicAddress: String,
                                                 appBundleIdentifier: String) -> WalletLinkingResult {
        guard let account = kinClient.accounts.last else {
            return (.init(WalletLinkerError.noAccount), nil)
        }

        return (account.linkAccount(to: publicAddress, appBundleIdentifier: appBundleIdentifier), account.publicAddress)
    }
}
