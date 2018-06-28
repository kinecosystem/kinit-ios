//
//  WebViewController.swift
//  KinWallet
//
//  Copyright © 2018 KinFoundation. All rights reserved.
//

import UIKit
import WebKit

//swiftlint:disable:next line_length
let viewportScriptString = "var meta = document.createElement('meta'); meta.setAttribute('name', 'viewport'); meta.setAttribute('content', 'width=device-width'); meta.setAttribute('initial-scale', '1.0'); meta.setAttribute('maximum-scale', '1.0'); meta.setAttribute('minimum-scale', '1.0'); meta.setAttribute('user-scalable', 'no'); document.getElementsByTagName('head')[0].appendChild(meta);"

class WebViewController: UIViewController {
    let webView: WKWebView = {
        let viewportScript = WKUserScript(source: viewportScriptString,
                                          injectionTime: .atDocumentEnd,
                                          forMainFrameOnly: true)

        let controller = WKUserContentController()
        controller.addUserScript(viewportScript)
        let config = WKWebViewConfiguration()
        config.userContentController = controller
        return WKWebView(frame: .zero, configuration: config)
    }()

    let activityIndicatorView: UIActivityIndicatorView = {
        let a = UIActivityIndicatorView(activityIndicatorStyle: .gray)
        a.hidesWhenStopped = true

        return a
    }()

    override func loadView() {
        self.view = webView
        webView.addAndCenter(activityIndicatorView)
    }
}
