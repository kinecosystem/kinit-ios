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

    @IBAction func restoreWallet(_ sender: Any) {
        let scannerViewController = StoryboardScene.Onboard.restoreBackupQRScannerViewController.instantiate()
        navigationController?.pushViewController(scannerViewController, animated: true)
    }

    @IBAction func createWallet(_ sender: Any) {
        AppDelegate.shared.rootViewController.startCreatingWallet()
    }
}
