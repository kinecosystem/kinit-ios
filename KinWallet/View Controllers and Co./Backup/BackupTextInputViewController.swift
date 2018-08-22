//
//  BackupTextInputViewController.swift
//  KinWallet
//
//  Copyright © 2018 KinFoundation. All rights reserved.
//

import UIKit

class BackupTextInputViewController: UIViewController {
    let accessoryView = ButtonAccessoryInputView.nextActionButton()
    @IBOutlet weak var titleStackViewTopConstraint: NSLayoutConstraint!

    @IBOutlet weak var observationLabel: UILabel! {
        didSet {
            observationLabel.font = FontFamily.Roboto.regular.font(size: 12)
            observationLabel.textColor = UIColor.kin.slightlyLightGray
        }
    }

    @IBOutlet weak var textField: UITextField! {
        didSet {
            textField.makeBackupTextField()
        }
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        textField.inputAccessoryView = accessoryView
        accessoryView.tapped.on(next: moveToNextStep)
        accessoryView.isEnabled = false
    }

    func isInputTextValid(text: String? = nil) -> Bool {
        fatalError("Override")
    }

    @objc func moveToNextStep() {

    }
}

extension BackupTextInputViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if isInputTextValid() {
            accessoryView.shake()
        } else {
            observationLabel.shake()
        }

        return false
    }
}
