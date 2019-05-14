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

    @IBOutlet weak var explanationLabel: UILabel! {
        didSet {
            explanationLabel.text = L10n.OneWallet.ConnectScreen.explanation
            explanationLabel.applySailecLineSpacing()
            explanationLabel.font = FontFamily.Sailec.regular.font(size: 16)
        }
    }

    let acceptButton: RoundedButton = {
        let button = RoundedButton(text: L10n.OneWallet.ConnectScreen.accept)
        button.textFont = FontFamily.Sailec.medium.font(size: 16)
        button.tintColor = UIColor.kin.ecosystemPurple
        button.translatesAutoresizingMaskIntoConstraints = false
        button.textColor = .white
        button.backgroundColor = .white
        button.cornerRadius = 4

        return button
    }()

    @IBOutlet weak var navigationBar: UINavigationBar! {
        didSet {
            navigationBar.isTranslucent = false
            navigationBar.barTintColor = .white
            navigationBar.titleTextAttributes = [.font: FontFamily.Sailec.regular.font(size: 18),
                                                 .foregroundColor: UIColor.black]
            let navigationItem = UINavigationItem(title: "Kin Ecosystem")
            let xImage = Asset.closeXButtonDarkGray.image
            navigationItem.leftBarButtonItem = UIBarButtonItem(image: xImage,
                                                               landscapeImagePhone: nil,
                                                               style: .plain,
                                                               target: self,
                                                               action: #selector(cancelTapped))
            navigationItem.leftBarButtonItem?.tintColor = .black

            navigationBar.items = [navigationItem]
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.tintColor = UIColor.kin.ecosystemPurple
        view.addSubview(acceptButton)
        acceptButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        acceptButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        acceptButton.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.8).isActive = true
        acceptButton.bottomAnchor.constraint(equalTo: view.bottomAnchor,
                                             constant: -40).isActive = true

        acceptButton.tappedHandler = { [weak self] in
            self?.delegate?.oneWalletConfirmationDidConfirm()
        }
    }

    @objc func cancelTapped() {
        delegate?.oneWalletConfirmationDidCancel()
    }
}
