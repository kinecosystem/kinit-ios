//
//  TrueXViewController.swift
//  KinWallet
//
//  Copyright © 2018 KinFoundation. All rights reserved.
//

import UIKit

class TrueXViewController: WebViewController {
    var task: Task!
    var finished = false
    let configHash: String = {
        #if DEBUG
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

    private func loadActivity() {
        activityIndicatorView.startAnimating()
        let userId = User.current!.userId

        WebRequests.trueXActivity().withCompletion { [weak self] activity, _ in
            DispatchQueue.main.async {
                guard let `self` = self else {
                    return
                }

                self.activityIndicatorView.stopAnimating()

                guard let activity = activity else {
                    self.dismiss(animated: true, completion: nil)
                    return
                }

                let params: [String: Any] = ["activity": activity.toJSON(),
                                             "userId": userId,
                                             "configHash": self.configHash]
                KLogDebug(params["activity"]!)
                self.webView.bridge.post(action: "prepareAndShowActivity", parameters: params)
            }
            }.load(with: KinWebService.shared)
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
        KLogDebug("trueXActivityStarted")
    }

    private func trueXActivityClosed() {
        KLogDebug("trueXActivityClosed")
    }

    private func trueXActivityFinished() {
        KLogDebug("trueXActivityFinished")
        moveOn()
    }

    private func trueXActivityCredited() {
        KLogDebug("trueXActivityCredited")
    }

    private func moveOn() {
        guard !finished else {
            return
        }

        finished = true

        let taskCompleted = StoryboardScene.Earn.taskCompletedViewController.instantiate()
        taskCompleted.task = task
        navigationController?.pushViewController(taskCompleted, animated: true)
    }
}
