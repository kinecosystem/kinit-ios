//
//  SendKinViewController.swift
//  KinWallet
//
//  Copyright © 2018 KinFoundation. All rights reserved.
//

import UIKit

class SendKinViewController: UIViewController {
    var phoneNumber: String!
    var contactName: String!
    var publicAddress: String!
    var contactImage: UIImage!

    var amount: UInt {
        return UInt(amountTextField.text ?? "0") ?? 0
    }

    @IBOutlet weak var amountTextField: UITextField! {
        didSet {
            amountTextField.textColor = UIColor.kin.blue
        }
    }

    @IBOutlet weak var contactNameLabel: UILabel!
    @IBOutlet weak var contactImageView: UIImageView! {
        didSet {
            contactImageView.layer.cornerRadius = contactImageView.frame.height/2.0
            contactImageView.layer.masksToBounds = true
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        reloadContact()
        amountTextField.becomeFirstResponder()
    }

    func reloadContact() {
        contactNameLabel.text = contactName
        contactImageView.image = contactImage
    }

    @IBAction func sendKin(_ sender: Any) {
        let aAmount = UInt64(amount)
        Kin.shared.send(aAmount, to: publicAddress) { [weak self] txId, _ in
            guard let txId = txId else {
                KLogDebug("Transaction failed")
                return
            }

            KLogDebug("Transaction succeeded, will report to server")
            self?.reportKinSent(amount: aAmount, txId: txId)
        }
    }

    func reportKinSent(amount: UInt64, txId: String) {
        WebRequests.reportTransaction(with: txId, amount: amount, to: publicAddress)
            .withCompletion { [weak self] success, _ in
                guard let success = success, success else {
                    KLogDebug("Failed to report transaction to server")
                    return
                }

                DispatchQueue.main.async {
                    let sentViewController = StoryboardScene.Spend.kinSentViewController.instantiate()
                    sentViewController.amount = amount
                    self?.navigationController?.pushViewController(sentViewController, animated: true)
                }
            }.load(with: KinWebService.shared)
    }
}
