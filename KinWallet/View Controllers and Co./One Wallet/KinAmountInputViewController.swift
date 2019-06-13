//
//  KinAmountInputViewController.swift
//  KinWallet
//
//  Copyright © 2019 KinFoundation. All rights reserved.
//

import UIKit

protocol KinAmountInputDelegate: class {
    func amountInputDidChange(_ amount: UInt64)
}

class KinAmountInputViewController: UIViewController {
    let keyboard = KinitNumberPad(style: .default)
    weak var delegate: KinAmountInputDelegate?

    private let amountLabel = with(KinAmountLabel(frame: .zero)) {
        $0.size = .large
        $0.precedenceType = .prefixed
    }

    private let formatter: NumberFormatter = {
        let f = NumberFormatter()
        f.locale = Locale.current
        f.numberStyle = .decimal

        return f
    }()

    override func loadView() {
        let view = UIView()
        view.backgroundColor = .white

        self.view = view
    }

    var isEnabled: Bool {
        get {
            return keyboard.isEnabled
        }
        set {
            keyboard.isEnabled = newValue
        }
    }

    var amount: UInt64 {
        get {
            return amountLabel.amount
        }
        set {
            UIView.performWithoutAnimation {
                delegate?.amountInputDidChange(newValue)
            }

            amountLabel.amount = newValue
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        amountLabel.textAlignment = .center
        amountLabel.adjustsFontSizeToFitWidth = true
        amountLabel.minimumScaleFactor = 0.5
        amountLabel.textColor = UIColor.kin.ecosystemPurple
        amountLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(amountLabel)
        NSLayoutConstraint.activate([
            amountLabel.heightAnchor.constraint(equalToConstant: 60),
            view.centerXAnchor.constraint(equalTo: amountLabel.centerXAnchor),
            amountLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            NSLayoutConstraint(item: amountLabel,
                               attribute: .centerY,
                               relatedBy: .equal,
                               toItem: view,
                               attribute: .centerY,
                               multiplier: 0.6,
                               constant: 0)
            ])

        keyboard.delegate = self
        keyboard.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(keyboard)
        view.leadingAnchor.constraint(equalTo: keyboard.leadingAnchor).isActive = true
        view.trailingAnchor.constraint(equalTo: keyboard.trailingAnchor).isActive = true

        view.safeBottomAnchor.constraint(equalTo: keyboard.bottomAnchor).isActive = true
        keyboard.heightAnchor.constraint(equalToConstant: 200).isActive = true
    }
}

extension KinAmountInputViewController: KinitNumberPadDelegate {
    func numberPadPressed(key: KinitNumberPadKey) {
        var newAmount = amount

        if key != .delete {
            guard newAmount < 1_000_000_000_000 else {
                return
            }
        }

        switch key {
        case .hundred:
            newAmount *= 100
        case .ten:
            newAmount *= 10
        case .delete:
            newAmount /= 10
        case .digit(let digit):
            newAmount *= 10
            newAmount += UInt64(digit)
        }

        delegate?.amountInputDidChange(newAmount)
        UIView.transition(with: amountLabel, duration: 0.075, options: .transitionCrossDissolve, animations: {
            self.amount = newAmount
        }, completion: nil)
    }
}
