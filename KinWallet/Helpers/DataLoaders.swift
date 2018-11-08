//
//  DataLoaders.swift
//  KinWallet
//
//  Copyright © 2018 KinFoundation. All rights reserved.
//

import Foundation
import UIKit

class DataLoaders {
    private static let instance = DataLoaders()

    let kinit = KinitLoader()
    let tasks = TaskLoader()
    var didEnterBackground = false

    static var kinit: KinitLoader {
        return instance.kinit
    }

    static var tasks: TaskLoader {
        return instance.tasks
    }

    init() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(applicationDidBecomeActive),
                                               name: UIApplication.didBecomeActiveNotification,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(applicationDidEnterBackground),
                                               name: UIApplication.didEnterBackgroundNotification,
                                               object: nil)
    }

    @objc func applicationDidEnterBackground() {
        didEnterBackground = true
    }

    @objc func applicationDidBecomeActive() {
        guard User.current != nil, didEnterBackground else {
            return
        }

        didEnterBackground = false
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
