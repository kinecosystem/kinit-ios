//
//  SendKinToAppUnavailableTableViewCell.swift
//  KinWallet
//
//  Copyright © 2018 KinFoundation. All rights reserved.
//

import UIKit

class SendKinToAppUnavailableTableViewCell: UITableViewCell {
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        textLabel?.text = L10n.AppPage.sendComingSoon
        textLabel?.font = FontFamily.Roboto.regular.font(size: 14)
        textLabel?.numberOfLines = 2
        textLabel?.textColor = UIColor.kin.gray

        imageView?.image = Asset.infoIcon.image

        let topSeparator = separator()
        let bottomSeparator = separator()

        [topSeparator, bottomSeparator].forEach {
            let cv = self.contentView
            cv.addSubview($0)
            cv.leadingAnchor.constraint(equalTo: $0.leadingAnchor).isActive = true
            cv.trailingAnchor.constraint(equalTo: $0.trailingAnchor).isActive = true
        }

        contentView.topAnchor.constraint(equalTo: topSeparator.topAnchor).isActive = true
        contentView.bottomAnchor.constraint(equalTo: bottomSeparator.bottomAnchor).isActive = true
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    fileprivate func separator() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.kin.lightGray
        view.heightAnchor.constraint(equalToConstant: 1).isActive = true

        return view
    }
}
