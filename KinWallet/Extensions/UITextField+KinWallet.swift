//
//  UITextField+KinWallet.swift
//  Kinit
//

import Foundation

extension UITextField {
    func setBottomLine(with color: UIColor, height: CGFloat = 1) {
        background = {
            UIGraphicsBeginImageContextWithOptions(CGSize(width: 1, height: frame.height), false, 0)
            defer {
                UIGraphicsEndImageContext()
            }

            let rectanglePath = UIBezierPath(rect: CGRect(x: 0,
                                                          y: frame.height - height,
                                                          width: 1,
                                                          height: height))
            color.setFill()
            rectanglePath.fill()

            return UIGraphicsGetImageFromCurrentImageContext()
        }()
    }

    var textOrEmpty: String {
        return text ?? ""
    }

    func makeBackupTextField() {
        autocorrectionType = .no
        autocapitalizationType = .none
        clearButtonMode = .never
        setLeftPaddingPoints(10)
        setRightPaddingPoints(10)
        layer.cornerRadius = 3
        layer.borderWidth = 2
        layer.borderColor = UIColor.kin.lightGray.cgColor
        font = FontFamily.Roboto.regular.font(size: 16)
        textColor = UIColor.kin.gray
    }

    func setLeftPaddingPoints(_ amount: CGFloat) {
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: self.frame.size.height))
        self.leftView = paddingView
        self.leftViewMode = .always
    }

    func setRightPaddingPoints(_ amount: CGFloat) {
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: self.frame.size.height))
        self.rightView = paddingView
        self.rightViewMode = .always
    }
}
