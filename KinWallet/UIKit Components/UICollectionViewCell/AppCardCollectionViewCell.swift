//
//  AppCardCollectionViewCell.swift
//  KinWallet
//
//  Copyright © 2018 KinFoundation. All rights reserved.
//

import UIKit

protocol AppCardCellDelegate: class {
    func appCardCellDidTapOpenApp(_ cell: AppCardCollectionViewCell)
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

    @IBOutlet weak var getAppButton: UIButton! {
        didSet {
            getAppButton.setTitle(L10n.getApp, for: .normal)
            getAppButton.makeKinButtonOutlined(height: 28, borderWidth: 1)
            getAppButton.widthAnchor.constraint(equalToConstant: 72).isActive = true
        }
    }

    @IBAction func openApp() {
        delegate?.appCardCellDidTapOpenApp(self)
    }
}

extension AppCardCollectionViewCell: AppInfoBasicView {
    var categoryLabel: UILabel? {
        return nil
    }
}

extension AppCardCollectionViewCell: NibLoadableView {}
