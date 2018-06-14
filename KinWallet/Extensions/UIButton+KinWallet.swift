//
//  UIButton+KinWallet.swift
//  Kinit
//

import UIKit

private let kinButtonFont = FontFamily.Roboto.medium.font(size: 16)

extension UIButton {
    func makeKinButtonFilled(with color: UIColor = UIColor.kin.blue) {
        setBackgroundImage(.from(color), for: .normal)
        tintColor = .white
        titleLabel?.font = kinButtonFont
        layer.masksToBounds = true
        layer.cornerRadius = frame.height / 2.0
    }

    func makeKinButtonOutlined() {
        setBackgroundImage(Asset.buttonStroke.image, for: .normal)
        titleLabel?.font = kinButtonFont
        tintColor = UIColor.kin.blue
    }
}
