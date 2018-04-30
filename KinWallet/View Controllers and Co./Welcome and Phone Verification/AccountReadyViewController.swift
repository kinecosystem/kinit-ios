//
//  AccountReadyViewController.swift
//  KinWallet
//
//  Copyright © 2018 KinFoundation. All rights reserved.
//

import UIKit

class AccountReadyViewController: UIViewController {
    @IBOutlet weak var confettiView: ConfettiView!

    @IBOutlet weak var titleLabel: UILabel! {
        didSet {
            titleLabel.textColor = UIColor.kin.appTint
            titleLabel.font = FontFamily.Roboto.black.font(size: 42)
        }
    }

    @IBOutlet weak var descriptionLabel: UILabel! {
        didSet {
            descriptionLabel.textColor = UIColor.kin.gray
            descriptionLabel.font = FontFamily.Roboto.regular.font(size: 16)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(viewTapped))
        view.addGestureRecognizer(tapGesture)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        confettiView.start()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        FeedbackGenerator.notifySuccessIfAvailable()

        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            AppDelegate.shared.dismissSplashIfNeeded()
        }
    }

    @objc func viewTapped() {
        AppDelegate.shared.dismissSplashIfNeeded()
    }
}
