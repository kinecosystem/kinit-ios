//
//  SimpleCollectionReusableView.swift
//  Kinit
//

import UIKit

class SimpleCollectionReusableView: UICollectionReusableView {
    @IBOutlet weak var textLabel: UILabel! {
        didSet {
            textLabel.font = FontFamily.Roboto.regular.font(size: 16)
            textLabel.textColor = UIColor.kin.darkGray
        }
    }
}

extension SimpleCollectionReusableView: NibLoadableView { }
