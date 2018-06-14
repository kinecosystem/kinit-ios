//
//  NSLayoutConstraintHairline.swift
//  Kinit
//

import UIKit

class NSLayoutConstraintHairline: NSLayoutConstraint {
    override init() {
        super.init()

        commonInit()
    }

    override func awakeFromNib() {
        super.awakeFromNib()

        commonInit()
    }

    func commonInit() {
        constant = 1.0 / UIScreen.main.scale
    }
}
