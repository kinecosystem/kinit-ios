//
//  TrueXViewController.swift
//  KinWallet
//
//  Copyright © 2018 KinFoundation. All rights reserved.
//

import UIKit
import WebKit
import SafariServices

protocol TrueXViewControllerDelegate: class {
    func trueXLoadingDidFail()
}

class TrueXViewController: WebViewController {
    var task: Task!
    weak var delegate: TrueXViewControllerDelegate?
    var safariViewController: SFSafariViewController?

    var pushedTaskCompleted  = false
    var activityFinished = false

    let configHash: String = {
        #if DEBUG || RELEASE_STAGE
        return Configuration.shared.trueXConfigHashDebug!
        #else
        return Configuration.shared.trueXConfigHashProd!
        #endif
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        guard
            let fileURL = Bundle.main.url(forResource: "TrueXIndex", withExtension: "html"),
            let htmlData = try? Data(contentsOf: fileURL),
            let htmlString = String(data: htmlData, encoding: .utf8),
            let baseURL = URL(string: "https://serve.truex.com") else {
                fatalError("Couldn't load TruexIndex.html file from main bundle correctly.")
        }

        webView.loadHTMLString(htmlString, baseURL: baseURL)
        webView.bridge.printScriptMessageAutomatically = true
        webView.uiDelegate = self
        registerBridge()
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        navigationController?.setNavigationBarHidden(true, animated: animated)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        if activityFinished {
            moveOn()
        }
    }

    private func loadActivity() {
        activityIndicatorView.startAnimating()

        WebRequests.trueXActivity().withCompletion { [weak self] response, _ in
            DispatchQueue.main.async {
                guard let `self` = self else {
                    return
                }

                guard let response = response else {
                    self.activityIndicatorView.stopAnimating()
                    self.alertLoadingFailed()
                    return
                }

                let params: [String: Any] = ["activity": response.toJSON(),
                                             "userId": response.networkUserId,
                                             "configHash": self.configHash]
                KLogDebug(params["activity"]!)
                self.webView.bridge.post(action: "prepareAndShowActivity", parameters: params)
            }
            }.load(with: KinWebService.shared)
    }

    private func alertLoadingFailed() {
        let title = "Houston We Have a Problem"
        let message = "Please try again later. If you continue to see this message, please reach out to support."

        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(.ok(handler: { _ in
            self.delegate?.trueXLoadingDidFail()
        }))
        present(alertController, animated: true)
    }

    private func bridgeDidBecomeAvailable() {
        loadActivity()
    }

    private func registerBridge() {
        webView.bridge.register({ parameters, _ in
            KLogDebug("WebView: \(parameters?["message"] ?? "")")
        }, for: "print")

        webView.bridge.register({ [weak self] _, _ in
            guard let `self` = self else {
                return
            }
            self.bridgeDidBecomeAvailable()

            }, for: "bridgeAvailable")

        webView.bridge.register({ [weak self] _, _ in
            guard let `self` = self else { return }

            self.trueXActivityStarted()
            }, for: "trueXActivityStarted")

        webView.bridge.register({ [weak self] _, _ in
            guard let `self` = self else { return }

            self.trueXActivityFinished()
            }, for: "trueXActivityFinished")

        webView.bridge.register({ [weak self] _, _ in
            guard let `self` = self else { return }

            self.trueXActivityClosed()
            }, for: "trueXActivityClosed")

        webView.bridge.register({ [weak self] _, _ in
            guard let `self` = self else { return }

            self.trueXActivityCredited()
            }, for: "trueXActivityCredited")
    }

    private func trueXActivityStarted() {
        activityIndicatorView.stopAnimating()
        KLogVerbose("trueXActivityStarted")
    }

    private func trueXActivityClosed() {
        KLogVerbose("trueXActivityClosed")
    }

    private func trueXActivityFinished() {
        KLogVerbose("trueXActivityFinished")
        activityFinished = true
        moveOn()
    }

    private func trueXActivityCredited() {
        KLogVerbose("trueXActivityCredited")
    }

    private func moveOn() {
        guard !pushedTaskCompleted  else {
            return
        }

        pushedTaskCompleted  = true

        let taskCompleted = StoryboardScene.Earn.taskCompletedViewController.instantiate()
        taskCompleted.task = task
        navigationController?.pushViewController(taskCompleted, animated: true)
    }
}

extension TrueXViewController: WKUIDelegate {
    func webView(_ webView: WKWebView,
                 createWebViewWith configuration: WKWebViewConfiguration,
                 for navigationAction: WKNavigationAction,
                 windowFeatures: WKWindowFeatures) -> WKWebView? {
        guard let url = navigationAction.request.url else {
            return nil
        }

        KLogDebug("WebViewDelegate asking \(navigationAction.request.url?.absoluteString ?? "No URL") with \(navigationAction.navigationType)")

        safariViewController = SFSafariViewController(url: url)
        navigationController!.present(safariViewController!, animated: true)

        return nil
    }
}
