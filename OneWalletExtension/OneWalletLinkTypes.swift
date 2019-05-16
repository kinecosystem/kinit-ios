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
}

enum KinitOneWalletOperationType {
    case confirmSetup
    case link(KinWalletLinkRequestPayload)
}

enum KinitOneWalletLinkError: Error {
    case decodeError
}

extension KinitOneWalletOperationType: Codable {
    private struct OperationTypeKey {
        static let link = "link"
        static let confirmSetup = "confirm-setup"
    }

    private enum CodingKeys: String, CodingKey {
        case type
        case linkRequestPayload = "payload"
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        let type = try container.decode(String.self, forKey: .type)

        switch type {
        case OperationTypeKey.confirmSetup:
            self = .confirmSetup
        case OperationTypeKey.link:
            self = .link(try container.decode(KinWalletLinkRequestPayload.self, forKey: .linkRequestPayload))
        default:
            throw KinitOneWalletLinkError.decodeError
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        switch self {
        case .confirmSetup:
            try container.encode(OperationTypeKey.confirmSetup, forKey: .type)
        case .link(let payload):
            try container.encode(OperationTypeKey.link, forKey: .type)
            try container.encode(payload, forKey: .linkRequestPayload)
        }
    }
}

enum OneWalletLinkResult {
    case success(String)
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
            self = .success(envelope)
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
        case .success(let envelope):
            try container.encode(LinkResultKey.success, forKey: .result)
            try container.encode(envelope, forKey: .successEnvelope)
        }
    }
}
