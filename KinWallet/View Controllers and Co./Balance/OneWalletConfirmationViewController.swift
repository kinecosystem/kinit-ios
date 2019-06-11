//
//  OneWalletConfirmationViewController.swift
//  KinWallet
//
//  Copyright © 2019 KinFoundation. All rights reserved.
//

import UIKit
import KinitDesignables

protocol OneWalletConfirmationDelegate: class {
    func oneWalletConfirmationDidCancel()
    func oneWalletConfirmationDidConfirm()
}

final class OneWalletConfirmationViewController: UIViewController {
    weak var delegate: OneWalletConfirmationDelegate?
    var appName: String! {
        didSet {
            if isViewLoaded {
                explanationLabel.setTextApplyingLineSpacing(L10n.OneWallet.ConnectScreen.explanation(appName))
            }
        }
    }

    var isLoading = false {
        didSet {
            if isLoading {
                activityIndicator.startAnimating()
            } else {
                activityIndicator.stopAnimating()
            }
        }
    }

    @IBOutlet weak var explanationLabel: UILabel! {
        didSet {
            explanationLabel.text = nil
            explanationLabel.font = FontFamily.Sailec.regular.font(size: 16)
        }
    }

    private let agreeButton: RoundedButton = {
        let button = RoundedButton(text: L10n.OneWallet.ConnectScreen.accept)
        button.textFont = FontFamily.Sailec.medium.font(size: 16)
        button.tintColor = UIColor.kin.ecosystemPurple
        button.translatesAutoresizingMaskIntoConstraints = false
        button.textColor = .white
        button.backgroundColor = .white
        button.cornerRadius = 4

        return button
    }()

    private let activityIndicator: UIActivityIndicatorView = {
        let a = UIActivityIndicatorView(style: .gray)
        a.translatesAutoresizingMaskIntoConstraints = false
        a.color = UIColor.kin.ecosystemPurple

        return a
    }()

    private let errorMessageLabel: UILabel = {
        let l = UILabel()
        l.translatesAutoresizingMaskIntoConstraints = false
        l.textColor = UIColor.kin.cranberryRed
        l.font = FontFamily.Sailec.regular.font(size: 14)
        l.textAlignment = .center
        l.numberOfLines = 0

        return l
    }()

    @IBOutlet weak var navigationBar: UINavigationBar! {
        didSet {
            navigationBar.isTranslucent = false
            navigationBar.shadowImage = .init()
            let navigationItem = UINavigationItem(title: "Kin Ecosystem")
            let xImage = Asset.closeButtonBlack.image.withRenderingMode(.alwaysOriginal)
            navigationItem.leftBarButtonItem = UIBarButtonItem(image: xImage,
                                                               landscapeImagePhone: nil,
                                                               style: .plain,
                                                               target: self,
                                                               action: #selector(cancelTapped))

            navigationBar.items = [navigationItem]
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.tintColor = UIColor.kin.ecosystemPurple

        navigationBar.setBackgroundImage(.from(.white), for: .default)
        navigationBar.titleTextAttributes = [.font: FontFamily.Sailec.regular.font(size: 18),
                                             .foregroundColor: UIColor.black]

        addAgreeButton()
        addActivityIndicator()
        addErrorMessageLabel()
    }

    func setAgreeButtonHidden(_ hidden: Bool, animated: Bool) {
        let changes = {
            self.agreeButton.alpha = hidden ? 0 : 1
        }

        guard animated else {
            changes()
            return
        }

        UIView.animate(withDuration: 0.25, animations: changes)
    }

    func setErrorMessage(_ message: String?) {
        guard let message = message else {
            errorMessageLabel.text = nil
            return
        }

        errorMessageLabel.setTextApplyingLineSpacing(message)
    }

    func setAgreeButtonEnabled(_ enabled: Bool) {
        agreeButton.isEnabled = enabled
    }

    private func addAgreeButton() {
        view.addSubview(agreeButton)
        agreeButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        agreeButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        agreeButton.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.8).isActive = true
        view.bottomAnchor.constraint(equalTo: agreeButton.bottomAnchor, constant: 42).isActive = true

        agreeButton.tappedHandler = { [weak self] in
            self?.delegate?.oneWalletConfirmationDidConfirm()
        }
    }

    private func addActivityIndicator() {
        view.addSubview(activityIndicator)
        activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        agreeButton.topAnchor.constraint(equalTo: activityIndicator.bottomAnchor, constant: 24).isActive = true
    }

    private func addErrorMessageLabel() {
        view.addSubview(errorMessageLabel)
        view.centerXAnchor.constraint(equalTo: errorMessageLabel.centerXAnchor).isActive = true
        agreeButton.widthAnchor.constraint(equalTo: errorMessageLabel.widthAnchor).isActive = true
        agreeButton.topAnchor.constraint(equalTo: errorMessageLabel.bottomAnchor, constant: 24).isActive = true
    }

    @objc func cancelTapped() {
        delegate?.oneWalletConfirmationDidCancel()
    }
}
