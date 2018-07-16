//
//  BalanceViewController.swift
//  Kinit
//

import UIKit

class BalanceViewController: UIViewController {
    @IBOutlet var headerGradientViews: [GradientView]! {
        didSet {
            headerGradientViews.forEach {
                $0.colors = UIColor.navigationBarGradientColors
                $0.direction = .horizontal
            }
        }
    }

    @IBOutlet weak var containerView: UIView!

    @IBOutlet weak var balanceLabel: BalanceLabel! {
        didSet {
            balanceLabel.textColor = .white
            balanceLabel.type = .prefixed
            balanceLabel.size = .large
        }
    }

    @IBOutlet weak var balanceTitleLabel: UILabel! {
        didSet {
            balanceTitleLabel.font = FontFamily.Roboto.regular.font(size: 12)
            balanceTitleLabel.textColor = UIColor.white.withAlphaComponent(0.7)
            balanceTitleLabel.text = L10n.yourKinBalance
        }
    }

    @IBOutlet weak var transactionsHeader: UIView! {
        didSet {
            transactionsHeader.layer.shadowColor = UIColor.lightGray.cgColor
            transactionsHeader.layer.shadowRadius = 3
            transactionsHeader.layer.shadowOpacity = 3
            transactionsHeader.layer.shadowOffset = CGSize(width: 0, height: 1)
        }
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        addAndFit(StoryboardScene.Main.balancePagerTabViewController.instantiate(), to: containerView)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        Events.Analytics.ViewBalancePage().send()
    }
}
