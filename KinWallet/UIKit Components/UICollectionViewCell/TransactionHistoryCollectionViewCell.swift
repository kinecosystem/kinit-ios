//
//  TransactionHistoryCollectionViewCell.swift
//  KinWallet
//
//  Copyright © 2018 KinFoundation. All rights reserved.
//

import UIKit

class TransactionHistoryCellFactory {
    static let timeDateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateStyle = .none
        f.timeStyle = .short

        return f
    }()

    static let dayDateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "d MMM"

        return f
    }()

    class func drawCell(_ cell: TransactionHistoryCollectionViewCell,
                        for transaction: KinitTransaction,
                        isFirst: Bool,
                        isLast: Bool,
                        balanceAfter: UInt64) {
        cell.amountLabel.text = "\(transaction.isEarn ? "+" : "-")\(transaction.amount) K"
        cell.amountLabel.textColor = transaction.isEarn
            ? UIColor.kin.appTint
            : UIColor.kin.gray

        if transaction.isEarn {
            cell.sourceLabel.text = "Daily Task"
        } else {
            cell.sourceLabel.text = transaction.title
        }

        let date = transaction.date
        cell.dateLabel.text = Date().beginningOfDay() < date
            ? timeDateFormatter.string(from: date)
            : dayDateFormatter.string(from: date)

        cell.timelineTopView.isHidden = isFirst
        cell.timelineBottomView.isHidden = isLast

        cell.balanceLabel.text = "\(balanceAfter) K"

        cell.iconImageView.image = (transaction.isEarn ? Asset.historyKinIcon : Asset.historyCouponIcon).image
    }
}

class TransactionHistoryCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var timelineTopView: UIView!
    @IBOutlet weak var timelineBottomView: UIView!
    @IBOutlet weak var iconImageView: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()

        for v in [timelineTopView, timelineBottomView] {
            v?.backgroundColor = UIColor.kin.lightGray
        }
    }

    @IBOutlet weak var amountLabel: UILabel! {
        didSet {
            amountLabel.font = FontFamily.Roboto.medium.font(size: 16)
        }
    }

    @IBOutlet weak var sourceLabel: UILabel! {
        didSet {
            sourceLabel.font = FontFamily.Roboto.regular.font(size: 18)
            sourceLabel.textColor = UIColor.kin.darkGray
        }
    }

    @IBOutlet weak var dateLabel: UILabel! {
        didSet {
            dateLabel.font = FontFamily.Roboto.regular.font(size: 14)
            dateLabel.textColor = UIColor.kin.gray
        }
    }

    @IBOutlet weak var balanceLabel: UILabel! {
        didSet {
            balanceLabel.font = FontFamily.Roboto.regular.font(size: 14)
            balanceLabel.textColor = UIColor.kin.gray
        }
    }
}

extension TransactionHistoryCollectionViewCell: NibLoadableView {}
