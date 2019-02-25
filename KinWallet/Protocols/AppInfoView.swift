//
//  AppInfoView.swift
//  KinWallet
//
//  Copyright © 2018 KinFoundation. All rights reserved.
//

import UIKit

protocol AppInfoBasicView {
    static var actionButtonHeight: CGFloat { get }
    static var actionButtonWidth: CGFloat { get }

    var iconImageView: UIImageView? { get }
    var bannerImageView: UIImageView? { get }
    var titleLabel: UILabel? { get }
    var subtitleLabel: UILabel? { get }
    var categoryLabel: UILabel? { get }
    var actionButton: UIButton? { get }

    func drawAppInformation(_ app: EcosystemApp, category: String?, short: Bool)
    func setupActionButtonConstraints()
}

extension AppInfoBasicView {
    static var actionButtonHeight: CGFloat {
        return 28
    }

    static var actionButtonWidth: CGFloat {
        return 72
    }

    func setupActionButtonConstraints() {
        actionButton?.heightAnchor.constraint(equalToConstant: Self.actionButtonHeight).isActive = true
        actionButton?.widthAnchor.constraint(equalToConstant: Self.actionButtonWidth).isActive = true
    }

    func drawAppInformation(_ app: EcosystemApp, category: String?, short: Bool) {
        let cardImageURL = app.metadata.cardImageURL.kinImagePathAdjustedForDevice()
        let appIconImageURL = app.metadata.iconURL.kinImagePathAdjustedForDevice()
        bannerImageView?.loadImage(url: cardImageURL, placeholderColor: UIColor.kin.lightGray)
        iconImageView?.loadImage(url: appIconImageURL, placeholderColor: UIColor.kin.lightGray)
        titleLabel?.text = app.name
        subtitleLabel?.text = app.metadata.shortDescription
        categoryLabel?.text = category

        let isTransferAvailable = app.isTransferAvailable
        let actionTitle: String

        if isTransferAvailable {
            actionTitle = short ? L10n.sendKinActionShort : L10n.sendKinAction
            actionButton?.makeKinButtonFilled(height: Self.actionButtonHeight)
        } else {
            actionTitle = short ? L10n.getAppShort : L10n.getApp
            actionButton?.makeKinButtonOutlined(height: Self.actionButtonHeight, borderWidth: 1)
        }

        actionButton?.setTitle(actionTitle, for: .normal)
    }
}
