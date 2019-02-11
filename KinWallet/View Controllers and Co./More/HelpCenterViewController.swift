//
//  HelpCenterViewController.swift
//  Kinit
//

import UIKit
import WebKit

private struct FAQKeys {
    static let category = "faqCategory"
    static let subCategory = "faqSubCategory"
}

private struct MessageNames {
    static let contactSupport = "contactSupport"
    static let supportSubmitted = "supportSubmitted"
    static let supportRequestSent = "supportRequestSent"
    static let showSubmissionError = "showSubmissionError"
    static let pageLoaded = "pageLoaded"
    static let isPageHelpfulSelection = "isPageHelpfulSelection"
    static let formPageLoaded = "formPageLoaded"
}

final class HelpCenterViewController: WebViewController {
    private let helpCenterURL = URL(string: "https://s3.amazonaws.com/kinapp-static/faq2/index.html")!

    private let activityIndicatorView = UIActivityIndicatorView(style: .white)
    private var errorCount = 0

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: activityIndicatorView)

        title = L10n.iNeedHelp

        loadMainPage()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        navigationController?.setNavigationBarHidden(false, animated: animated)
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    override func setupUserContentController(_ controller: WKUserContentController) {
        let handler = HelpCenterWebViewHandler(helpCenterViewController: self)
        controller.add(handler, name: MessageNames.contactSupport)
        controller.add(handler, name: MessageNames.isPageHelpfulSelection)
        controller.add(handler, name: MessageNames.pageLoaded)
        controller.add(handler, name: MessageNames.supportSubmitted)
        controller.add(handler, name: MessageNames.supportRequestSent)
        controller.add(handler, name: MessageNames.showSubmissionError)
        controller.add(handler, name: MessageNames.formPageLoaded)
    }

    override func loadingStateChanged(_ isLoading: Bool) {
        super.loadingStateChanged(isLoading)

        if isLoading {
            activityIndicatorView.startAnimating()
        } else {
            activityIndicatorView.stopAnimating()
        }
    }

    fileprivate func loadMainPage() {
        loadURL(helpCenterURL)
    }

    fileprivate func presentErrorAlert() {
        var title = L10n.SupportSubmitError.title
        var message = L10n.SupportSubmitError.message
        if errorCount > 0 {
            title = L10n.SupportSubmitError.AfterRetry.title
            message = L10n.SupportSubmitError.AfterRetry.message
        }

        let alertController = UIAlertController(title: title,
                                                message: message,
                                                preferredStyle: .alert)
        if errorCount == 0 {
            alertController.addAction(title: L10n.SupportSubmitError.retry, style: .default) {
              self.webView.evaluateJavaScript("submitForm();")
            }
        }
        alertController.addOkAction()
        present(alertController, animated: true)
        errorCount += 1
    }

    fileprivate func onFormPageLoaded() {
        let userId = User.current?.userId ?? "No user ID"
        let platform = "\(UIDevice.current.model) \(ProcessInfo().operatingSystemVersionString)"
        var debug = "false"
        #if DEBUG
            debug = "true"
        #endif

        let jsToRun = "window.setMiscFormData(\(toJS(str: userId)),\(toJS(str: platform)),\(toJS(str: Bundle.appVersion)),\(toJS(str: debug)));"

        print(jsToRun)
        webView.evaluateJavaScript(jsToRun)
    }

    private func toJS(str: String) -> String {
        return "\"\(str)\""
    }
}

extension HelpCenterViewController: KinNavigationControllerDelegate {
    func shouldPopViewController() -> Bool {
        if webView.canGoBack && webView.url != helpCenterURL {
            loadMainPage()
            return false
        }

        return true
    }
}

private class HelpCenterWebViewHandler: NSObject, WKScriptMessageHandler {

    weak var helpCenterViewController: HelpCenterViewController?

    init(helpCenterViewController: HelpCenterViewController) {
        self.helpCenterViewController = helpCenterViewController
    }

    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        guard
            let body = message.body as? [String: Any] else {
                return
        }

        switch message.name {
        case MessageNames.showSubmissionError:
            handleSubmissionError(body: body)
        case MessageNames.contactSupport:
            contactSupportClicked(body: body)
        case MessageNames.isPageHelpfulSelection:
            isPageHelpfulSelection(body: body)
        case MessageNames.pageLoaded:
            pageLoaded(body: body)
        case MessageNames.supportSubmitted:
            supportSubmitted(body: body)
        case MessageNames.supportRequestSent:
            supportRequestSent(body: body)
        case MessageNames.formPageLoaded:
            formPageLoaded(body: body)
        default:
            break
        }
    }

    private func handleSubmissionError(body: [String: Any]) {
        guard
            let data = body["data"] as? String,
            let errors = body["error"] as? String else {
                return
        }
        print("Data: \(data), Error: \(errors)")
        helpCenterViewController?.presentErrorAlert()
    }

    private func contactSupportClicked(body: [String: Any]) {
        guard
            let category = body[FAQKeys.category] as? String,
            let subCategory = body[FAQKeys.subCategory] as? String else {
                return
        }
        Events.Analytics
            .ClickContactButtonOnSpecificFaqPage(faqCategory: category, faqSubcategory: subCategory)
            .send()
    }

    private func pageLoaded(body: [String: Any]) {
        guard
            let category = body[FAQKeys.category] as? String,
            let subCategory = body[FAQKeys.subCategory] as? String else {
                return
        }
        if category == "FAQ" {
            Events.Analytics.ViewFaqMainPage().send()
        } else {
            Events.Analytics
                .ViewFaqPage(faqCategory: category, faqSubcategory: subCategory)
                .send()
        }
    }

    private func isPageHelpfulSelection(body: [String: Any]) {
        guard
            let isHelpful = body["helpful"] as? Bool,
            let category = body[FAQKeys.category] as? String,
            let subCategory = body[FAQKeys.subCategory] as? String else {
                return
        }
        Events.Analytics
            .ClickPageHelpfulButtonOnFaqPage(faqCategory: category, faqSubcategory: subCategory, helpful: isHelpful)
            .send()
    }

    private func supportSubmitted(body: [String: Any]) {
        guard
            let category = body[FAQKeys.category] as? String,
            let subCategory = body[FAQKeys.subCategory] as? String else {
                return
        }
        Events.Analytics
            .ClickSubmitButtonOnSupportFormPage(faqCategory: category, faqSubcategory: subCategory)
            .send()
    }

    private func supportRequestSent(body: [String: Any]) {
        guard
            let category = body[FAQKeys.category] as? String,
            let subCategory = body[FAQKeys.subCategory] as? String else {
                return
        }
       Events.Business
        .SupportRequestSent(faqCategory: category, faqSubcategory: subCategory)
        .send()
    }

    private func formPageLoaded(body: [String: Any]) {
        helpCenterViewController?.onFormPageLoaded()
    }
}
