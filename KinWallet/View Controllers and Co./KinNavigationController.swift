//
//  KinNavigationController.swift
//  Kinit
//

import UIKit

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
}
