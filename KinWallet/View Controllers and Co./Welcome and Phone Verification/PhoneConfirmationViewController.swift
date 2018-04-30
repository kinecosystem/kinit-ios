//
//  PhoneConfirmationViewController.swift
//  KinWallet
//
//  Copyright © 2018 KinFoundation. All rights reserved.
//

import UIKit
import FirebaseAuth
import KinUtil

class PhoneConfirmationViewController: UIViewController {
    let isCodeLengthValid = Observable<Bool>(false)
    let linkBag = LinkBag()

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

    func verifyCode() {
        guard
            var user = User.current,
            isCurrentCodeValid() else {
            return
        }

        let credential = PhoneAuthProvider.provider().credential(withVerificationID: verificationId,
                                                                 verificationCode: currentCode())
        activityIndicatorView.startAnimating()

        Auth.auth().signIn(with: credential) { [weak self] _, error in
            guard let aSelf = self else {
                return
            }

            aSelf.activityIndicatorView.stopAnimating()
            
            if error != nil {
                FeedbackGenerator.notifyErrorIfAvailable()
                aSelf.textFields.forEach {
                    $0.text = ""
                    $0.shake(delta: 20)
                }

                aSelf.textFields.first?.becomeFirstResponder()

                return
            }

            user.phoneNumber = aSelf.phoneNumber
            user.save()

            AppDelegate.shared.dismissSplashIfNeeded()
            WebRequests.updateUserPhone(aSelf.phoneNumber).load(with: KinWebService.shared)
            FeedbackGenerator.notifySuccessIfAvailable()
        }
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
