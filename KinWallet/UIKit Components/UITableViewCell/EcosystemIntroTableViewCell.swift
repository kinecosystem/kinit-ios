//
//  EcosystemIntroTableViewCell.swift
//  KinWallet
//
//  Copyright © 2018 KinFoundation. All rights reserved.
//

import UIKit

class EcosystemIntroTableViewCell: UITableViewCell {
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)

        textLabel?.adjustsFontSizeToFitWidth = true
        textLabel?.minimumScaleFactor = 0.5
        textLabel?.text = L10n.AppDiscovery.Header.title
        textLabel?.font = FontFamily.Roboto.medium.font(size: 20)
        textLabel?.textColor = UIColor.kin.gray

        detailTextLabel?.text = L10n.AppDiscovery.Header.subtitle
        detailTextLabel?.font = FontFamily.Roboto.regular.font(size: 16)
        detailTextLabel?.textColor = UIColor.kin.gray
        detailTextLabel?.numberOfLines = 2
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        let difference: CGFloat = 5
        var textFrame = textLabel!.frame
        textFrame.origin.x += difference
        textFrame.size.width -= difference
        textLabel!.frame = textFrame

        var detailFrame = detailTextLabel!.frame
        detailFrame.origin.x += difference
        detailFrame.size.width -= difference
        detailTextLabel!.frame = detailFrame
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
