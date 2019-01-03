//
//  AppBasicInfoTableViewCell.swift
//  KinWallet
//
//  Copyright © 2018 KinFoundation. All rights reserved.
//

import UIKit

protocol AppBasicInfoDelegate: class {
    func appBasicInfoCellDidTapOpen(_ cell: AppBasicInfoTableViewCell)
}

class AppBasicInfoTableViewCell: UITableViewCell {
    weak var delegate: AppBasicInfoDelegate?

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

    @IBOutlet weak var categoryLabel: UILabel? {
        didSet {
            categoryLabel?.textColor = UIColor.kin.gray
            categoryLabel?.font = FontFamily.Roboto.regular.font(size: 12)
        }
    }

    @IBOutlet weak var getAppButton: UIButton! {
        didSet {
            getAppButton.setTitle(L10n.getAppShort, for: .normal)
            getAppButton.makeKinButtonOutlined(height: 28, borderWidth: 1)
            getAppButton.widthAnchor.constraint(equalToConstant: 72).isActive = true
        }
    }

    @IBAction func didTapOpen() {
        delegate?.appBasicInfoCellDidTapOpen(self)
    }
}

extension AppBasicInfoTableViewCell: AppInfoBasicView {
    var bannerImageView: UIImageView? {
        return nil
    }
}

extension AppBasicInfoTableViewCell: NibLoadableView {}
