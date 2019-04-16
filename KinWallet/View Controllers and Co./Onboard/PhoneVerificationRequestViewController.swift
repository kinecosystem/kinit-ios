//
//  PhoneVerificationRequestViewController.swift
//  Kinit
//

import UIKit
import FirebaseAuth
import libPhoneNumber_iOS
import KinUtil

class PhoneVerificationRequestViewController: UIViewController {
    var phoneConfirmationViewController: PhoneConfirmationViewController?
    var requestCodeOrErrorCount = 0 {
        didSet {
            if requestCodeOrErrorCount >= 3 {
                phoneConfirmationViewController?.allowContactingSupport = true
            }
        }
    }

    fileprivate let accessoryView: ButtonAccessoryInputView = {
        let b = ButtonAccessoryInputView()
        b.title = L10n.nextAction
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
    var blacklistedCodes: Set<String> = []

    @IBOutlet weak var titleLabel: UILabel! {
        didSet {
            titleLabel.font = FontFamily.Roboto.medium.font(size: 22)
            titleLabel.textColor = UIColor.kin.appTint
            titleLabel.text = L10n.phoneVerificationRequestTitle
        }
    }

    @IBOutlet weak var descriptionLabel: UILabel! {
        didSet {
            descriptionLabel.font = FontFamily.Roboto.regular.font(size: 16)
            descriptionLabel.textColor = UIColor.kin.gray
            descriptionLabel.text = L10n.phoneVerificationRequestMessage
        }
    }

    @IBOutlet weak var countryCodeTextField: UITextField! {
        didSet {
            countryCodeTextField.isUserInteractionEnabled = false
            countryCodeTextField.font = FontFamily.Roboto.regular.font(size: 16)
            countryCodeTextField.textColor = UIColor.kin.gray
            countryCodeTextField.setBottomLine(with: UIColor.kin.gray)

            countryCodeTextField.text = countryCode(for: regionCode)
        }
    }

    @IBOutlet weak var phoneTextField: UITextField! {
        didSet {
            phoneTextField.font = FontFamily.Roboto.regular.font(size: 16)
            phoneTextField.textColor = UIColor.kin.gray
            phoneTextField.setBottomLine(with: UIColor.kin.appTint)
        }
    }

    var regionCode: String {
        let fromCarrier = NBPhoneNumberUtil().countryCodeByCarrier()

        guard let codeFromCarrier = fromCarrier, fromCarrier != NB_UNKNOWN_REGION else {
            return Locale.current.regionCode ?? "US"
        }

        return codeFromCarrier
    }

    private func countryCode(for region: String) -> String {
        let countryCallingCode = NBPhoneNumberUtil().getCountryCode(forRegion: region) ?? NSNumber(value: 1)
        return "+" + countryCallingCode.stringValue
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        WebRequests.Blacklists.areaCodes().withCompletion { [weak self] result in
            if let codes = result.value {
                self?.blacklistedCodes = Set(codes)
            }
        }.load(with: KinWebService.shared)

        navigationController?.navigationBar.setBackgroundImage(.from(.white), for: .default)

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(numberTextDidChange),
                                               name: UITextField.textDidChangeNotification,
                                               object: nil)

        isPhoneNumberValid
            .on { [weak self] in
                self?.accessoryView.isEnabled = $0
            }
            .add(to: linkBag)

        phoneTextField.inputAccessoryView = accessoryView
        accessoryView.tapped.on(next: verifyPhone)

        TestFairy.hide(phoneTextField)
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

        guard !blacklistedCodes.contains(countryCode(for: regionCode)) else {
            alertCountryCodeNotSupported()
            return
        }

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
                guard let self = self else {
                    return
                }

                self.accessoryView.isLoading = false

                if let error = error {
                    if UIDevice.isiPhone5() {
                        self.view.endEditing(true)
                    }

                    KLogError((error as NSError).domain)
                    KLogError((error as NSError).code)
                    FeedbackGenerator.notifyErrorIfAvailable()
                    let errorMessage = self.errorMessage(for: error as NSError)
                    self.errorLabel.text = errorMessage
                    self.makeErrorLabelVisible(true)
                    self.accessoryView.isLoading = false

                    return
                }

                self.showConfirmation(for: formattedNumber, verificationID: verificationID!)
        }
    }

    fileprivate func showConfirmation(for formattedNumber: String, verificationID: String) {
        let confirmCode = StoryboardScene.Onboard.phoneConfirmationViewController.instantiate()
        confirmCode.delegate = self
        confirmCode.verificationId = verificationID
        confirmCode.phoneNumber = formattedNumber
        confirmCode.allowContactingSupport = self.requestCodeOrErrorCount >= 2
        navigationController?.pushViewController(confirmCode, animated: true)
        phoneConfirmationViewController = confirmCode
    }

    fileprivate func errorMessage(for error: NSError) -> String {
        if error.domain == AuthErrorDomain {
            if error.code == AuthErrorCode.invalidPhoneNumber.rawValue
                || error.code == AuthErrorCode.missingPhoneNumber.rawValue {
                return L10n.phoneVerificationRequestInvalidNumber
            }
        }

        return L10n.phoneVerificationRequestGeneralError
    }

    fileprivate func alertCountryCodeNotSupported() {
        let alertController = UIAlertController(title: L10n.phoneVerificationUnsupportedCountryCodeTitle,
                                                message: L10n.phoneVerificationUnsupportedCountryCodeMessage,
                                                preferredStyle: .alert)
        alertController.addOkAction()
        present(alertController, animated: true, completion: nil)
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

extension PhoneVerificationRequestViewController: PhoneConfirmationDelegate {
    func phoneConfirmationRequestedNewCode() {
        requestCodeOrErrorCount += 1
        navigationController?.popViewController(animated: true)
    }

    func phoneConfirmationEnteredWrongCode() {
        requestCodeOrErrorCount += 1
    }
}
