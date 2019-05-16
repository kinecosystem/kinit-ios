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
    let confirmationViewController = UIStoryboard(name: "OneWalletExtension", bundle: nil)
        .instantiateViewController(withIdentifier: "OneWalletConfirmationViewController")
        as! OneWalletConfirmationViewController //swiftlint:disable:this force_cast

    var linkRequestPayload: KinWalletLinkRequestPayload?
    var promise: Promise<TransactionEnvelope>?
    var retryCount = 0

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

        confirmationViewController.isLoading = true

        guard let itemProvider = (extensionContext?.inputItems.first as? NSExtensionItem)?
            .attachments?
            .first(where: { $0.hasItemConformingToTypeIdentifier(walletLinkingTypeIdentifier) }) else {
                handleDecodingError()
                return
        }

        itemProvider.loadItem(forTypeIdentifier: walletLinkingTypeIdentifier, options: nil) { [weak self] result, _ in
            DispatchQueue.main.async {
                guard let self = self else {
                    return
                }
                self.confirmationViewController.isLoading = false

                guard let data = result as? Data,
                    let operationType = try? JSONDecoder().decode(KinitOneWalletOperationType.self, from: data) else {
                        self.handleDecodingError()
                        return
                }

                switch operationType {
                case .confirmSetup:
                    print("Confirm setup is not ready yet")
                case .link(let payload):
                    guard WalletLinker.isAddressAllowedToLink(payload.publicAddress) else {
                        self.addressesMatch()
                        return
                    }

                    self.linkRequestPayload = payload
                    self.confirmationViewController.setAgreeButtonHidden(false, animated: true)
                    self.startConnectPromise()
                }
            }
        }
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
            self.complete(with: .addressesMatch)
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

        promise = WalletLinker.createLinkingAccountsTransaction(to: payload.publicAddress,
                                                                appBundleIdentifier: payload.bundleId)
    }

    func connect() {
        if promise == nil {
            startConnectPromise(isRetrying: true)
        }

        guard let promise = promise else {
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
                        self?.complete(with: .success(encodedEnvelope))
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

    func linkingFailed(error: Error, isEncodingError: Bool) {
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

        guard let data = try? JSONEncoder().encode(result) else {
            extensionContext?.completeRequest(returningItems: nil, completionHandler: nil)
            return
        }

        let returnProvider = NSItemProvider(item: data as NSSecureCoding,
                                            typeIdentifier: walletLinkingResultTypeIdentifier)
        let returnItem = NSExtensionItem()
        returnItem.attachments = [returnProvider]
        extensionContext?.completeRequest(returningItems: [returnItem], completionHandler: nil)
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
