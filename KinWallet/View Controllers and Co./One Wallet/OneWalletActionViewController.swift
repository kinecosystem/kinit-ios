//
//  OneWalletActionViewController.swift
//  KinWallet
//
//  Copyright © 2019 KinFoundation. All rights reserved.
//

import UIKit
import MobileCoreServices
import KinSDK

private let walletLinkingSetupTypeIdentifier = "org.kinecosystem.kinit.wallet-linking-setup"

@objc(OneWalletActionViewController)

class OneWalletActionViewController: UIViewController {
    let confirmationViewController = StoryboardScene.Main.oneWalletConfirmationViewController.instantiate()

    var linkRequestPayload: KinWalletLinkRequestPayload!
    var promise: Promise<TransactionEnvelope>?
    var retryCount = 0
    var masterAddress: String!

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .white

        confirmationViewController.delegate = self
        confirmationViewController.setAgreeButtonHidden(true, animated: false)
        addAndFit(confirmationViewController)

        guard WalletLinker.isWalletAvailable() else {
            noAccountAvailable()
            return
        }

        guard WalletLinker.isAddressAllowedToLink(linkRequestPayload.publicAddress) else {
            self.addressesMatch()
            return
        }

        confirmationViewController.appName = linkRequestPayload.appName
        confirmationViewController.setAgreeButtonHidden(false, animated: true)
        startConnectPromise()
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }

    private func addressesMatch() {
        //TODO: Adjust
        presentAlert(title: "Wallets Are the Same",
                     message: "It seems that you're trying to link an account to itself") {
            self.complete(with: .addressesMatch)
        }
    }

    private func addressAlreadyLinked() {
        presentAlert(title: "Wallets Already Linked",
                     message: "It seems that you're trying to link an account that is already linked to Kinit") {
            self.complete(with: .addressAlreadyLinked)
        }
    }

    private func noAccountAvailable() {
        presentAlert(title: "No Account Yet",
                     message: "It seems that you haven't logged in to Kinit yet. Open Kinit to setup your account") {
                self.complete(with: .noAccount)
        }
    }

    private func handleDecodingError() {
        presentAlert(title: L10n.generalErrorTitle,
                     message: "The host app didn't provide Kinit with the correct data") {
                        self.complete(with: .decodingError)
        }
    }

    private func presentAlert(title: String, message: String, action: @escaping () -> Void) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(title: L10n.ok, handler: action)
        presentAnimated(alertController)
    }

    private func startConnectPromise(isRetrying: Bool = false) {
        guard let payload = linkRequestPayload else {
            complete(with: .decodingError)
            return
        }

        if isRetrying {
            retryCount += 1
        }

        let linkAccounts = WalletLinker.createLinkingAccountsTransaction(to: payload.publicAddress,
                                                                         appBundleIdentifier: payload.bundleId)
        masterAddress = linkAccounts.1
        let recipientAddress = payload.publicAddress

        let p = Promise<TransactionEnvelope>()
        promise = p
        linkAccounts.0.then { txEnv in
            guard let txBase64 = txEnv.asBase64String else {
                p.signal(TxSignatureError.encodingFailed)
                return
            }

            let transaction = WhitelistTransactionRequest(senderAddress: self.masterAddress!,
                                                          recipientAddress: recipientAddress,
                                                          transaction: txBase64)
            WebRequests.signLinkingTransaction(transaction)
                .withCompletion { result in
                    guard
                        let signedTxString = result.value,
                        let signedEnv = TransactionEnvelope.fromBase64String(string: signedTxString) else {
                            p.signal(result.error ?? TxSignatureError.decodingFailed)
                            return
                    }

                    p.signal(signedEnv)
                }.load(with: KinWebService.shared)
        }
    }

    private func connect() {
        if promise == nil {
            startConnectPromise(isRetrying: true)
        }

        guard
            let promise = promise,
            let masterAddress = masterAddress else {
            return
        }

        confirmationViewController.isLoading = true
        confirmationViewController.setErrorMessage(nil)
        confirmationViewController.setAgreeButtonEnabled(false)
        promise
            .then { [weak self] envelope in
                do {
                    let encodedEnvelope = try XDREncoder.encode(envelope).base64EncodedString()
                    DispatchQueue.main.async {
                        self?.complete(with: .success(encodedEnvelope, masterAddress))
                    }
                } catch {
                    DispatchQueue.main.async {
                        self?.linkingFailed(error: error, isEncodingError: true)
                    }
                }
            }
            .error { [weak self] error in
                DispatchQueue.main.async {
                    self?.linkingFailed(error: error, isEncodingError: false)
                }
        }
    }

    private func linkingFailed(error: Error, isEncodingError: Bool) {
        promise = nil
        let shouldEnableAgreeButton: Bool
        confirmationViewController.isLoading = false

        let isMissingSequenceError: Bool

        if case KinSDK.StellarError.missingSequence = error {
            isMissingSequenceError = true
        } else {
            isMissingSequenceError = false
        }

        if case KinSDK.StellarError.missingAccount = error {
            shouldEnableAgreeButton = false
            noAccountAvailable()
        } else if isMissingSequenceError || error.isInternetError {
            shouldEnableAgreeButton = true
            confirmationViewController.setErrorMessage(L10n.OneWallet.ConnectScreen.internetError)
        } else {
            shouldEnableAgreeButton = !isEncodingError
            let errorMessage = shouldEnableAgreeButton
                ? L10n.OneWallet.ConnectScreen.genericErrorTryAgain
                : L10n.OneWallet.ConnectScreen.genericErrorClose
            confirmationViewController.setErrorMessage(errorMessage)
        }

        confirmationViewController.setAgreeButtonEnabled(shouldEnableAgreeButton)
    }

    private func complete(with result: OneWalletLinkResult) {
        confirmationViewController.isLoading = false

        defer {
            dismissAnimated()
        }

        guard
            let data = try? JSONEncoder().encode(result),
            let jsonString = String(data: data, encoding: .utf8),
            let payload = jsonString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
            let url = URL(string: "\(linkRequestPayload.urlScheme)://kin-wallet-link/result?payload=\(payload)") else {
                if let fallbackURL = URL(string: linkRequestPayload.urlScheme + "://") {
                    UIApplication.shared.open(fallbackURL)
                }

                return
        }

        UIApplication.shared.open(url)
    }
}

extension OneWalletActionViewController: OneWalletConfirmationDelegate {
    func oneWalletConfirmationDidCancel() {
        complete(with: .cancelled)
    }

    func oneWalletConfirmationDidConfirm() {
        connect()
    }
}
