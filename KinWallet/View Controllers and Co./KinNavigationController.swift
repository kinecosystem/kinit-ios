//
//  KinNavigationController.swift
//  Kinit
//

import UIKit

class KinNavigationController: UINavigationController {
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }

    override var childViewControllerForStatusBarStyle: UIViewController? {
        return topViewController
    }
}
