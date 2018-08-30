//
//  BackupNagCounter.swift
//  KinWallet
//
//  Copyright © 2018 KinFoundation. All rights reserved.
//

import Foundation

private let currentBackupNagCountKey = "org.kinecosystem.kinit.backupNagCount"
private let backupNagCountLastIncrementDateKey = "org.kinecosystem.kinit.backupNagCountLastIncrementDate"

class BackupNagCounter {
    static var count: Int {
        return UserDefaults.standard.integer(forKey: currentBackupNagCountKey)
    }

    static func incrementIfNeeded() {
        if let lastIncrementDate = UserDefaults.standard.object(forKey: backupNagCountLastIncrementDateKey) as? Date,
            lastIncrementDate > Date().beginningOfDay() {
            return
        }

        increment()
    }

    static func increment() {
        UserDefaults.standard.set(Date(), forKey: backupNagCountLastIncrementDateKey)
        UserDefaults.standard.set(count + 1, forKey: currentBackupNagCountKey)
    }
}
