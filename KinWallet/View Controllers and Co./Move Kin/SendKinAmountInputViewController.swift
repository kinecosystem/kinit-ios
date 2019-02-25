//
//  SendKinAmountInputViewController.swift
//  KinWallet
//
//  Copyright © 2019 KinFoundation. All rights reserved.
//

import UIKit
import KinUtil
import MoveKin

class SendKinAmountInputViewController: UIViewController {
    var amountSelectionBlock: ((UInt) -> Void)?
    var cancelBlock: (() -> Void)?
    let linkBag = LinkBag()
    var appName: String!
    var appIconURL: URL!
    var sendKinButtonEnabled = Observable(false)

    @IBOutlet weak var amountTextField: UITextField!
    @IBOutlet weak var appNameLabel: UILabel!
    @IBOutlet weak var currentBalanceLabel: UILabel!

    @IBOutlet weak var toLabel: UILabel! {
        didSet {
            toLabel.text = L10n.sendTo
        }
    }

    var amount: UInt {
        return UInt(amountLabel.text ?? "0") ?? 0
    }

    @IBOutlet weak var sendKinButton: UIButton! {
        didSet {
            sendKinButton.titleLabel?.font = FontFamily.Roboto.regular.font(size: 18)
        }
    }

    @IBOutlet weak var sendKinContainerView: UIView! {
        didSet {
            sendKinContainerView.applyThinShadow()
        }
    }

    @IBOutlet weak var separatorView: UIView! {
        didSet {
            separatorView.backgroundColor = UIColor.kin.lightGray
        }
    }

    @IBOutlet weak var amountLabel: UILabel! {
        didSet {
            amountLabel.textColor = UIColor.kin.blue
        }
    }

    @IBOutlet weak var kLabel: UILabel! {
        didSet {
            kLabel.font = FontFamily.KinK.regular.font(size: 16)
            kLabel.textColor = UIColor.kin.blue
        }
    }

    @IBOutlet weak var appIconImageView: UIImageView! {
        didSet {
            appIconImageView.layer.cornerRadius = 6
            appIconImageView.layer.masksToBounds = true
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.hidesBackButton = true
        let closeImage = Asset.closeXButtonDarkGray.image.withRenderingMode(.alwaysOriginal)
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: closeImage,
                                                           style: .plain,
                                                           target: self,
                                                           action: #selector(cancel))
        toLabel.textColor = UIColor.kin.gray
        appNameLabel.textColor = UIColor.kin.gray
        currentBalanceLabel.textColor = UIColor.kin.gray

        appNameLabel.text = appName
        appIconImageView.loadImage(url: appIconURL,
                                   placeholderColor: UIColor.kin.lightGray,
                                   useInMemoryCache: true)

        sendKinButtonEnabled.on(next: { [weak self] enabled in
            self?.sendKinButton.isEnabled = enabled
        }).add(to: linkBag)

        currentBalanceLabel.text = L10n.xKinAvailable(Int(Kin.shared.balance))
        amountTextField.text = "0"
        amountTextField.inputAccessoryView = sendKinContainerView
        amountTextField.becomeFirstResponder()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        navigationController?.setNavigationBarHidden(false, animated: animated)
    }

    @IBAction func sendKin(_ sender: Any) {
        let aAmount = amount
        guard aAmount <= Kin.shared.balance else {
            return
        }

        amountSelectionBlock?(aAmount)
    }

    @objc func cancel() {
        cancelBlock?()
    }
}

extension SendKinAmountInputViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField,
                   shouldChangeCharactersIn range: NSRange,
                   replacementString string: String) -> Bool {
        let currentAmount = amount

        guard currentAmount < 1000000000 else {
            return false
        }

        defer {
            textField.text = " "
            sendKinButtonEnabled.next(amount > 0 && amount <= Kin.shared.balance)

            if amount > Kin.shared.balance {
                currentBalanceLabel.shake(times: 1, delta: 5)

                FeedbackGenerator.notifyWarningIfAvailable()
            }
        }

        guard
            let amountText = amountLabel.text,
            let currentText = textField.text else {
                return false
        }

        let newText = (currentText as NSString).replacingCharacters(in: range, with: string)

        if newText.count == 0 {
            //delete tapped
            if currentAmount == 0 {
                return false
            }

            if amountText.count == 1 {
                amountLabel.text = "0"
                return false
            }

            let indexEndOfText = amountText.index(amountText.endIndex, offsetBy: -1)
            amountLabel.text = String(amountText[..<indexEndOfText])
        } else if newText.count == 2 {
            guard
                string.count == 1,
                Int(string) != nil else {
                    return false
            }

            amountLabel.text = currentAmount == 0
                ? string
                : amountText.appending(string)
        }

        return false
    }
}

extension SendKinAmountInputViewController: MoveKinSelectAmountPage {
    func setupSelectAmountPage(cancelHandler: @escaping () -> Void, selectionHandler: @escaping (UInt) -> Void) {
        amountSelectionBlock = selectionHandler
        cancelBlock = cancelHandler
    }
}
