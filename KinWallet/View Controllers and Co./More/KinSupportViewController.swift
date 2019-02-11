//
//  KinSupportViewController.swift
//  Kinit
//

import UIKit
import MessageUI

private let emailDomain = "@kinitapp.com"

enum EmailClient {
    case gmail
    case inbox
    case spark
    case outlook
}

extension EmailClient {
    static var allCases: [EmailClient] = [.gmail, .inbox, .spark, .outlook]

    var urlSchemeHost: String {
        switch self {
        case .gmail: return "googlegmail"
        case .inbox: return "inbox-gmail"
        case .outlook: return "ms-outlook"
        case .spark: return "readdle-spark"
        }
    }

    var urlScheme: String {
        return urlSchemeHost + "://"
    }

    var composePath: String {
        switch self {
        case .gmail, .inbox: return "co"
        case .outlook, .spark: return "compose"
        }
    }

    var schemeRecipientString: String {
        switch self {
        case .gmail, .inbox, .outlook: return "to"
        case .spark: return "recipient"
        }
    }

    func composeURLString(to recipient: String, subject: String, body: String) -> String {
        let encodedSubject = subject.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed).orEmpty
        let encodedBody = body.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed).orEmpty

        return urlScheme
            + composePath + "?"
            + schemeRecipientString + "="
            + recipient + "&"
            + "subject="
            + encodedSubject + "&"
            + "body="
            + encodedBody
    }
}

enum ContactOption: String {
    case feedback
    case support
}

extension ContactOption {
    var emailAddress: String {
        return rawValue + emailDomain
    }

    var emailSubject: String {
        switch self {
        case .support: return L10n.supportEmailSubject
        case .feedback: return L10n.feedbackEmailSubject
        }
    }

    var emailBody: String {
        switch self {
        case .support: return KinSupportViewController.attachmentString()
        case .feedback: return L10n.feedbackEmailBody(Bundle.appVersion)
        }
    }
}

final class KinSupportViewController: MFMailComposeViewController {
    let option: ContactOption

    init(option: ContactOption) {
        self.option = option

        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    class func presentFeedback(from presenter: UIViewController) {
        Events.Analytics.ClickFeedbackButton().send()
        present(.feedback, from: presenter)
    }

    class func presentSupport(from presenter: UIViewController, faqCategory: String = "", faqSubcategory: String = "") {
        Events.Analytics
            .ClickSupportButton(faqCategory: faqCategory, faqSubcategory: faqSubcategory)
            .send()
        present(.support, from: presenter)
    }

    private class func present(_ option: ContactOption, from presenter: UIViewController) {
        let recipient = option.emailAddress
        let subject = option.emailSubject

        guard MFMailComposeViewController.canSendMail() else {
            mailNotConfigured(option: option, recipient: recipient, subject: subject, from: presenter)

            return
        }

        let mailController = KinSupportViewController(option: option)
        mailController.setToRecipients([recipient])
        mailController.setSubject(subject)

        if option == .feedback {
            mailController.setMessageBody(option.emailBody, isHTML: false)
        }

        mailController.addAttachmentData(attachmentData(),
                                         mimeType: "txt",
                                         fileName: "Info.txt")
      //  mailController.mailComposeDelegate = mailController
        presenter.present(mailController, animated: true)
    }

    private class func mailNotConfigured(option: ContactOption,
                                         recipient: String,
                                         subject: String,
                                         from presenter: UIViewController) {
        let body = option.emailBody

        var foundMailClient = false
        for mailClient in EmailClient.allCases {
            if let clientURL = URL(string: mailClient.urlScheme),
                UIApplication.shared.canOpenURL(clientURL),
                let composeURL = mailClient.composeURLString(to: recipient, subject: subject, body: body).toURL() {
                foundMailClient = true

                if #available(iOS 10.0, *) {
                    UIApplication.shared.open(composeURL)
                } else {
                    UIApplication.shared.openURL(composeURL)
                }

                break
            }
        }

        if !foundMailClient {
            let alertController = UIAlertController(title: L10n.mailNotConfiguredTitle,
                                                    message: L10n.mailNotConfiguredMessage(recipient),
                                                    preferredStyle: .alert)
            alertController.addAction(title: L10n.mailNotConfiguredCopyInformation, style: .default) {
                UIPasteboard.general.string = recipient + "\n\n" + body
            }

            presenter.present(alertController, animated: true)
        }
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    override var childForStatusBarStyle: UIViewController? {
        return nil
    }

    fileprivate class func attachmentString() -> String {
        return """
        App Version: \(Bundle.appVersion)
        iOS \(ProcessInfo().operatingSystemVersionString)
        User ID: \(User.current?.userId ?? "No user ID")
        """
    }

    private class func attachmentData() -> Data {
        return attachmentString().data(using: .utf8) ?? Data()
    }
}

