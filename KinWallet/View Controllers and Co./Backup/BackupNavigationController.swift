//
//  BackupNavigationController.swift
//  KinWallet
//
//  Copyright © 2018 KinFoundation. All rights reserved.
//

import UIKit

protocol BackupNavigationDelegate: class {
    func shouldPopViewController() -> Bool
}

class BackupNavigationController: KinNavigationController {
    var confirmEmailAppearCount = 0
    var sendEmailAppearCount = 0

    override func popViewController(animated: Bool) -> UIViewController? {
        if let backupNavigationDelegate = topViewController as? BackupNavigationDelegate,
            !backupNavigationDelegate.shouldPopViewController() {
            return nil
        }

        return super.popViewController(animated: animated)
    }
}

extension BackupNavigationController: UINavigationBarDelegate {
    func navigationBar(_ navigationBar: UINavigationBar, shouldPop item: UINavigationItem) -> Bool {
        if item == topViewController?.navigationItem {
            _ = popViewController(animated: true)
            return false
        }

        return true
    }
}
