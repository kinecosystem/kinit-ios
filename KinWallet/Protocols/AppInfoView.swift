//
//  AppInfoView.swift
//  KinWallet
//
//  Copyright © 2018 KinFoundation. All rights reserved.
//

import UIKit

protocol AppInfoBasicView {
    var iconImageView: UIImageView? { get }
    var bannerImageView: UIImageView? { get }
    var titleLabel: UILabel? { get }
    var subtitleLabel: UILabel? { get }
    var categoryLabel: UILabel? { get }

    func drawAppInformation(_ app: EcosystemApp, category: String?)
}

extension AppInfoBasicView {
    func drawAppInformation(_ app: EcosystemApp, category: String?) {
        let cardImageURL = app.metadata.cardImageURL.kinImagePathAdjustedForDevice()
        let appIconImageURL = app.metadata.iconURL.kinImagePathAdjustedForDevice()
        bannerImageView?.loadImage(url: cardImageURL, placeholderColor: UIColor.kin.lightGray)
        iconImageView?.loadImage(url: appIconImageURL, placeholderColor: UIColor.kin.lightGray)
        titleLabel?.text = app.name
        subtitleLabel?.text = app.metadata.shortDescription
        categoryLabel?.text = category
    }
}
