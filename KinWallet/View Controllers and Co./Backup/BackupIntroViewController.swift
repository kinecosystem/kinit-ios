//
//  BackupIntroViewController.swift
//  KinWallet
//
//  Copyright © 2018 KinFoundation. All rights reserved.
//

import UIKit

enum BackupStep: Int {
    case firstQuestion = 0
    case secondQuestion
    case sendQRCode
}

extension BackupStep {
    var title: String {
        switch self {
        case .firstQuestion: return L10n.firstSecurityQuestion
        case .secondQuestion: return L10n.secondSecurityQuestion
        case .sendQRCode: return L10n.secondSecurityQuestion
        }
    }
}

class BackupIntroViewController: UIViewController {
    var hints: [AvailableBackupHint]?

    @IBOutlet weak var backupNowButton: UIButton! {
        didSet {
            backupNowButton.makeKinButtonFilled()
        }
    }

    @IBOutlet weak var titleLabel: UILabel! {
        didSet {
            titleLabel.font = FontFamily.Roboto.medium.font(size: 22)
            titleLabel.textColor = UIColor.kin.darkGray
            titleLabel.text = L10n.walletBackup
        }
    }

    @IBOutlet weak var explanationLabel: UILabel! {
        didSet {
            explanationLabel.font = FontFamily.Roboto.regular.font(size: 16)
            explanationLabel.textColor = UIColor.kin.gray
            explanationLabel.text = L10n.backupIntroExplanation
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .white
        KinLoader.shared.fetchAvailableBackupHints(skipCache: true)

        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel",
                                                           style: .plain,
                                                           target: self,
                                                           action: #selector(cancel))
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    @objc func cancel() {
        dismiss(animated: true, completion: nil)
    }

    @IBAction func backupNow(_ sender: Any) {
        guard let hints = hints else {
            return
        }

        let firstQuestion = StoryboardScene.Backup.backupQuestionViewController.instantiate()
        firstQuestion.availableHints = hints
        firstQuestion.step = .firstQuestion
        navigationController?.pushViewController(firstQuestion, animated: true)
    }
}
