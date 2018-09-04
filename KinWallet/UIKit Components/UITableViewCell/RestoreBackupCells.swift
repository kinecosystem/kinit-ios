//
//  RestoreBackupCells.swift
//  KinWallet
//
//  Copyright © 2018 KinFoundation. All rights reserved.
//

import UIKit
import KinUtil

class RestoreBackupHeaderCell: UITableViewCell {
    @IBOutlet weak var titleLabel: UILabel! {
        didSet {
            titleLabel.font = FontFamily.Roboto.medium.font(size: 22)
            titleLabel.textColor = UIColor.kin.darkGray
            titleLabel.text = L10n.restoreBackupQuestionsTitle
        }
    }

    @IBOutlet weak var subtitleLabel: UILabel! {
        didSet {
            subtitleLabel.font = FontFamily.Roboto.regular.font(size: 16)
            subtitleLabel.textColor = UIColor.kin.gray
            subtitleLabel.text = L10n.restoreBackupQuestionsSubtitle
        }
    }
}

class RestoreBackupQuestionCell: UITableViewCell {
    static let fontFamily = FontFamily.Roboto.self

    @IBOutlet weak var questionLabel: UILabel! {
        didSet {
            questionLabel.font = RestoreBackupQuestionCell.fontFamily.regular.font(size: 14)
            questionLabel.textColor = UIColor.kin.gray
        }
    }

    @IBOutlet weak var titleLabel: UILabel! {
        didSet {
            titleLabel.font = FontFamily.Roboto.medium.font(size: 16)
            titleLabel.textColor = UIColor.kin.darkGray
            titleLabel.text = L10n.restoreBackupYourAnswerTitle
        }
    }

    @IBOutlet weak var textField: UITextField! {
        didSet {
            textField.placeholder = L10n.restoreBackupYourAnswerPlaceholder
            textField.makeBackupTextField()
            TestFairy.hide(textField)
        }
    }
}

protocol RestoreBackupCellDelegate: class {
    func restoreBackupCellDidTapNext()
}

class RestoreBackupActionCell: UITableViewCell {
    let actionButton = ButtonAccessoryInputView.nextActionButton()
    let linkBag = LinkBag()
    weak var delegate: RestoreBackupCellDelegate?

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        contentView.addAndCenter(actionButton)
        actionButton.tapped.on(next: { [weak self] in
            self?.delegate?.restoreBackupCellDidTapNext()
        })
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
