//
//  SplashScreenViewController.swift
//  KinWallet
//
//  Copyright © 2018 KinFoundation. All rights reserved.
//

import UIKit
import KinUtil

final class SplashScreenViewController: UIViewController {
    var creatingAccount = false
    let linkBag = LinkBag()

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationController?.setNavigationBarHidden(true, animated: false)

        if Kin.shared.accountStatus == .activated && User.current?.phoneNumber != nil {
            KinLoader.shared.currentTask
                .on(queue: .main, next: { _ in
                    AppDelegate.shared.dismissSplashIfNeeded()
                }).add(to: linkBag)
        }

        let splashFromStoryboard = StoryboardScene.LaunchScreen.splashScreenViewController.instantiate()
        addAndFit(splashFromStoryboard)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        if creatingAccount {
            let label = creatingWalletLabel()
            label.font = FontFamily.Roboto.medium.font(size: 16)
            UIView.animate(withDuration: 0.4) {
                label.alpha = 1
            }
        }

        Events.Analytics.ViewSplashscreenPage().send()
    }

    func creatingWalletLabel() -> UILabel {
        return childViewControllers
            .first!
            .view
            .subviews
            .compactMap { $0 as? UILabel }
            .first!
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
}
