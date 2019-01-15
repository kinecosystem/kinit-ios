//
//  HelpCenterViewController.swift
//  Kinit
//

import UIKit
import WebKit

private struct MessageNames {
    static let contactSupport = "contactSupport"
    static let pageLoaded = "pageLoaded"
    static let isPageHelpfulSelection = "isPageHelpfulSelection"
}

final class HelpCenterViewController: WebViewController {
    private let fallbackHelpCenterURL = URL(string: "https://cdn.kinitapp.com/faq/index.html")!

    fileprivate lazy var helpCenterURL: URL = {
        return RemoteConfig.current?.faqUrl ?? fallbackHelpCenterURL
    }()

    private let activityIndicatorView = UIActivityIndicatorView(style: .white)

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: activityIndicatorView)

        title = L10n.helpCenter

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
    }

    fileprivate func contactSupport(category: String, subcategory: String) {
        KinSupportViewController.presentSupport(from: self, faqCategory: category, faqSubcategory: subcategory)
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
            let body = message.body as? [String: Any],
            let category = body["faqTitle"] as? String,
            let subcategory = body["faqCategory"] as? String else {
            return
        }

        switch message.name {
        case MessageNames.contactSupport:
            helpCenterViewController?.contactSupport(category: category, subcategory: subcategory)
        case MessageNames.isPageHelpfulSelection:
            if let isHelpful = body["helpful"] as? Bool {
                isPageHelpfulSelection(category: category, subcategory: subcategory, isHelpful: isHelpful)
            }
        case MessageNames.pageLoaded:
            if category == "Main Page" {
                mainPageLoaded()
            } else {
                pageLoaded(category: category, subcategory: subcategory)
            }
        default:
            break
        }
    }

    private func mainPageLoaded() {
        Events.Analytics.ViewFaqMainPage().send()
    }

    private func pageLoaded(category: String, subcategory: String) {
        Events.Analytics
            .ViewFaqPage(faqCategory: category, faqSubcategory: subcategory)
            .send()
    }

    private func isPageHelpfulSelection(category: String, subcategory: String, isHelpful: Bool) {
        Events.Analytics
            .ClickPageHelpfulButtonOnFaqPage(faqCategory: category, faqSubcategory: subcategory, helpful: isHelpful)
            .send()
    }
}
