//
//  KinitInputNumberPad.swift
//  KinWallet
//
//  Copyright © 2019 KinFoundation. All rights reserved.
//

import UIKit

protocol KinitNumberPadDelegate: class {
    func numberPadPressed(key: KinitNumberPadKey)
}

final class KinitNumberPad: UIView {
    let buttons: [KinitNumberPadButton]
    weak var delegate: KinitNumberPadDelegate?

    var isEnabled: Bool = true {
        didSet {
            buttons.forEach {
                $0.isEnabled = isEnabled
            }
        }
    }

    init(style: KinitNumberPadButtonStyle) {
        let keys: [KinitNumberPadKey] = [.digit(1), .digit(2), .digit(3),
                                         .digit(4), .digit(5), .digit(6),
                                         .digit(7), .digit(8), .digit(9),
                                         .hundred, .ten, .delete]
        buttons = keys.map { KinitNumberPadButton(style: style, key: $0) }

        super.init(frame: .zero)

        buttons.forEach {
            $0.addTarget(self, action: #selector(buttonTapped), for: .primaryActionTriggered)
        }

        let buttonsChunked = buttons.chunked(into: 3)

        let stackViews = buttonsChunked.map { rowButtons -> UIStackView in
            let stackView = UIStackView(arrangedSubviews: rowButtons)
            stackView.axis = .horizontal
            stackView.distribution = .fillEqually
            stackView.alignment = .fill
            stackView.spacing = 0
            return stackView
        }

        let mainStackView = UIStackView(arrangedSubviews: stackViews)
        mainStackView.translatesAutoresizingMaskIntoConstraints = false
        mainStackView.axis = .vertical
        mainStackView.distribution = .fillEqually
        mainStackView.alignment = .fill
        mainStackView.spacing = 0

        addSubview(mainStackView)
        NSLayoutConstraint.activate([
            leadingAnchor.constraint(equalTo: mainStackView.leadingAnchor),
            topAnchor.constraint(equalTo: mainStackView.topAnchor),
            trailingAnchor.constraint(equalTo: mainStackView.trailingAnchor),
            bottomAnchor.constraint(equalTo: mainStackView.bottomAnchor)
            ])
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc func buttonTapped(_ sender: KinitNumberPadButton) {
        UIDevice.current.playInputClick()
        delegate?.numberPadPressed(key: sender.key)
    }
}

struct KinInputActionBarStyle {
    let backgroundColor: UIColor
    let progressColor: UIColor
    let disabledBackgroundColor: UIColor
    let textColor: UIColor
    let disabledTextColor: UIColor
    let font: UIFont

    static let `default` = KinInputActionBarStyle(backgroundColor: UIColor.kin.ecosystemPurple,
                                                  progressColor: UIColor(red: 0.58, green: 0.42, blue: 0.99, alpha: 1),
                                                  disabledBackgroundColor: UIColor(red: 0.91, green: 0.91, blue: 0.91, alpha: 1),
                                                  textColor: .white,
                                                  disabledTextColor: UIColor(red: 0.65, green: 0.65, blue: 0.65, alpha: 1),
                                                  font: FontFamily.Sailec.bold.font(size: 18))
}

extension KinitNumberPad: UIInputViewAudioFeedback {
    var enableInputClicksWhenVisible: Bool {
        return true
    }
}
