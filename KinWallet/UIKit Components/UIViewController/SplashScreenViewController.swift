//
//  SplashScreenViewController.swift
//  Kinit
//

import UIKit
import KinUtil

final class SplashScreenViewController: UIViewController {
    let linkBag = LinkBag()

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationController?.setNavigationBarHidden(true, animated: false)

        if User.current?.publicAddress != nil && User.current?.phoneNumber != nil {
            DataLoaders.tasks.categories
                .on(queue: .main, next: { _ in
                    AppDelegate.shared.dismissSplashIfNeeded()
                }).add(to: linkBag)
        }

        let splashFromStoryboard = StoryboardScene.LaunchScreen.splashScreenViewController.instantiate()
        addAndFit(splashFromStoryboard)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        Events.Analytics.ViewSplashscreenPage().send()
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
}
