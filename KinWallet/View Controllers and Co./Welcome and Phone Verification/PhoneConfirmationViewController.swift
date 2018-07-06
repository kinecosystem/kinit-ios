//
//  PhoneConfirmationViewController.swift
//  Kinit
//

import UIKit
import FirebaseAuth
import KinUtil

private var secondsCountDown: TimeInterval = 16

class PhoneConfirmationViewController: UIViewController {
    let isCodeLengthValid = Observable<Bool>(false)
    let linkBag = LinkBag()
    var smsArrivalTimer: Timer?
    var didAppearAtDate: Date!

    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!

    @IBOutlet weak var titleLabel: UILabel! {
        didSet {
            titleLabel.font = FontFamily.Roboto.medium.font(size: 22)
            titleLabel.textColor = UIColor.kin.appTint
        }
    }

    @IBOutlet weak var descriptionLabel: UILabel! {
        didSet {
            descriptionLabel.font = FontFamily.Roboto.regular.font(size: 16)
            descriptionLabel.textColor = UIColor.kin.gray
        }
    }

    @IBOutlet weak var countdownLabel: UILabel! {
        didSet {
            countdownLabel.font = FontFamily.Roboto.regular.font(size: 14)
            countdownLabel.textColor = UIColor.kin.lightGray
            countdownLabel.alpha = 0
        }
    }

    @IBOutlet weak var newCodeButton: UIButton! {
        didSet {
            newCodeButton.isHidden = true
            newCodeButton.titleLabel?.font = FontFamily.Roboto.regular.font(size: 14)
        }
    }

    @IBOutlet var textFields: [UITextField]!

    var verificationId: String!
    var phoneNumber: String!

    override func viewDidLoad() {
        super.viewDidLoad()

        descriptionLabel.text = "We have sent a verification code to \(phoneNumber!). Please type it below:"

        textFields.forEach {
            $0.text = " "
            $0.delegate = self
            $0.tintColor = .clear
            $0.textColor = UIColor.kin.gray
            $0.font = FontFamily.Roboto.medium.font(size: 20)
            $0.keyboardType = .numberPad
            $0.setBottomLine(with: UIColor.kin.appTint)
        }

        textFields.first?.becomeFirstResponder()

        isCodeLengthValid.on(next: { [weak self] isValid in
            if isValid {
                self?.verifyCode()
            }
        }).add(to: linkBag)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        navigationController?.setNavigationBarHidden(true, animated: animated)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        logViewedPage()
        didAppearAtDate = Date()
        smsArrivalTimer = Timer.scheduledTimer(timeInterval: 1,
                                               target: self,
                                               selector: #selector(updateCountdown),
                                               userInfo: nil,
                                               repeats: true)
        updateCountdown()
    }

    func verifyCode() {
        guard isCurrentCodeValid() else {
            return
        }

        let credential = PhoneAuthProvider.provider().credential(withVerificationID: verificationId,
                                                                 verificationCode: currentCode())
        activityIndicatorView.startAnimating()

        Auth.auth().signIn(with: credential) { [weak self] firebaseUser, error in
            guard let aSelf = self else {
                return
            }

            if error != nil {
                aSelf.validationFailed()
                return
            }

            aSelf.getFirebaseIdToken(for: firebaseUser!)
        }
    }

    func getFirebaseIdToken(for user: FirebaseAuth.User) {
        user.getIDTokenForcingRefresh(true) { [weak self] token, error in
            guard let aSelf = self else {
                return
            }

            if error != nil {
                aSelf.validationFailed()
                return
            }

            aSelf.updateServer(with: token!)
        }
    }

    func updateServer(with token: String) {
        WebRequests.updateUserIdToken(token, phoneNumber: phoneNumber.sha256()).withCompletion { [weak self] success, _ in
            guard let aSelf = self else {
                return
            }

            DispatchQueue.main.async {
                if !success.boolValue {
                    aSelf.validationFailed()
                    return
                }

                aSelf.validationSucceeded()
            }
        }.load(with: KinWebService.shared)
    }

    func validationFailed() {
        activityIndicatorView.stopAnimating()

        logVerificationError()
        FeedbackGenerator.notifyErrorIfAvailable()
        textFields.forEach {
            $0.text = ""
            $0.shake(delta: 20)
        }

        textFields.first?.becomeFirstResponder()
    }

    func validationSucceeded() {
        KinLoader.shared.deleteCachedAndFetchNextTask()

        activityIndicatorView.stopAnimating()

        var user = User.current!
        user.phoneNumber = phoneNumber
        user.save()

        smsArrivalTimer?.invalidate()
        smsArrivalTimer = nil

        let accountReady = StoryboardScene.Main.accountReadyViewController.instantiate()
        navigationController?.pushViewController(accountReady, animated: true)
    }

    @objc func updateCountdown() {
        let sinceDidAppear = Date().timeIntervalSince(didAppearAtDate)
        let countdown = Int(secondsCountDown - sinceDidAppear)
        if countdown > 0 {
            if countdownLabel.alpha == 0 {
                UIView.animate(withDuration: 0.2) { [weak self] in
                    self?.countdownLabel.alpha = 1
                }
            }

            countdownLabel.text = "The code should arrive in \(countdown)s."
        } else {
            smsArrivalTimer?.invalidate()
            smsArrivalTimer = nil

            UIView.animate(withDuration: 0.2) { [weak self] in
                self?.countdownLabel.isHidden = true
                self?.newCodeButton.isHidden = false
            }
        }
    }

    @IBAction func sendNewCode(_ sender: Any) {
        logRequestedNewCode()
        navigationController?.popViewController(animated: true)
    }

    func isCurrentCodeValid() -> Bool {
        return currentCode().count == 6
    }

    func currentCode() -> String {
        return textFields
            .compactMap { $0.text }
            .filter { $0 != " " }
            .joined()
    }
}

extension PhoneConfirmationViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField,
                   shouldChangeCharactersIn range: NSRange,
                   replacementString string: String) -> Bool {
        defer {
            isCodeLengthValid.next(isCurrentCodeValid())
        }

        guard let currentText = textField.text else {
            return false
        }

        let newText = (currentText as NSString).replacingCharacters(in: range, with: string)
        let pressedBackspaceAfterSingleSpaceSymbol = currentText == " "
            && newText == ""
            && range.location == 0
            && range.length == 1

        if pressedBackspaceAfterSingleSpaceSymbol {
            if let currentIndex = textFields.index(of: textField),
                currentIndex - 1 >= 0 {
                let previous = textFields[currentIndex - 1]
                previous.text = " "
                previous.becomeFirstResponder()
            }

            return false
        }

        if newText.isEmpty {
            textField.text = " "
        } else if newText.count == 1 {
            textField.text = newText
        } else if newText.count == 2 && newText.first! == " " {
            textField.text = string
        }

        if let currentIndex = textFields.index(of: textField),
            textFields.count > currentIndex + 1 {
            textFields[currentIndex + 1].becomeFirstResponder()
        }

        return false
    }
}

extension PhoneConfirmationViewController {
    fileprivate func logViewedPage() {
        Events.Analytics.ViewVerificationPage().send()
    }

    fileprivate func logVerificationError() {
        Events.Analytics.ViewErrorMessageOnVerificationPage().send()
    }

    fileprivate func logRequestedNewCode() {
        Events.Analytics.ClickNewCodeLinkOnVerificationPage(verificationCodeCount: 0).send()
    }
}
