//
//  Kin+Enums.swift
//  KinWallet
//
//  Copyright © 2019 KinFoundation. All rights reserved.
//

import Foundation

enum TxSignatureError: Error {
    case encodingFailed
    case decodingFailed
}

enum SendTransactionType {
    case spend
    case crossApp

    var toBIEventType: Events.TransactionType {
        switch self {
        case .spend: return .spend
        case .crossApp: return .crossApp
        }
    }
}

enum OnboardingResult {
    case success
    case failure(String)
}

enum ImportWalletResult {
    case success(migrationNeeded: Bool)
    case decryptFailed(Error)
    case migrationCheckFailed(Error)
}
