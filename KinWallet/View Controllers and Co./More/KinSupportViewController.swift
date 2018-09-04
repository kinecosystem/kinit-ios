//
//  KinSupportViewController.swift
//  Kinit
//

import UIKit
import MessageUI

private let supportEmail = "support@kinitapp.com"

final class KinSupportViewController: MFMailComposeViewController {
    class func present(from presenter: UIViewController) {
        Events.Analytics.ClickSupportButton().send()

        guard MFMailComposeViewController.canSendMail() else {
            let alertController = UIAlertController(title: L10n.mailNotConfiguredErrorTitle,
                                                    message: L10n.mailNotConfiguredErrorMessage,
                                                    preferredStyle: .alert)
            alertController.addOkAction()
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

    override var childForStatusBarStyle: UIViewController? {
        return nil
    }

    private class func attachmentString() -> String {
        return """
        App Version: \(Bundle.appVersion)
        iOS \(ProcessInfo().operatingSystemVersionString)
        User ID: \(User.current?.userId ?? "No user ID")
        Balance: \(Kin.shared.balance)
        Device ID: \(User.current?.deviceId ?? "No device ID")
        Device Token: \(User.current?.deviceToken ?? "No device Token")
        """
    }

    private class func attachmentData() -> Data {
        return attachmentString().data(using: .utf8) ?? Data()
    }
}

extension KinSupportViewController: MFMailComposeViewControllerDelegate {
    func mailComposeController(_ controller: MFMailComposeViewController,
                               didFinishWith result: MFMailComposeResult,
                               error: Error?) {
        dismiss(animated: true)

        if result == .sent {
            Events.Business.SupportRequestSent().send()
        }
    }
}
