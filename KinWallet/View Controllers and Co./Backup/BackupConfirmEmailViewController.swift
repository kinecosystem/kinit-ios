//
//  BackupConfirmEmailViewController.swift
//  KinWallet
//
//  Copyright © 2018 KinFoundation. All rights reserved.
//

import UIKit

class BackupConfirmEmailViewController: UIViewController {
    @IBOutlet weak var titleLabel: UILabel! {
        didSet {
            titleLabel.font = FontFamily.Roboto.medium.font(size: 22)
            titleLabel.textColor = UIColor.kin.darkGray
            titleLabel.text = L10n.backupConfirmTitle
        }
    }

    @IBOutlet weak var resendEmailLabel: UILabel! {
        didSet {
            resendEmailLabel.isUserInteractionEnabled = true
            resendEmailLabel.font = FontFamily.Roboto.regular.font(size: 16)
            resendEmailLabel.textColor = UIColor.kin.gray

            let resend = L10n.backupConfirmResend
            let resendMessage = L10n.backupConfirmResendMessage(resend)
            let range = (resendMessage as NSString).range(of: resend)

            let attributedString = NSMutableAttributedString(string: resendMessage)
            attributedString.addAttribute(.foregroundColor, value: UIColor.kin.appTint, range: range)
            attributedString.addAttribute(.underlineStyle, value: NSUnderlineStyle.styleSingle.rawValue, range: range)
            resendEmailLabel.attributedText = attributedString
        }
    }

    @IBOutlet weak var messageStackView: UIStackView!

    @IBOutlet weak var subtitleLabel: UILabel! {
        didSet {
            subtitleLabel.font = FontFamily.Roboto.regular.font(size: 16)
            subtitleLabel.textColor = UIColor.kin.gray
            subtitleLabel.text = L10n.backupConfirmSubtitle
        }
    }

    @IBOutlet weak var messageLabel: UILabel! {
        didSet {
            messageLabel.textColor = UIColor.kin.gray
            messageLabel.font = FontFamily.Roboto.medium.font(size: 18)
            messageLabel.text = L10n.backupConfirmMessage
        }
    }

    private let confirmAccessoryView: ButtonAccessoryInputView = {
        let b = ButtonAccessoryInputView()
        b.title = L10n.confirm
        b.translatesAutoresizingMaskIntoConstraints = false

        return b
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        view.addSubview(confirmAccessoryView)
        view.leadingAnchor.constraint(equalTo: confirmAccessoryView.leadingAnchor).isActive = true
        view.trailingAnchor.constraint(equalTo: confirmAccessoryView.trailingAnchor).isActive = true

        if #available(iOS 11.0, *) {
            view.safeAreaLayoutGuide.bottomAnchor.constraint(equalTo: confirmAccessoryView.bottomAnchor).isActive = true
        } else {
            view.bottomAnchor.constraint(equalTo: confirmAccessoryView.bottomAnchor).isActive = true
        }

        messageStackView.bottomAnchor.constraint(lessThanOrEqualTo: confirmAccessoryView.topAnchor,
                                                 constant: 20).isActive = true

        confirmAccessoryView.tapped.on(next: backupComplete)
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    @IBAction func resendEmail(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }

    func backupComplete() {
        let backupDoneViewController = StoryboardScene.Backup.backupDoneViewController.instantiate()
        navigationController?.pushViewController(backupDoneViewController, animated: true)
    }
}
