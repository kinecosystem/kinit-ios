//
//  KinNavigationController.swift
//  Kinit
//

import UIKit

protocol KinNavigationControllerDelegate: class {
    func shouldPopViewController() -> Bool
}

class KinNavigationController: UINavigationController {
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }

    override var childForStatusBarStyle: UIViewController? {
        return topViewController
    }

    override var prefersStatusBarHidden: Bool {
        return topViewController?.prefersStatusBarHidden ?? false
    }

    override func popViewController(animated: Bool) -> UIViewController? {
        if let backupNavigationDelegate = topViewController as? KinNavigationControllerDelegate,
            !backupNavigationDelegate.shouldPopViewController() {
            return nil
        }

        return super.popViewController(animated: animated)
    }
}

extension KinNavigationController: UINavigationBarDelegate {
    func navigationBar(_ navigationBar: UINavigationBar, shouldPop item: UINavigationItem) -> Bool {
        if item == topViewController?.navigationItem {
            _ = popViewController(animated: true)
            return false
        }

        return true
    }
}
