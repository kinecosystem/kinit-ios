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

class OneWalletActionViewController: UIViewController {
    var incomingAddress: String?
    var hostAppBundleId: String?
    var hostAppName: String?
    var promise: Promise<TransactionEnvelope>?

    @IBOutlet weak var label: UILabel! {
        didSet {
            label.alpha = 0
        }
    }

    @IBOutlet weak var connectButton: UIButton! {
        didSet {
            connectButton.alpha = 0
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        guard WalletLinker.isWalletAvailable() else {
            //TODO: warn the wallet wasn't created and return error
            return
        }

        print("Extension activated")

        (extensionContext?.inputItems.first as? NSExtensionItem)?
            .attachments?
            .first(where: { $0.hasItemConformingToTypeIdentifier(walletLinkingTypeIdentifier) })?
            .loadItem(forTypeIdentifier: walletLinkingTypeIdentifier, options: nil, completionHandler: { result, error in
                guard let dictionary = result as? [String: String] else {
                    print(String(describing: result))
                    print("loaded item is not a dictionary")
                    return
                }

                self.incomingAddress = dictionary["address"]
                self.hostAppBundleId = dictionary["bundleId"]
                self.hostAppName = dictionary["appName"]

                let text = "Incoming address is \(self.incomingAddress ?? "meh")"
                DispatchQueue.main.async {
                    self.label.text = text
                    UIView.animate(withDuration: 0.3, animations: {
                        self.label.alpha = 1
                        self.connectButton.alpha = 1
                    })
                }
            })
    }

    @IBAction func cancel() {
        // Return any edited content to the host app.
        // This template doesn't do anything, so we just echo the passed in items.
        self.extensionContext!.completeRequest(returningItems: nil,
                                               completionHandler: nil)
    }

    @IBAction func connect(_ sender: Any) {
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
