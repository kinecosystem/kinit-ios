//
//  BackupSendEmailViewController.swift
//  KinWallet
//
//  Copyright © 2018 KinFoundation. All rights reserved.
//

import UIKit

class BackupSendEmailViewController: BackupTextInputViewController {
    var encryptedKey: String!

    @IBOutlet weak var titleLabel: UILabel! {
        didSet {
            titleLabel.font = FontFamily.Roboto.medium.font(size: 22)
            titleLabel.textColor = UIColor.kin.darkGray
            titleLabel.text = L10n.qrCode
        }
    }

    @IBOutlet weak var subtitleLabel: UILabel! {
        didSet {
            subtitleLabel.font = FontFamily.Roboto.regular.font(size: 16)
            subtitleLabel.textColor = UIColor.kin.gray
            subtitleLabel.text = L10n.backupQRCodeSubtitle
        }
    }

    @IBOutlet weak var emailAddressLabel: UILabel! {
        didSet {
            emailAddressLabel.text = L10n.backupQRCodeEmailAddress
            emailAddressLabel.font = FontFamily.Roboto.medium.font(size: 16)
            emailAddressLabel.textColor = UIColor.kin.darkGray
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        observationLabel.text = L10n.backupQRCodeEmailObservation
        textField.placeholder = L10n.backupQRCodeEmailPlaceholder

        if #available(iOS 10.0, *) {
            textField.textContentType = .emailAddress
        }
    }

    override func isInputTextValid(text: String?) -> Bool {
        return (text ?? textField.textOrEmpty).isValidEmailAddress
    }

    override func moveToNextStep() {
        submitQRCode()
    }

    private func submitQRCode() {
        accessoryView.isLoading = true

        WebRequests.sendBackupEmail(to: textField.text!, encriptedKey: encryptedKey)
            .withCompletion { [weak self] success, _ in
                DispatchQueue.main.async {
                    self?.accessoryView.isLoading = false

                    guard success.boolValue else {
                        //handle error

                        return
                    }

                    let confirmEmailReceived = StoryboardScene.Backup.backupConfirmEmailViewController.instantiate()
                    self?.navigationController?.pushViewController(confirmEmailReceived, animated: true)
                }
        }.load(with: KinWebService.shared)
    }
}

extension BackupSendEmailViewController {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        UIView.animate(withDuration: 0.3) {
            if self.titleStackViewTopConstraint.constant > 0 {
                self.titleStackViewTopConstraint.constant -= 60
                self.view.layoutIfNeeded()
            }
        }
    }

    func textField(_ textField: UITextField,
                   shouldChangeCharactersIn range: NSRange,
                   replacementString string: String) -> Bool {
        guard let currentText = textField.text else {
            return false
        }

        let newText = (currentText as NSString).replacingCharacters(in: range, with: string)
        accessoryView.isEnabled = isInputTextValid(text: newText)

        return true
    }
}