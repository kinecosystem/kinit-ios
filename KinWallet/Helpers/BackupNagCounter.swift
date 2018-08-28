//
//  BackupNagCounter.swift
//  KinWallet
//
//  Copyright © 2018 KinFoundation. All rights reserved.
//

import Foundation

private let currentBackupNagCountKey = "org.kinecosystem.kinit.backupNagCount"

class BackupNagCounter {
    static var count: Int {
        return UserDefaults.standard.integer(forKey: currentBackupNagCountKey)
    }

    static func increment() {
        UserDefaults.standard.set(count + 1, forKey: currentBackupNagCountKey)
    }
}
