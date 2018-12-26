//
//  UIButton+KinWallet.swift
//  Kinit
//

import UIKit

private let kinButtonFont = FontFamily.Roboto.medium.font(size: 16)

extension UIButton {
    func makeKinButtonFilled(with color: UIColor = UIColor.kin.blue, height: CGFloat? = nil) {
        let side = height ?? frame.height
        let image = UIImage
            .from(color, size: .init(width: side, height: side), oval: true)?
            .resizableImage(withCapInsets: .init(top: 0, left: side/2, bottom: 0, right: side/2))
        setBackgroundImage(image, for: .normal)
        tintColor = color == .white ? UIColor.kin.appTint : .white
        titleLabel?.font = kinButtonFont
    }

    func makeKinButtonOutlined(height: CGFloat = 52,
                               borderWidth: CGFloat = 2,
                               borderColor: UIColor = UIColor.kin.blue) {
        makeKinButtonFilled(with: .white, height: height)
        layer.borderWidth = borderWidth
        layer.borderColor = UIColor.kin.blue.cgColor
        layer.cornerRadius = height/2
    }
}
