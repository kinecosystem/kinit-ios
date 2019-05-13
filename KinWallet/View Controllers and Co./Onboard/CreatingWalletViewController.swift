//
//  CreatingWalletViewController.swift
//  KinWallet
//
//  Copyright © 2019 KinFoundation. All rights reserved.
//

import UIKit

class CreatingWalletViewController: UIViewController {
    let walletLoadingViewController = StoryboardScene.Onboard.walletLoadingViewController.instantiate()

    override func viewDidLoad() {
        super.viewDidLoad()

        addAndFit(walletLoadingViewController)
        walletLoadingViewController.descriptionLabel.text = L10n.creatingYourWallet
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        navigationController?.setNavigationBarHidden(true, animated: animated)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        Events.Analytics.ViewCreatingWalletPage().send()
    }
}
