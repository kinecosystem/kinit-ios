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

    var analyticsStep: Events.BackupFlowStep {
        switch self {
        case .firstQuestion: return .securityQuestion1
        case .secondQuestion: return .securityQuestion2
        case .sendQRCode: return .sendEmail
        }
    }
}

protocol BackupIntroDelegate: class {
    func backupIntroDidCancel(with emailConfirmAttempts: Int)
}

class BackupIntroViewController: UIViewController {
    var hints: [AvailableBackupHint]?
    weak var delegate: BackupIntroDelegate?

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

        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel",
                                                           style: .plain,
                                                           target: self,
                                                           action: #selector(cancel))
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        Events.Analytics.ViewBackupIntroPage().send()
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    @objc func cancel() {
        let attempsCount = (navigationController as? BackupNavigationController)?.confirmEmailAppearCount ?? 0
        delegate?.backupIntroDidCancel(with: attempsCount)
    }

    @IBAction func backupNow(_ sender: Any) {
        Events.Analytics.ClickBackupButtonOnBackupIntroPage().send()

        guard let hints = hints else {
            return
        }

        let firstQuestion = StoryboardScene.Backup.backupQuestionViewController.instantiate()
        firstQuestion.availableHints = hints
        firstQuestion.step = .firstQuestion
        navigationController?.pushViewController(firstQuestion, animated: true)
    }
}
