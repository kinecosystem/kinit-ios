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
    private let helpCenterURL = URL(string: "https://cdn.kinitapp.com/faq/faq.html")!
    private let activityIndicatorView: UIActivityIndicatorView = {
        let aView = UIActivityIndicatorView(activityIndicatorStyle: .white)
        aView.hidesWhenStopped = true

        return aView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: activityIndicatorView)

        title = L10n.helpCenter
        let url = RemoteConfig.current?.faqUrl ?? helpCenterURL
        loadURL(url)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        navigationController?.setNavigationBarHidden(false, animated: animated)
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    override func setupUserContentController(_ controller: WKUserContentController) {
        controller.add(self, name: MessageNames.contactSupport)
    }

    private func contactSupport(category: String, pageTitle: String) {
        KinSupportViewController.presentSupport(from: self, faqCategory: category, faqTitle: pageTitle)
    }

    private func mainPageLoaded() {
        Events.Analytics.ViewFaqMainPage().send()
    }

    private func pageLoaded(category: String, pageTitle: String) {
        Events.Analytics
            .ViewFaqPage(faqCategory: category, faqTitle: pageTitle)
            .send()
    }

    private func isPageHelpfulSelection(category: String, pageTitle: String, isHelpful: Bool) {
        Events.Analytics
            .ClickPageHelpfulButtonOnFaqPage(faqCategory: category, faqTitle: pageTitle, helpful: isHelpful)
            .send()
    }

    override func loadingStateChanged(_ isLoading: Bool) {
        super.loadingStateChanged(isLoading)

        if isLoading {
            activityIndicatorView.startAnimating()
        } else {
            activityIndicatorView.stopAnimating()
        }
    }
}

extension HelpCenterViewController: WKScriptMessageHandler {
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        switch message.name {
        case MessageNames.contactSupport:
            contactSupport(category: "", pageTitle: "") //TODO: get category and page title
        case MessageNames.isPageHelpfulSelection:
            isPageHelpfulSelection(category: "", pageTitle: "", isHelpful: true)
        case MessageNames.pageLoaded:
            pageLoaded(category: "", pageTitle: "")
        default:
            break
        }
    }
}
