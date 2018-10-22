//
//  DataLoaders.swift
//  KinWallet
//
//  Copyright © 2018 KinFoundation. All rights reserved.
//

import Foundation

class DataLoaders {
    static let kinit = KinitLoader()
    static let tasks = TaskLoader()

    static func loadAllData() {
        kinit.loadAllData()
        tasks.loadAllData()
    }
}
