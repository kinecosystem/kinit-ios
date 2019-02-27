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

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        commonInit()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        commonInit()
    }

    private func commonInit() {
        selectionStyle = .none
    }
}

extension EcosystemFooterTableViewCell: NibLoadableView {}
