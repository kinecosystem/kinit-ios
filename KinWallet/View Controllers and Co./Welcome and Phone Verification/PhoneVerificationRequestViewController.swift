//
//  PhoneVerificationRequestViewController.swift
//  KinWallet
//
//  Copyright © 2018 KinFoundation. All rights reserved.
//

import UIKit
import FirebaseAuth
import libPhoneNumber_iOS
import KinUtil

class PhoneVerificationRequestViewController: UIViewController {
    fileprivate let accessoryView: ButtonAcessoryInputView = {
        let b = ButtonAcessoryInputView()
        b.title = "Next"
        b.translatesAutoresizingMaskIntoConstraints = false

        return b
    }()

    @IBOutlet weak var errorLabel: UILabel! {
        didSet {
            errorLabel.isHidden = true
            errorLabel.alpha = 0
            errorLabel.textColor = UIColor.kin.errorRed
            errorLabel.font = FontFamily.Roboto.regular.font(size: 14)
        }
    }

    let phoneNumberUtility = NBPhoneNumberUtil()
    let isPhoneNumberValid = Observable<Bool>(false)
    let linkBag = LinkBag()

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

    @IBOutlet weak var countryCodeTextField: UITextField! {
        didSet {
            countryCodeTextField.isUserInteractionEnabled = false
            countryCodeTextField.font = FontFamily.Roboto.regular.font(size: 16)
            countryCodeTextField.textColor = UIColor.kin.gray
            countryCodeTextField.setBottomLine(with: UIColor.kin.gray)
            let callingCode = NBPhoneNumberUtil().getCountryCode(forRegion: regionCode) ?? NSNumber(value: 1)
            countryCodeTextField.text = "+\(callingCode)"
        }
    }

    @IBOutlet weak var phoneTextField: UITextField! {
        didSet {
            phoneTextField.font = FontFamily.Roboto.regular.font(size: 16)
            phoneTextField.textColor = UIColor.kin.gray
            phoneTextField.setBottomLine(with: UIColor.kin.appTint)
        }
    }

    let regionCode: String = {
        let fromCarrier = NBPhoneNumberUtil().countryCodeByCarrier()

        guard let codeFromCarrier = fromCarrier, fromCarrier != NB_UNKNOWN_REGION else {
            return Locale.current.regionCode ?? "US"
        }

        return codeFromCarrier
    }()

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationController?.navigationBar.setBackgroundImage(.from(.white), for: .default)

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(numberTextDidChange),
                                               name: .UITextFieldTextDidChange,
                                               object: nil)

        isPhoneNumberValid
            .on { [weak self] in
                self?.accessoryView.isEnabled = $0
            }
            .add(to: linkBag)

        phoneTextField.inputAccessoryView = accessoryView
        accessoryView.tapped.on(next: {
            self.verifyPhone()
        })
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        phoneTextField.becomeFirstResponder()

        if let navController = navigationController,
            navController.viewControllers.first != self {
            navController.setNavigationBarHidden(false, animated: animated)
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        logViewedPage()
    }

    private func verifyPhone() {
        logSubmittedPhone()

        guard
            let text = phoneTextField.text,
            let phoneNumber = try? phoneNumberUtility.parse(text, defaultRegion: regionCode),
            var formattedNumber = try? phoneNumberUtility.format(phoneNumber, numberFormat: .INTERNATIONAL) else {
                logPhoneFormattingFailed()
                return
        }

        formattedNumber = formattedNumber
            .replacingOccurrences(of: " ", with: "")
            .replacingOccurrences(of: "-", with: "")

        accessoryView.isLoading = true

        PhoneAuthProvider.provider()
            .verifyPhoneNumber(formattedNumber, uiDelegate: nil) { [weak self] verificationID, error in
                guard let `self` = self else {
                    return
                }

                self.accessoryView.isLoading = false

                if let error = error {
                    if UIDevice.isiPhone5() {
                        self.view.endEditing(true)
                    }

                    FeedbackGenerator.notifyErrorIfAvailable()
                    let errorMessage = self.errorMessage(for: error as NSError)
                    self.errorLabel.text = errorMessage
                    self.makeErrorLabelVisible(true)
                    self.accessoryView.isLoading = false

                    return
                }

                let confirmCode = StoryboardScene.Main.phoneConfirmationViewController.instantiate()
                confirmCode.verificationId = verificationID!
                confirmCode.phoneNumber = formattedNumber
                self.navigationController?.pushViewController(confirmCode, animated: true)
        }
    }

    fileprivate func errorMessage(for error: NSError) -> String {
        if error.domain == AuthErrorDomain {
            if error.code == AuthErrorCode.invalidPhoneNumber.rawValue
                || error.code == AuthErrorCode.missingPhoneNumber.rawValue {
                return "Invalid phone number"
            }
        }

        return "Something wrong happened. Please check your internet connection"
    }

    fileprivate func makeErrorLabelVisible(_ visible: Bool) {
        UIView.animate(withDuration: 0.25, animations: {
            self.errorLabel.alpha = visible ? 1 : 0
            self.errorLabel.isHidden = !visible
        })
    }

    @objc func numberTextDidChange() {
        let text = phoneTextField.text ?? ""

        if !errorLabel.isHidden {
            makeErrorLabelVisible(false)
        }

        guard
            let phoneNumber = try? phoneNumberUtility.parse(text, defaultRegion: regionCode),
            var formattedNumber = try? phoneNumberUtility.format(phoneNumber, numberFormat: .NATIONAL) else {
                logPhoneFormattingFailed()
                return
        }

        if formattedNumber.first == "0" {
            let indexWithoutZero = formattedNumber.index(formattedNumber.startIndex, offsetBy: 1)
            formattedNumber = String(formattedNumber[indexWithoutZero...])
        }

        formattedNumber = formattedNumber.replacingOccurrences(of: "*", with: "")

        phoneTextField.text = formattedNumber
        let isValid = phoneNumberUtility.isValidNumber(forRegion: phoneNumber, regionCode: regionCode)
        isPhoneNumberValid.next(isValid)
    }
}

extension PhoneVerificationRequestViewController {
    fileprivate func logViewedPage() {
        Events.Analytics.ViewPhoneAuthPage().send()
    }

    fileprivate func logSubmittedPhone() {
        Events.Analytics.ClickNextButtonOnPhoneAuthPage().send()
    }

    fileprivate func logPhoneFormattingFailed() {
        Events.Log.PhoneFormattingFailed().send()
    }
}

private class ButtonAcessoryInputView: UIView {
    private let button: UIButton = {
        let b = UIButton(type: .system)
        b.titleLabel?.font = FontFamily.Roboto.regular.font(size: 18)

        return b
    }()

    lazy var activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .gray)

    let tapped = Observable<Void>()

    var title: String? {
        get {
            return button.title(for: .normal)
        }
        set {
            button.setTitle(newValue, for: .normal)
        }
    }

    var isEnabled: Bool {
        get {
            return button.isEnabled
        }
        set {
            button.isEnabled = newValue
        }
    }

    var isLoading: Bool = false {
        didSet {
            isLoading ? activityIndicator.startAnimating() : activityIndicator.stopAnimating()
            button.isHidden = isLoading
        }
    }

    override var intrinsicContentSize: CGSize {
        return CGSize(width: UIScreen.main.bounds.width, height: 68)
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        commonInit()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        commonInit()
    }

    func commonInit() {
        backgroundColor = .white
        applyThinShadow()

        button.translatesAutoresizingMaskIntoConstraints = false
        addAndFit(button)
        button.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)

        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.hidesWhenStopped = true
        addSubview(activityIndicator)
        activityIndicator.centerInSuperview()
    }

    @objc func buttonTapped() {
        tapped.next(())
    }
}
