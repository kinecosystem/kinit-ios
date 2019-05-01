//
//  MigratingWalletViewController.swift
//  KinWallet
//
//  Copyright © 2019 KinFoundation. All rights reserved.
//

import UIKit

private struct Constants {
    static let errorMessageFont = FontFamily.Roboto.regular.font(size: 14)!
    static let errorMessageTextColor = UIColor.kin.gray
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
