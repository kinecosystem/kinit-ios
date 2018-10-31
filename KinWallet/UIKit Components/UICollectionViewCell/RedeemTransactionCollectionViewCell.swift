//
//  RedeemTransactionCollectionViewCell.swift
//  Kinit
//

import UIKit

protocol RedeemTransactionCellDelegate: class {
    func redeemTransactionCellDidTapExport(_ cell: RedeemTransactionCollectionViewCell)
    func redeemTransactionCellDidToggle(_ cell: RedeemTransactionCollectionViewCell)
}

class RedeemTransactionCellFactory {
    class func drawCell(_ cell: RedeemTransactionCollectionViewCell, for transaction: RedeemTransaction) {
        cell.iconImageView.loadImage(url: transaction.provider.imageURL.kinImagePathAdjustedForDevice())
        cell.titleLabel.text = transaction.title
        cell.detailsTextView.text = transaction.description
        cell.couponCodeLabel.text = transaction.value
    }
}

class RedeemTransactionCollectionViewCell: UICollectionViewCell {
    var indexPath: IndexPath!
    weak var delegate: RedeemTransactionCellDelegate?

    @IBOutlet var detailsBottomConstraint: NSLayoutConstraint!

    var isOpen = false {
        didSet {
            detailsBottomConstraint.isActive = isOpen
            let buttonTitle = isOpen ? "See less" : "See details"
            detailsToggleButton.setTitle(buttonTitle, for: .normal)
        }
    }

    @IBOutlet weak var iconImageView: UIImageView!

    @IBOutlet weak var titleLabel: UILabel! {
        didSet {
            titleLabel.font = FontFamily.Roboto.regular.font(size: 18)
            titleLabel.textColor = UIColor.kin.darkGray
        }
    }

    @IBOutlet weak var separator: UIView! {
        didSet {
            separator.backgroundColor = UIColor.kin.lightGray
        }
    }

    @IBOutlet weak var detailsTextView: UITextView! {
        didSet {
            detailsTextView.font = FontFamily.Roboto.regular.font(size: 14)
            detailsTextView.textColor = UIColor.kin.gray
        }
    }

    @IBOutlet weak var couponCodeLabel: UILabel! {
        didSet {
            couponCodeLabel.font = FontFamily.Roboto.medium.font(size: 15)
            couponCodeLabel.textColor = UIColor.kin.gray
        }
    }

    @IBOutlet weak var detailsToggleButton: UIButton! {
        didSet {
            detailsToggleButton.titleLabel?.font = FontFamily.Roboto.regular.font(size: 14)
        }
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        isOpen = false
    }

    override func awakeFromNib() {
        super.awakeFromNib()

        detailsBottomConstraint.isActive = false
    }

    @IBAction func toggleDetails(_ sender: Any) {
        delegate?.redeemTransactionCellDidToggle(self)
    }

    @IBAction func export(_ sender: Any) {
        delegate?.redeemTransactionCellDidTapExport(self)
    }
}

extension RedeemTransactionCollectionViewCell: NibLoadableView {}
