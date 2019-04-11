//
//  SpendKinViewController.swift
//  KinWallet
//
//  Copyright © 2018 KinFoundation. All rights reserved.
//

import UIKit

class UseKinViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()

        addBalanceLabel()
        addAndFit(StoryboardScene.Spend.offerWallViewController.instantiate())
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
}
