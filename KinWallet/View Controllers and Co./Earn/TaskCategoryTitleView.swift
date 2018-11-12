//
//  TaskCategoryTitleView.swift
//  KinWallet
//
//  Copyright © 2018 KinFoundation. All rights reserved.
//

import UIKit

class TaskCategoryTitleView: UIView {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var tasksCountStackView: UIStackView!
    @IBOutlet weak var tasksCountLabel: UILabel!
    @IBOutlet weak var iconImageView: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()

        let textColor = UIColor.white
        let font = FontFamily.Roboto.regular

        titleLabel.textColor = textColor
        titleLabel.font = font.font(size: 20)

        tasksCountLabel.textColor = textColor
        tasksCountLabel.font = font.font(size: 12)
    }
}

extension TaskCategoryTitleView: NibLoadableView {}
