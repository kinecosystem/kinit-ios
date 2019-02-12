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
    static let feedbackSubmitted = "feedbackSubmitted"
}

final class HelpCenterViewController: WebViewController {
    enum Page: String {
        case faq = "https://s3.amazonaws.com/kinapp-static/faq2/index.html"
        case feedback = "https://s3.amazonaws.com/kinapp-static/faq2/support/feedback.html"
        case support = "https://s3.amazonaws.com/kinapp-static/faq2/support/contact-us.html"
    }
    enum Category: String {
        case backup_restore = "Backup %26 Restore your Kin"
        case other = "Other"
    }

    enum SubCategory: String {
        case other = "Other"
        case onboarding = "On-boarding error"
    }

    private let activityIndicatorView = UIActivityIndicatorView(style: .white)
    private var errorCount = 0
    private var pageURL = URL(string: Page.faq.rawValue)!

    func setPageToLoad(page: Page) {
        pageURL = URL(string: page.rawValue)!
    }

    func setPageToLoad(page: Page, category: Category, subCategory: SubCategory) {
        let urlString = "\(page.rawValue)?category=\(category)&subCategory=\(subCategory)"
        pageURL = URL(string: urlString)!
    }

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
        controller.add(handler, name: MessageNames.feedbackSubmitted)
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
        loadURL(pageURL)
    }

    fileprivate func presentErrorAlert() {
        let title = errorCount > 0 ? L10n.SupportSubmitError.AfterRetry.title : L10n.SupportSubmitError.title
        let message = errorCount > 0 ? L10n.SupportSubmitError.title : L10n.SupportSubmitError.message

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
        let isDebug: String
        #if DEBUG
            isDebug = "true"
        #else
            isDebug = "false"
        #endif

        let jsToRun = """
            window.setMiscFormData(\(toJS(str: userId)),\
                                   \(toJS(str: platform)),\
                                   \(toJS(str: Bundle.appVersion)),
                                   \(toJS(str: isDebug)));
        """
        webView.evaluateJavaScript(jsToRun)
    }

    private func toJS(str: String) -> String {
        return "\"\(str)\""
    }
}

extension HelpCenterViewController: KinNavigationControllerDelegate {
    func shouldPopViewController() -> Bool {
        if webView.canGoBack && webView.url != pageURL {
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
        case MessageNames.feedbackSubmitted:
            feedbackSubmitted(body: body)
        default:
            break
        }
    }

    private func handleSubmissionError(body: [String: Any]) {
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

    private func feedbackSubmitted(body: [String: Any]) {
        Events.Analytics.ClickSubmitButtonOnFeedbackForm().send()
    }

    private func feedbackFormSent(body: [String: Any]) {
        Events.Business.FeedbackformSent().send()
    }
}
