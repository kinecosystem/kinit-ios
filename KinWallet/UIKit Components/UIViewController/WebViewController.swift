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
    var webView: WKWebView!
    var isLoadingObservationToken: NSKeyValueObservation?

    let activityIndicatorView: UIActivityIndicatorView = {
        let a = UIActivityIndicatorView(style: .gray)
        a.hidesWhenStopped = true

        return a
    }()

    deinit {
        isLoadingObservationToken?.invalidate()
    }

    init() {
        super.init(nibName: nil, bundle: nil)

        let viewportScript = WKUserScript(source: viewportScriptString,
                                          injectionTime: .atDocumentEnd,
                                          forMainFrameOnly: true)

        let controller = WKUserContentController()
        controller.addUserScript(viewportScript)
        self.setupUserContentController(controller)

        let config = WKWebViewConfiguration()
        self.setupWebViewConfiguration(config)
        config.userContentController = controller

        webView = WKWebView(frame: .zero, configuration: config)
        isLoadingObservationToken = webView.observe(\WKWebView.isLoading, options: .new) { [weak self] _, value in
            guard let isLoading = value.newValue else {
                return
            }

            self?.loadingStateChanged(isLoading)
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .white
        view.addAndFit(webView, layoutReference: .safeArea)
    }

    func setupUserContentController(_ controller: WKUserContentController) {

    }

    func setupWebViewConfiguration(_ configuration: WKWebViewConfiguration) {

    }

    func loadingStateChanged(_ isLoading: Bool) {

    }

    func loadURL(_ url: URL) {
        webView.load(URLRequest(url: url))
    }

    func loadHTMLString(_ string: String, baseURL: URL?) {
        webView.loadHTMLString(string, baseURL: baseURL)
    }
}
