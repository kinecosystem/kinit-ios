//
//  MoreTableViewCell.swift
//  KinWallet
//
//  Copyright © 2018 KinFoundation. All rights reserved.
//

import UIKit

class MoreTableViewCell: UITableViewCell {
    override func awakeFromNib() {
        super.awakeFromNib()

        textLabel?.font = FontFamily.Roboto.regular.font(size: 16)
        textLabel?.textColor = UIColor.kin.gray
    }


}
