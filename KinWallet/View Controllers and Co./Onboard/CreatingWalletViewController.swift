//
//  CreatingWalletViewController.swift
//  KinWallet
//
//  Copyright © 2018 KinFoundation. All rights reserved.
//

import UIKit
import Lottie

private struct Constants {
    static let errorMessageFont = FontFamily.Roboto.regular.font(size: 14)!
    static let errorMessageTextColor = UIColor.kin.gray
}

class WalletLoadingViewController: UIViewController {
    @IBOutlet weak var descriptionLabel: UILabel! {
        didSet {
            descriptionLabel.font = FontFamily.Roboto.medium.font(size: 16)
            descriptionLabel.textColor = UIColor.kin.gray
        }
    }

    @IBOutlet weak var bottomContainerView: UIView!

    let timeEstimationLabel: UILabel = {
        let l = UILabel()
        l.textAlignment = .center
        l.translatesAutoresizingMaskIntoConstraints = false
        l.text = L10n.creatingYourWalletBePatient
        l.font = FontFamily.Roboto.regular.font(size: 12)
        l.textColor = UIColor.kin.gray

        return l
    }()

    @IBOutlet weak var loaderView: LOTAnimationView! {
        didSet {
            loaderView.backgroundColor = .clear
            loaderView.setAnimation(named: "WalletLoader.json")
            loaderView.loopAnimation = true
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        loaderView.play()

        addTimeEstimationLabel()
    }

    func addTimeEstimationLabel() {
        addToBottomView(timeEstimationLabel)
    }

    func addToBottomView(_ subview: UIView) {
        bottomContainerView.removeAllSubviews()
        bottomContainerView.addSubview(subview)
        bottomContainerView.leadingAnchor.constraint(equalTo: subview.leadingAnchor).isActive = true
        bottomContainerView.bottomAnchor.constraint(equalTo: subview.bottomAnchor).isActive = true
        bottomContainerView.trailingAnchor.constraint(equalTo: subview.trailingAnchor).isActive = true
    }
}

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

class MigratingWalletViewController: UIViewController {
    let walletLoadingViewController = StoryboardScene.Onboard.walletLoadingViewController.instantiate()

    override func viewDidLoad() {
        super.viewDidLoad()

        addAndFit(walletLoadingViewController)
        walletLoadingViewController.descriptionLabel.text = L10n.Migration.migratingWallet
    }

    func migrationFailed() {
        walletLoadingViewController.loaderView.stop()
        walletLoadingViewController.loaderView.animationProgress = 0
        walletLoadingViewController.descriptionLabel.text = nil

        addBottomViews()
    }

    func addBottomViews() {
        let errorLabel = UILabel()
        errorLabel.textColor = Constants.errorMessageTextColor
        errorLabel.font = Constants.errorMessageFont
        errorLabel.text = L10n.Migration.migrationFailed

        let orLabel = UILabel()
        orLabel.text = L10n.or.lowercased()
        orLabel.font = Constants.errorMessageFont
        orLabel.textColor = Constants.errorMessageTextColor

        let retryButton = failedButton(with: L10n.retry, selector: #selector(retryMigration))
        let supportButton = failedButton(with: L10n.contactSupport.lowercased(), selector: #selector(contactSupport))

        let bottomStackView = UIStackView(arrangedSubviews: [retryButton, orLabel, supportButton])
        bottomStackView.translatesAutoresizingMaskIntoConstraints = false
        bottomStackView.alignment = .center
        bottomStackView.distribution = .equalSpacing
        bottomStackView.axis = .horizontal
        bottomStackView.spacing = 2

        let externalStackView = UIStackView(arrangedSubviews: [errorLabel, bottomStackView])
        externalStackView.translatesAutoresizingMaskIntoConstraints = false
        externalStackView.alignment = .center
        externalStackView.distribution = .equalSpacing
        externalStackView.axis = .vertical
        externalStackView.spacing = 0

        walletLoadingViewController.addToBottomView(externalStackView)
    }

    private func failedButton(with title: String, selector: Selector) -> UIButton {
        let button = UIButton(type: .custom)
        let attributedTitle = NSAttributedString(string: title,
                                                 attributes: [.foregroundColor: Constants.errorMessageTextColor,
                                                              .font: Constants.errorMessageFont,
                                                              .underlineStyle: NSUnderlineStyle.single.rawValue])
        button.setAttributedTitle(attributedTitle, for: .normal)
        button.addTarget(self, action: selector, for: .touchUpInside)

        return button
    }

    @objc func retryMigration() {
        walletLoadingViewController.loaderView.play()
        walletLoadingViewController.addTimeEstimationLabel()
        walletLoadingViewController.descriptionLabel.text = L10n.Migration.migratingWallet

        Kin.shared.startMigration()
    }

    @objc func contactSupport() {
        KinSupportViewController.presentSupport(from: self)
    }
}
