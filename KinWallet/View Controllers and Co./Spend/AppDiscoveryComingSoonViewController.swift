//
//  AppDiscoveryComingSoonViewController.swift
//  KinWallet
//
//  Copyright © 2018 KinFoundation. All rights reserved.
//

import UIKit
import WebKit

private let url = URL(string: "https://cdn.kinitapp.com/discovery/coming-soon-webpage/index.html")!
private let closePageMessageName = "pageClosed"

class AppDiscoveryComingSoonViewController: WebViewController {
    override func viewDidLoad() {
        super.viewDidLoad()

        loadURL(url)
    }

    override func setupUserContentController(_ controller: WKUserContentController) {
        controller.add(self, name: closePageMessageName)
    }

    func webView(_ webView: WKWebView,
                 decidePolicyFor navigationResponse: WKNavigationResponse,
                 decisionHandler: @escaping (WKNavigationResponsePolicy) -> Void) {
        guard let response = navigationResponse.response as? HTTPURLResponse else {
            decisionHandler(.cancel)
            return
        }

        if response.statusCode >= 200 && response.statusCode < 300 {
            decisionHandler(.allow)
        } else {
            decisionHandler(.cancel)
        }
    }

    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        dismissAnimated()
    }

    fileprivate func closeTapped() {
        dismissAnimated()
    }
}

extension AppDiscoveryComingSoonViewController: WKScriptMessageHandler {
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        guard message.name == closePageMessageName else {
            return
        }

        closeTapped()
    }
}
