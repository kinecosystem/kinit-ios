//
//  OfferCollectionViewCell.swift
//  Kinit
//

import UIKit

class OfferCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var offerImageView: UIImageView!
    @IBOutlet weak var authorImageView: UIImageView!

    @IBOutlet weak var leadingCornerMaskImageView: UIImageView!
    @IBOutlet weak var trailingCornerMaskImageView: UIImageView!

    var offerImage: UIImage?
    var authorImage: UIImage?

    @IBOutlet weak var titleLabel: UILabel! {
        didSet {
            titleLabel.font = FontFamily.Roboto.medium.font(size: 16)
            titleLabel.textColor = UIColor.kin.darkGray
        }
    }

    @IBOutlet weak var authorNameLabel: UILabel! {
        didSet {
            authorNameLabel.font = FontFamily.Roboto.regular.font(size: 14)
            authorNameLabel.textColor = UIColor.kin.lightGray
            authorNameLabel.numberOfLines = 2
        }
    }

    @IBOutlet weak var priceLabel: UILabel! {
        didSet {
            priceLabel.font = FontFamily.Roboto.medium.font(size: 16)
            priceLabel.textColor = UIColor.kin.blue
        }
    }

    var offer: Offer! {
        didSet {
            drawOffer()
        }
    }

    static func itemSize(for cellWidth: CGFloat) -> CGSize {
        let ratio: CGFloat = 1.48
        return CGSize(width: cellWidth, height: cellWidth/ratio)
    }

    override func awakeFromNib() {
        super.awakeFromNib()

        let imageToFlip = isRightToLeft ? leadingCornerMaskImageView : trailingCornerMaskImageView
        imageToFlip?.transform = CGAffineTransform(scaleX: -1, y: 1)

        authorImageView.layer.cornerRadius = 8
    }

    func drawOffer() {
        offerImage = nil
        authorImage = nil

        offerImageView.loadImage(url: offer.imageURL.kinImagePathAdjustedForDevice(),
                                 placeholderImage: Asset.patternPlaceholder.image) { [weak self] image in
                                    self?.offerImage = image
        }

        authorImageView.loadImage(url: offer.author.imageURL.kinImagePathAdjustedForDevice(),
                                  placeholderColor: UIColor.kin.extraLightGray) { [weak self] image in
                                    self?.authorImage = image
        }

        titleLabel.text = offer.title
        authorNameLabel.text = offer.author.name
        let priceString = KinAmountFormatter().string(from: NSNumber(value: offer.price))
            ?? String(describing: offer.price)

        if offer.shouldDisplayPrice() {
            priceLabel.text = "\(priceString) KIN"
        } else {
            priceLabel.text = nil
        }
    }
}

extension OfferCollectionViewCell: NibLoadableView { }
