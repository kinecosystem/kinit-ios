//
//  EcosystemFooterTableViewCell.swift
//  KinWallet
//
//  Copyright © 2018 KinFoundation. All rights reserved.
//

import UIKit

class EcosystemFooterTableViewCell: UITableViewCell {
    @IBOutlet weak var explanationLabel: UILabel! {
        didSet {
            explanationLabel.text = L10n.AppDiscovery.Footer.title
            explanationLabel.font = FontFamily.Roboto.bold.font(size: 16)
            explanationLabel.textColor = UIColor.kin.gray
        }
    }

    @IBOutlet weak var moreAppsSoonLabel: UILabel! {
        didSet {
            moreAppsSoonLabel.text = L10n.AppDiscovery.Footer.subtitle
            moreAppsSoonLabel.font = FontFamily.Roboto.regular.font(size: 16)
            moreAppsSoonLabel.textColor = UIColor.kin.lightGray
        }
    }

    @IBOutlet weak var illustrationImageView: UIImageView! {
        didSet {
            illustrationImageView.layer.shadowColor = UIColor.kin.gray.cgColor
            illustrationImageView.layer.shadowOpacity = 0.5
            illustrationImageView.layer.shadowOffset = CGSize(width: 0, height: 3)
            illustrationImageView.layer.shadowRadius = 5
        }
    }
}

extension EcosystemFooterTableViewCell: NibLoadableView {}
