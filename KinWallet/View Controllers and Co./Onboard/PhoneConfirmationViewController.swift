//
//  PhoneConfirmationViewController.swift
//  Kinit
//

import UIKit
import FirebaseAuth
import KinUtil

private var secondsCountDown: TimeInterval = 16

protocol PhoneConfirmationDelegate: class {
    func phoneConfirmationRequestedNewCode()
    func phoneConfirmationEnteredWrongCode()
}

class PhoneConfirmationViewController: UIViewController {
    weak var delegate: PhoneConfirmationDelegate?
    var allowContactingSupport = false {
        didSet {
            if allowContactingSupport {
                UIView.animate(withDuration: 0.2) { [weak self] in
                    self?.supportButton?.isHidden = false
                }
            }
        }
    }

    let isCodeLengthValid = Observable<Bool>(false)
    let linkBag = LinkBag()
    var smsArrivalTimer: Timer?
    var newCodeTimerInitialDate: Date?

    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!

    @IBOutlet weak var titleLabel: UILabel! {
        didSet {
            titleLabel.font = FontFamily.Roboto.medium.font(size: 22)
            titleLabel.textColor = UIColor.kin.appTint
            titleLabel.text = L10n.phoneConfirmationTitle
        }
    }

    @IBOutlet weak var descriptionLabel: UILabel! {
        didSet {
            descriptionLabel.font = FontFamily.Roboto.regular.font(size: 16)
            descriptionLabel.textColor = UIColor.kin.gray
            descriptionLabel.text = L10n.phoneConfirmationMessage
        }
    }

    @IBOutlet weak var countdownLabel: UILabel! {
        didSet {
            countdownLabel.font = FontFamily.Roboto.regular.font(size: 14)
            countdownLabel.textColor = UIColor.kin.lightGray
            countdownLabel.alpha = 0
        }
    }

    @IBOutlet weak var supportButton: UIButton! {
        didSet {
            supportButton.isHidden = !allowContactingSupport
            supportButton.titleLabel?.font = FontFamily.Roboto.regular.font(size: 14)
            supportButton.setTitle(L10n.contactSupport, for: .normal)
        }
    }

    @IBOutlet weak var newCodeButton: UIButton! {
        didSet {
            newCodeButton.isHidden = true
            newCodeButton.titleLabel?.font = FontFamily.Roboto.regular.font(size: 14)
            newCodeButton.setTitle(L10n.phoneConfirmationAskNewCode, for: .normal)
        }
    }

    @IBOutlet var textFields: [UITextField]!

    var verificationId: String!
    var phoneNumber: String!

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(assignFirstResponder),
                                               name: UIApplication.didBecomeActiveNotification,
                                               object: nil)

        descriptionLabel.text = L10n.phoneVerificationCodeSent(phoneNumber!)
        TestFairy.hide(descriptionLabel)

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

        textFields.forEach { $0.text = " " }
        textFields.first?.becomeFirstResponder()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        logViewedPage()

        if newCodeTimerInitialDate == nil {
            newCodeTimerInitialDate = Date()
        }

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
        WebRequests.updateUserIdToken(token).withCompletion { [weak self] hints, _ in
            guard let aSelf = self else {
                return
            }

            DispatchQueue.main.async {
                guard let hints = hints else {
                    aSelf.validationFailed()
                    return
                }

                aSelf.validationSucceeded(with: hints)
            }
        }.load(with: KinWebService.shared)
    }

    func validationFailed() {
        delegate?.phoneConfirmationEnteredWrongCode()
        activityIndicatorView.stopAnimating()

        logVerificationError()
        FeedbackGenerator.notifyErrorIfAvailable()
        textFields.forEach {
            $0.text = " "
            $0.shake(delta: 20)
        }

        textFields.first?.becomeFirstResponder()
    }

    func validationSucceeded(with hintIds: [Int]) {
        DataLoaders.tasks.loadAllData()

        activityIndicatorView.stopAnimating()

        var user = User.current!
        user.phoneNumber = phoneNumber
        user.save()

        smsArrivalTimer?.invalidate()
        smsArrivalTimer = nil

        AppDelegate.shared.rootViewController.phoneNumberValidated(with: hintIds)
    }

    @objc func assignFirstResponder() {
        textFields.first(where: { $0.text == " " })?.becomeFirstResponder()
    }

    @objc func updateCountdown() {
        guard let newCodeTimerInitialDate = newCodeTimerInitialDate else {
            return
        }

        let sinceDidAppear = Date().timeIntervalSince(newCodeTimerInitialDate)
        let countdown = Int(secondsCountDown - sinceDidAppear)
        if countdown > 0 {
            if countdownLabel.alpha == 0 {
                UIView.animate(withDuration: 0.2) { [weak self] in
                    self?.countdownLabel.alpha = 1
                }
            }

            countdownLabel.text = L10n.phoneConfirmationCountdown(countdown)
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
        delegate?.phoneConfirmationRequestedNewCode()
    }

    @IBAction func contactSupport(_ sender: Any) {
        KinSupportViewController.presentSupport(from: self)
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
