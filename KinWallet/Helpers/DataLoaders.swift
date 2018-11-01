//
//  DataLoaders.swift
//  KinWallet
//
//  Copyright © 2018 KinFoundation. All rights reserved.
//

import Foundation

class DataLoaders {
    private static let instance = DataLoaders()

    let kinit = KinitLoader()
    let tasks = TaskLoader()

    static var kinit: KinitLoader {
        return instance.kinit
    }

    static var tasks: TaskLoader {
        return instance.tasks
    }

    init() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(applicationWillEnterForeground),
                                               name: UIApplication.willEnterForegroundNotification,
                                               object: nil)
    }

    @objc func applicationWillEnterForeground() {
        guard User.current != nil else {
            return
        }

        loadAllData()
    }

    static func loadAllData() {
        instance.loadAllData()
    }

    private func loadAllData() {
        kinit.loadAllData()
        tasks.loadAllData()
    }
}
