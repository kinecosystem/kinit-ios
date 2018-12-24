//
//  SpendKinViewController.swift
//  KinWallet
//
//  Copyright © 2018 KinFoundation. All rights reserved.
//

import UIKit

class UseKinViewController: UIViewController {
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var separatorView: UIView! {
        didSet {
            separatorView.backgroundColor = UIColor.kin.lightGray
        }
    }

    let pagerTabViewController = UseKinPagerTabViewController()
    @IBOutlet weak var buttonBarView: ButtonBarView!

    override func viewDidLoad() {
        super.viewDidLoad()

        addBalanceLabel()

        pagerTabViewController.buttonBarView = buttonBarView
        add(pagerTabViewController) { v in
            containerView.addAndFit(v)
        }
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
}

class UseKinPagerTabViewController: ButtonBarPagerTabStripViewController {
    override func viewDidLoad() {
        applyKinitStyle()

        super.viewDidLoad()
    }

    override func viewControllers(for pagerTabStripController: PagerTabStripViewController) -> [UIViewController] {
        return [StoryboardScene.Spend.offerWallViewController.instantiate(),
                AppDiscoveryViewController()]
    }
}
