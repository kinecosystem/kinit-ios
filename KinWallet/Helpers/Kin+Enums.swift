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


extension Notification.Name {
    static let KinMigrationStarted = Notification.Name("KinMigrationStarted")
    static let KinMigrationFailed = Notification.Name("KinMigrationFailed")
    static let KinMigrationSucceeded = Notification.Name("KinMigrationSucceeded")
}

protocol BalanceDelegate: class {
    func balanceDidUpdate(balance: UInt64)
}
