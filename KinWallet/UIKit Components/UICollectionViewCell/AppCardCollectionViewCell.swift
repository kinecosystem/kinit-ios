//
//  AppCardCollectionViewCell.swift
//  KinWallet
//
//  Copyright © 2018 KinFoundation. All rights reserved.
//

import UIKit

protocol AppCardCellDelegate: class {
    func appCardCellDidTapActionButton(_ cell: AppCardCollectionViewCell)
}

class AppCardCollectionViewCell: UICollectionViewCell {
    weak var delegate: AppCardCellDelegate?
    var row: Int!
    var column: Int!

    @IBOutlet weak var bannerImageView: UIImageView? {
        didSet {
            bannerImageView?.layer.cornerRadius = 8
            bannerImageView?.layer.masksToBounds = true
        }
    }

    @IBOutlet weak var iconImageView: UIImageView? {
        didSet {
            iconImageView?.layer.cornerRadius = 8
            iconImageView?.layer.masksToBounds = true
        }
    }

    @IBOutlet weak var titleLabel: UILabel? {
        didSet {
            titleLabel?.textColor = UIColor.kin.darkGray
            titleLabel?.font = FontFamily.Roboto.bold.font(size: 16)
        }
    }

    @IBOutlet weak var subtitleLabel: UILabel? {
        didSet {
            subtitleLabel?.textColor = UIColor.kin.gray
            subtitleLabel?.font = FontFamily.Roboto.regular.font(size: 14)
        }
    }

    @IBOutlet weak var actionButton: UIButton?

    override func awakeFromNib() {
        super.awakeFromNib()

        setupActionButtonConstraints()
    }

    @IBAction func actionButtonTapped() {
        delegate?.appCardCellDidTapActionButton(self)
    }
}

extension AppCardCollectionViewCell: AppInfoBasicView {
    var categoryLabel: UILabel? {
        return nil
    }
}

extension AppCardCollectionViewCell: NibLoadableView {}
