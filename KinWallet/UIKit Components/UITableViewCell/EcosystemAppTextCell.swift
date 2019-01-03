//
//  EcosystemAppTextCell.swift
//  KinWallet
//
//  Copyright © 2018 KinFoundation. All rights reserved.
//

import UIKit

private let extraTitleSpacing: CGFloat = 4
private let extraSubtitleSpacing: CGFloat = 16
private let bottomSpacing: CGFloat = 6

class EcosystemAppTextCell: UITableViewCell {
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)

        textLabel?.font = FontFamily.Roboto.regular.font(size: 20)
        textLabel?.textColor = UIColor.kin.gray

        detailTextLabel?.font = FontFamily.Roboto.regular.font(size: 16)
        detailTextLabel?.textColor = UIColor.kin.gray
        detailTextLabel?.numberOfLines = 0
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) not implemented in EcosystemAppTextCell")
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        var titleFrame = textLabel!.frame
        titleFrame.origin.y += extraTitleSpacing
        textLabel!.frame = titleFrame

        var detailFrame = detailTextLabel!.frame
        detailFrame.origin.y += extraSubtitleSpacing
        detailTextLabel!.frame = detailFrame
    }

    override func systemLayoutSizeFitting(_ targetSize: CGSize,
                                          withHorizontalFittingPriority horizontalFittingPriority: UILayoutPriority,
                                          verticalFittingPriority: UILayoutPriority) -> CGSize {
        var fromSuper = super.systemLayoutSizeFitting(targetSize,
                                                      withHorizontalFittingPriority: horizontalFittingPriority,
                                                      verticalFittingPriority: verticalFittingPriority)
        fromSuper.height += extraTitleSpacing + extraSubtitleSpacing + bottomSpacing

        return fromSuper
    }

    override func systemLayoutSizeFitting(_ targetSize: CGSize) -> CGSize {
        var fromSuper = super.systemLayoutSizeFitting(targetSize)
        fromSuper.height += extraTitleSpacing + extraSubtitleSpacing + bottomSpacing

        return fromSuper
    }
}
