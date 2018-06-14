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
}
