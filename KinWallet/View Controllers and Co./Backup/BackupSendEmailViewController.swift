//
//  BackupSendEmailViewController.swift
//  KinWallet
//
//  Copyright © 2018 KinFoundation. All rights reserved.
//

import UIKit

class BackupSendEmailViewController: BackupTextInputViewController {
    var encryptedWallet: String!
    var chosenHints: [Int]!

    var insertedEmailAddress: String {
        return textField.textOrEmpty.trimmingCharacters(in: .whitespaces)
    }

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

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        if let navController = navigationController as? BackupNavigationController {
            navController.sendEmailAppearCount += 1

            if navController.sendEmailAppearCount >= 3 {
                let alertController = UIAlertController(title: L10n.performBackupTooManyEmailAttemptsTitle,
                                                        message: L10n.performBackupTooManyEmailAttemptsMessage,
                                                        preferredStyle: .alert)
                alertController.addOkAction()
                presentAnimated(alertController)
            }
        }

        Events.Analytics
            .ViewBackupFlowPage(backupFlowStep: .sendEmail)
            .send()
    }

    override func isInputTextValid(text: String?) -> Bool {
        return (text ?? insertedEmailAddress).isValidEmailAddress
    }

    override func moveToNextStep() {
        Events.Analytics
            .ClickCompletedStepButtonOnBackupFlowPage(backupFlowStep: .sendEmail)
            .send()
        submitQRCode()
    }

    private func submitQRCode() {
        accessoryView.isLoading = true

        WebRequests.Backup.sendEmail(to: insertedEmailAddress, encryptedKey: encryptedWallet)
            .withCompletion { [weak self] result in
                DispatchQueue.main.async {
                    guard let self = self else {
                        return
                    }

                    self.accessoryView.isLoading = false

                    switch result {
                    case .failure:
                        self.presentSupportAlert(title: L10n.generalServerErrorTitle,
                                                 message: L10n.generalServerErrorMessage)
                    case .success:
                        let confirmEmailReceived = StoryboardScene.Backup.backupConfirmEmailViewController.instantiate()
                        confirmEmailReceived.chosenHints = self.chosenHints
                        self.navigationController?.pushViewController(confirmEmailReceived, animated: true)
                    }
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

        let newText = (currentText as NSString)
            .replacingCharacters(in: range, with: string)
            .trimmingCharacters(in: .whitespaces)
        accessoryView.isEnabled = isInputTextValid(text: newText)

        return true
    }
}
