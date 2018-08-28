//
//  AccountSourceViewController.swift
//  KinWallet
//
//  Copyright © 2018 KinFoundation. All rights reserved.
//

import UIKit

class AccountSourceViewController: UIViewController {
    @IBOutlet weak var titleLabel: UILabel! {
        didSet {
            titleLabel.text = L10n.backupAvailableTitle
            titleLabel.font = FontFamily.Roboto.regular.font(size: 16)
            titleLabel.textColor = UIColor.kin.gray
        }
    }

    @IBOutlet weak var restoreButton: UIButton! {
        didSet {
            restoreButton.setTitle(L10n.restoreFromBackup, for: .normal)
            restoreButton.makeKinButtonFilled()
        }
    }

    @IBOutlet weak var newWalletButton: UIButton! {
        didSet {
            newWalletButton.setTitle(L10n.createNewWallet, for: .normal)
            newWalletButton.makeKinButtonOutlined()
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        Events.Analytics.ViewWelcomeBackPage().send()
    }

    @IBAction func restoreWallet(_ sender: Any) {
        Events.Analytics.ClickRestoreWalletButtonOnWelcomeBackPage().send()

        let scannerViewController = StoryboardScene.Onboard.restoreBackupQRScannerViewController.instantiate()
        navigationController?.pushViewController(scannerViewController, animated: true)
    }

    @IBAction func createWallet(_ sender: Any) {
        Events.Analytics.ClickCreateNewWalletButtonOnWelcomeBackPage().send()

        let confirmAlertController = UIAlertController(title: L10n.backupIgnoreAndCreateNewWalletTitle,
                                                       message: L10n.backupIgnoreAndCreateNewWalletMessage,
                                                       preferredStyle: .alert)
        confirmAlertController.addAction(title: L10n.backAction, style: .cancel)
        confirmAlertController.addAction(title: L10n.continueAction, style: .default) {
            AppDelegate.shared.rootViewController.startCreatingWallet()
        }

        present(confirmAlertController, animated: true, completion: nil)
    }
}
