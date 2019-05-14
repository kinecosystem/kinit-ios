//
//  OneWalletActionViewController.swift
//  KinWallet
//
//  Copyright © 2019 KinFoundation. All rights reserved.
//

import UIKit
import MobileCoreServices
import KinSDK

private let walletLinkingTypeIdentifier = "org.kinecosystem.wallet-linking"

@objc(OneWalletActionViewController)

class OneWalletActionViewController: UIViewController {
    let confirmationViewController = UIStoryboard(name: "OneWalletExtension", bundle: nil)
        .instantiateViewController(withIdentifier: "OneWalletConfirmationViewController")
        as! OneWalletConfirmationViewController //swiftlint:disable:this force_cast

    var incomingAddress: String?
    var hostAppBundleId: String?
    var hostAppName: String?
    var promise: Promise<TransactionEnvelope>?

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .white

        confirmationViewController.delegate = self
        addAndFit(confirmationViewController)

        guard WalletLinker.isWalletAvailable() else {
            //TODO: warn the wallet wasn't created and return error
            return
        }

//        KLogDebug("Extension activated")

        (extensionContext?.inputItems.first as? NSExtensionItem)?
            .attachments?
            .first(where: { $0.hasItemConformingToTypeIdentifier(walletLinkingTypeIdentifier) })?
            .loadItem(forTypeIdentifier: walletLinkingTypeIdentifier, options: nil, completionHandler: { result, error in
                guard let dictionary = result as? [String: String] else {
                    //TODO: Handle error
                    return
                }

                self.incomingAddress = dictionary["address"]
                self.hostAppBundleId = dictionary["bundleId"]
                self.hostAppName = dictionary["appName"]

                //TODO: Activate button
            })
    }

    func cancel() {
        // Return any edited content to the host app.
        // This template doesn't do anything, so we just echo the passed in items.
        self.extensionContext!.completeRequest(returningItems: nil,
                                               completionHandler: nil)
    }

    func connect() {
        guard
            let address = incomingAddress,
            let bundleId = hostAppBundleId else {
            return
        }

        promise = WalletLinker.createLinkingAccountsTransaction(to: address, appBundleIdentifier: bundleId)
        promise!
            .then { [weak self] envelope in
                do {
                    let encodedEnvelope = try XDREncoder.encode(envelope).base64EncodedString()
                    let returnProvider = NSItemProvider(item: encodedEnvelope as NSSecureCoding?,
                                                        typeIdentifier: kUTTypeText as String)
                    let returnItem = NSExtensionItem()
                    returnItem.attachments = [returnProvider]
                    self?.extensionContext!.completeRequest(returningItems: [returnItem],
                                                           completionHandler: nil)
                } catch {
                    self?.linkingFailed(error: error)
                }
            }
            .error { [weak self] error in
                self?.linkingFailed(error: error)
        }
    }

    func linkingFailed(error: Error) {
        //TODO: handle error
        self.extensionContext!.completeRequest(returningItems: nil,
                                               completionHandler: nil)
    }
}

extension OneWalletActionViewController: OneWalletConfirmationDelegate {
    func oneWalletConfirmationDidCancel() {
        cancel()
    }

    func oneWalletConfirmationDidConfirm() {
        connect()
    }
}
