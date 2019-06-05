//
//  KinitNumberPadButton.swift
//  KinWallet
//
//  Copyright © 2019 KinFoundation. All rights reserved.
//

import UIKit

struct KinitNumberPadButtonStyle {
    enum Background {
        case color(UIColor)
        case image(UIImage)
    }

    let buttonBackground: Background
    let buttonBackgroundHighlighted: Background
    let font: UIFont
    let textColor: UIColor
    let highlightedTextColor: UIColor
    let disabledTextColor: UIColor
    let backspaceImage: UIImage

    static let `default` = KinitNumberPadButtonStyle(buttonBackground: .image(Asset.numberPadBackground.image),
                                                     buttonBackgroundHighlighted: .color(.init(red: 0.43, green: 0.26, blue: 0.91, alpha: 1.00)),
                                                     font: FontFamily.Sailec.bold.font(size: 20),
                                                     textColor: .black,
                                                     highlightedTextColor: .white,
                                                     disabledTextColor: .lightGray,
                                                     backspaceImage: Asset.numberPadDelete.image)
}

enum KinitNumberPadKey {
    case digit(UInt)
    case hundred
    case ten
    case delete
}

extension KinitNumberPadKey: Equatable {}

final class KinitNumberPadButton: UIButton {
    let key: KinitNumberPadKey

    init(style: KinitNumberPadButtonStyle, key: KinitNumberPadKey) {
        self.key = key

        super.init(frame: .zero)

        switch style.buttonBackground {
        case .color(let color):
            setBackgroundImage(.from(color), for: .normal)
        case .image(let image):
            setBackgroundImage(image, for: .normal)
        }

        switch style.buttonBackgroundHighlighted {
        case .color(let color):
            setBackgroundImage(.from(color), for: .highlighted)
        case .image(let image):
            setBackgroundImage(image, for: .highlighted)
        }

        switch key {
        case .digit(let digit):
            setTitle(String(describing: digit), for: .normal)
        case .hundred:
            setTitle("00", for: .normal)
        case .ten:
            setTitle("0", for: .normal)
        case .delete:
            setImage(style.backspaceImage, for: .normal)
            setImage(style.backspaceImage.tinted(with: style.highlightedTextColor), for: .highlighted)
            setImage(style.backspaceImage.tinted(with: style.disabledTextColor), for: .disabled)
        }

        titleLabel?.font = style.font
        setTitleColor(style.textColor, for: .normal)
        setTitleColor(style.highlightedTextColor, for: .highlighted)
        setTitleColor(style.disabledTextColor, for: .disabled)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        next?.touchesBegan(touches, with: event)
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)
        next?.touchesMoved(touches, with: event)
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        next?.touchesEnded(touches, with: event)
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)
        next?.touchesCancelled(touches, with: event)
    }

    func numberPadTouchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)
    }
}
