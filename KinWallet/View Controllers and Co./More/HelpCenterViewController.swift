//
//  HelpCenterViewController.swift
//  Kinit
//

import UIKit
import WebKit

private let contactSupportMessageName = "contactSupport"

final class HelpCenterViewController: WebViewController {
    private let helpCenterURL = URL(string: "https://cdn.kinitapp.com/faq/faq.html")!

    override func setupUserContentController(_ controller: WKUserContentController) {
        controller.add(self, name: contactSupportMessageName)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

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
}

extension HelpCenterViewController: WKScriptMessageHandler {
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        guard message.name == contactSupportMessageName else {
            return
        }

        KinSupportViewController.present(.support, from: self)
    }
}
