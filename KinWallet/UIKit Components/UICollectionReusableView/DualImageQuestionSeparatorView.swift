//
//  DualImageQuestionSeparatorView.swift
//  KinWallet
//
//  Copyright © 2018 KinFoundation. All rights reserved.
//

import UIKit

class DualImageQuestionSeparatorView: UICollectionReusableView, NibLoadableView {
    static let kind = "DualImageQuestionSeparator"
    static let height: CGFloat = 19

    @IBOutlet weak var orLabel: UILabel! {
        didSet {
            orLabel.textColor = UIColor.kin.gray
            orLabel.text = L10n.or
        }
    }
}
