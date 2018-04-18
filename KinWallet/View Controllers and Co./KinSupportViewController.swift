//
//  KinSupportViewController.swift
//  KinWallet
//
//  Copyright © 2018 KinFoundation. All rights reserved.
//

import UIKit
import MessageUI

private let supportEmail = "support@kinitapp.com"

class KinSupportViewController: MFMailComposeViewController {
    class func present(from presenter: UIViewController) {
        Analytics.logEvent(Events.Analytics.ClickSupportButton())

        guard MFMailComposeViewController.canSendMail() else {
            let alertMessage = "Add an email account to your device in order to send email."
            let alertController = UIAlertController(title: "Mail Not Configured",
                                                    message: alertMessage,
                                                    preferredStyle: .alert)
            alertController.addAction(.ok())
            presenter.present(alertController, animated: true)

            return
        }

        let mailController = KinSupportViewController()
        mailController.setToRecipients([supportEmail])
        mailController.setSubject("Kin Support Request")
        mailController.addAttachmentData(attachmentData(),
                                         mimeType: "txt",
                                         fileName: "Info.txt")
        mailController.mailComposeDelegate = mailController
        presenter.present(mailController, animated: true)
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    override var childViewControllerForStatusBarStyle: UIViewController? {
        return nil
    }

    private class func attachmentData() -> Data {
        return """
            App Version: \(Bundle.appVersion)
            iOS \(ProcessInfo().operatingSystemVersionString)
            Public address: \(Kin.shared.publicAddress)
            User ID: \(User.current?.userId ?? "No user ID")
            Balance: \(Kin.shared.balance)
            Device ID: \(User.current?.deviceId ?? "No device ID")
            Device Token: \(User.current?.deviceToken ?? "No device Token")
            """.data(using: .utf8) ?? Data()
    }
}

extension KinSupportViewController: MFMailComposeViewControllerDelegate {
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        dismiss(animated: true)

        if result == .sent {
            Analytics.logEvent(Events.Business.SupportRequestSent())
        }
    }
}
