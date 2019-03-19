//
//  ActionViewController.swift
//  KinWallet
//
//  Copyright © 2019 KinFoundation. All rights reserved.
//

import UIKit
import MobileCoreServices
import KinCoreSDK
import StellarKit

//swiftlint:disable force_cast
//swiftlint:disable force_try

class ActionViewController: UIViewController {
    let kinClient = KinEnvironment.kinClient()
    var incomingAddress: String?

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

        print("Extension activated")
        print("Extension's public address is \(kinClient.accounts.last?.publicAddress ?? "No address")")

        (extensionContext?.inputItems.first as? NSExtensionItem)?
            .attachments?
            .first(where: { $0.hasItemConformingToTypeIdentifier(kUTTypeText as String) })?
            .loadItem(forTypeIdentifier: kUTTypeText as String, options: nil, completionHandler: { result, error in
                guard let address = result as? String else {
                    return
                }

                self.incomingAddress = address

                let text = "Incoming address is \(address)"
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
            let account = kinClient.accounts.last else {
            self.extensionContext!.completeRequest(returningItems: nil,
                                                   completionHandler: nil)
            return
        }

        account.linkingTransaction(publicKey: address)
            .then { envelope in
                let encodedEnvelope = try! XDREncoder.encode(envelope).base64EncodedString() as NSSecureCoding?
                print(encodedEnvelope!)

                let returnProvider = NSItemProvider(item: encodedEnvelope as NSSecureCoding?,
                                                    typeIdentifier: kUTTypeText as String)
                let returnItem = NSExtensionItem()
                returnItem.attachments = [returnProvider]
                self.extensionContext!.completeRequest(returningItems: [returnItem],
                                                       completionHandler: nil)
            }.error { error in
                self.extensionContext!.completeRequest(returningItems: nil,
                                                       completionHandler: nil)
        }
    }
}

//swiftlint:enable force_cast
//swiftlint:enable force_try
