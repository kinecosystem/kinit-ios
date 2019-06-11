//
//  OneWalletLinkTypes.swift
//  KinWallet
//
//  Copyright © 2019 KinFoundation. All rights reserved.
//

import Foundation

let walletLinkingTypeIdentifier = "org.kinecosystem.wallet-linking"
let walletLinkingResultTypeIdentifier = "org.kinecosystem.wallet-linking-result"

struct KinWalletLinkRequestPayload: Codable {
    let bundleId: String
    let appName: String
    let publicAddress: String
    let urlScheme: String
}

enum KinitOneWalletLinkError: Error {
    case decodeError
}

public typealias EnvelopeBase64 = String
public typealias MasterAddress = String

enum OneWalletLinkResult {
    case success(EnvelopeBase64, MasterAddress)
    case noAccount
    case cancelled
    case decodingError
    case addressesMatch
    case addressAlreadyLinked
}

extension OneWalletLinkResult: Codable {
    private struct LinkResultKey {
        static let success = "success"
        static let noAccount = "no-account"
        static let cancelled = "cancelled"
        static let decodingError = "decoding-error"
        static let addressesMatch = "addresses-match"
        static let addressAlreadyLinked = "addresses-already-linked"
    }

    private enum CodingKeys: String, CodingKey {
        case result
        case successEnvelope = "envelope"
        case masterAddress = "master-address"
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        let result = try container.decode(String.self, forKey: .result)

        switch result {
        case LinkResultKey.cancelled: self = .cancelled
        case LinkResultKey.decodingError: self = .decodingError
        case LinkResultKey.noAccount: self = .noAccount
        case LinkResultKey.addressesMatch: self = .addressesMatch
        case LinkResultKey.addressAlreadyLinked: self = .addressAlreadyLinked
        case LinkResultKey.success:
            let envelope = try container.decode(String.self, forKey: .successEnvelope)
            let masterAddress = try container.decode(String.self, forKey: .masterAddress)
            self = .success(envelope, masterAddress)
        default: self = .decodingError
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        switch self {
        case .cancelled: try container.encode(LinkResultKey.cancelled, forKey: .result)
        case .decodingError: try container.encode(LinkResultKey.decodingError, forKey: .result)
        case .noAccount: try container.encode(LinkResultKey.noAccount, forKey: .result)
        case .addressesMatch: try container.encode(LinkResultKey.addressesMatch, forKey: .result)
        case .addressAlreadyLinked: try container.encode(LinkResultKey.addressAlreadyLinked, forKey: .result)
        case .success(let envelope, let masterAddress):
            try container.encode(LinkResultKey.success, forKey: .result)
            try container.encode(envelope, forKey: .successEnvelope)
            try container.encode(masterAddress, forKey: .masterAddress)
        }
    }
}

struct OneWalletTopupRequest: Codable {
    let appBundleIdentifier: String
    let publicAddress: String
    let appURLScheme: String
    let appName: String
}
