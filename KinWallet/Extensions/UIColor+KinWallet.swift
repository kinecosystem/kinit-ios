//
//  UIColor+KinWallet.swift
//  KinWallet
//
//  Copyright © 2018 KinFoundation. All rights reserved.
//

import UIKit

struct KinColors {
    let blue = UIColor(red: 4, green: 124, blue: 252)
    let green = UIColor(red: 71, green: 252, blue: 5)
    let appTint = UIColor(red: 22, green: 147, blue: 243)

    let darkGray = UIColor(red: 92, green: 103, blue: 134)
    let gray = UIColor(red: 120, green: 132, blue: 165)
    let lightGray = UIColor(red: 215, green: 220, blue: 233)
    let extraLightGray = UIColor(red: 239, green: 238, blue: 240)

    let errorRed = UIColor(red: 219, green: 68, blue: 55)

    let cadetBlue = UIColor(red: 164, green: 172, blue: 194)
    let brightBlue = UIColor(red: 130, green: 255, blue: 238)
}

extension UIColor {
    convenience init(red: Int, green: Int, blue: Int, alpha: CGFloat = 1) {
        self.init(red: CGFloat(red)/CGFloat(255),
                  green: CGFloat(green)/CGFloat(255),
                  blue: CGFloat(blue)/CGFloat(255),
                  alpha: alpha)
    }

    static let kin = KinColors()

    static let blueGradientColors1 = [UIColor(red: 23, green: 157, blue: 249),
                                      UIColor(red: 8, green: 76, blue: 201)]
    static let blueGradientColors2 = [UIColor(red: 15, green: 116, blue: 255),
                                      UIColor(red: 16, green: 142, blue: 251),
                                      UIColor(red: 19, green: 175, blue: 246)]
    static let navigationBarGradientColors = [UIColor(red: 14, green: 109, blue: 220),
                                              UIColor(red: 25, green: 163, blue: 253)]
}
