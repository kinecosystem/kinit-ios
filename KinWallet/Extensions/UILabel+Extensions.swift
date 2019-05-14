//
//  UILabel+Extensions.swift
//  KinWallet
//
//  Copyright © 2019 KinFoundation. All rights reserved.
//

import UIKit

extension UILabel {
    func applySailecLineSpacing(_ spacing: CGFloat = 5) {
        guard let text = text else {
            return
        }

        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = spacing
        paragraphStyle.alignment = textAlignment
        attributedText = NSAttributedString(string: text, attributes: [.paragraphStyle: paragraphStyle])
    }
}
