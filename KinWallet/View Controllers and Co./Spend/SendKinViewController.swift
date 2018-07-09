//
//  SendKinViewController.swift
//  Kinit
//

import UIKit
import KinUtil

class SendKinViewController: UIViewController {
    let linkBag = LinkBag()
    var phoneNumber: String!
    var contactName: String!
    var publicAddress: String!
    var contactImage: UIImage!
    var sendKinButtonEnabled = Observable(false)

    @IBOutlet weak var amountTextField: UITextField!
    @IBOutlet weak var contactNameLabel: UILabel!
    @IBOutlet weak var toLabel: UILabel!
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!

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

    @IBOutlet weak var contactImageView: UIImageView! {
        didSet {
            contactImageView.layer.cornerRadius = contactImageView.frame.height/2.0
            contactImageView.layer.masksToBounds = true
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        toLabel.textColor = UIColor.kin.gray
        contactNameLabel.textColor = UIColor.kin.gray

        sendKinButtonEnabled.on(next: { [weak self] enabled in
            self?.sendKinButton.isEnabled = enabled
        }).add(to: linkBag)

        reloadContact()
        amountTextField.text = "0"
        amountTextField.inputAccessoryView = sendKinContainerView
        amountTextField.becomeFirstResponder()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        Events.Analytics.ViewSendKinPage().send()
    }

    private func reloadContact() {
        contactNameLabel.text = contactName
        contactImageView.image = contactImage
    }

    @IBAction func sendKin(_ sender: Any) {
        guard !isSendingKin else {
            return
        }

        let aAmount = UInt64(amount)

        Events.Analytics
            .ClickSendButtonOnSendKinPage(kinAmount: Float(amount))
            .send()

        let currentBalance = Kin.shared.balance

        if let minKin = RemoteConfig.current?.peerToPeerMinKin, aAmount < minKin {
            alertAmount(higher: false, minOrMaxKin: minKin)
            return
        }

        if let maxKin = RemoteConfig.current?.peerToPeerMaxKin, aAmount > maxKin {
            alertAmount(higher: true, minOrMaxKin: maxKin)
            return
        }

        if aAmount > currentBalance {
            alertBalanceTooLow(minBalance: aAmount)
            return
        }

        isSendingKin = true
        Kin.shared.send(aAmount, to: publicAddress) { [weak self] txId, error in
            guard let txId = txId else {
                KLogWarn("Transaction failed in Kin step: \(error?.localizedDescription ?? "No description")")
                self?.alertTransactionFailed()
                Events.Business
                    .KINTransactionFailed(failureReason: error?.localizedDescription ?? "No reason",
                                          kinAmount: Float(aAmount),
                                          transactionType: .p2p)
                    .send()

                return
            }

            KLogVerbose("Transaction succeeded, will report to server")

            //delay sending the event a little bit, to make sure balance is updated
            DispatchQueue.global().asyncAfter(deadline: .now() + 2, execute: {
                Events.Business
                    .KINTransactionSucceeded(kinAmount: Float(aAmount),
                                             transactionId: txId,
                                             transactionType: .p2p)
                    .send()
            })

            self?.reportKinSent(amount: aAmount, txId: txId)
        }
    }

    private func reportKinSent(amount: UInt64, txId: String) {
        WebRequests.reportTransaction(with: txId, amount: amount, to: publicAddress)
            .withCompletion { [weak self] success, _ in
                guard let success = success, success else {
                    KLogWarn("Transaction failed to be reported to server")
                    self?.alertTransactionFailed()
                    return
                }

                DispatchQueue.main.async {
                    self?.navigationController?.delegate = self
                    let screenshot = UIApplication.shared.fullscreenshot
                    self?.isSendingKin = false
                    let sentViewController = StoryboardScene.Spend.kinSentViewController.instantiate()
                    sentViewController.amount = amount
                    sentViewController.sendKinScreenshot = screenshot
                    self?.navigationController?.pushViewController(sentViewController, animated: true)
                }
            }.load(with: KinWebService.shared)
    }

    private func alertAmount(higher: Bool, minOrMaxKin: UInt) {
        let title = higher
            ? "That's Very Kind"
            : "How About a Bit More Love?"
        let message = higher
            ? "You can only send \(minOrMaxKin) KIN at a time."
            : "Please send at least \(minOrMaxKin) KIN."
        alert(title: title, message: message)

        Events.Analytics
            .ViewErrorPopupOnSendKinPage(errorType: .exceedMaxOrMinKin)
            .send()
    }

    private func alertBalanceTooLow(minBalance: UInt64) {
        let title = "Looks Like Your Balance Is a Bit Low"
        let message = "Make sure you have at least \(minBalance) KIN."
        alert(title: title, message: message)

        Events.Analytics
            .ViewErrorPopupOnSendKinPage(errorType: .exceedExistingKin)
            .send()
    }

    private func alertTransactionFailed() {
        let title = "Houston We Have a Server Problem"
        let message = "Please try again later. If you continue to see this message, please reach out to support."
        alert(title: title, message: message)
    }

    private func alert(title: String?, message: String?) {
        DispatchQueue.main.async {
            if self.isSendingKin {
                self.isSendingKin = false
            }

            let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
            alertController.addAction(.ok())
            self.present(alertController, animated: true)
        }
    }

    fileprivate var isSendingKin: Bool = false {
        didSet {
            let buttonTitle = isSendingKin
                ? "Sending Kin"
                : "Send Kin"
            let buttonTintColor = isSendingKin
                ? UIColor.white
                : UIColor.kin.appTint
            let backgroundColor = isSendingKin
                ? UIColor.kin.blue
                : UIColor.white
            sendKinButton.setTitle(buttonTitle, for: .normal)
            sendKinButton.tintColor = buttonTintColor

            if isSendingKin {
                activityIndicatorView.startAnimating()
            } else {
                activityIndicatorView.stopAnimating()
            }

            UIView.animate(withDuration: 0.25) {
                self.sendKinContainerView.backgroundColor = backgroundColor
            }

            navigationController?.interactivePopGestureRecognizer?.isEnabled = !isSendingKin
            navigationController?.navigationBar.isUserInteractionEnabled = !isSendingKin
            sendKinContainerView.isUserInteractionEnabled = !isSendingKin
        }
    }
}

extension SendKinViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField,
                   shouldChangeCharactersIn range: NSRange,
                   replacementString string: String) -> Bool {
        let currentAmount = amount

        guard !isSendingKin else {
            return false
        }

        guard currentAmount < 1000000000 else {
            return false
        }

        defer {
            textField.text = " "
            sendKinButtonEnabled.next(amount > 0)
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

extension SendKinViewController: UINavigationControllerDelegate {
    func navigationController(_ navigationController: UINavigationController,
                              animationControllerFor operation: UINavigationControllerOperation,
                              from fromVC: UIViewController,
                              to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return AlphaAnimatedTransitioning()
    }
}
