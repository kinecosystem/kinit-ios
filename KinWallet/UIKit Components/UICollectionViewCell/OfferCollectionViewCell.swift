//
//  OfferCollectionViewCell.swift
//  Kinit
//

import UIKit

class OfferCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var offerImageView: UIImageView!
    @IBOutlet weak var authorImageView: UIImageView!

    var offerImage: UIImage?
    var authorImage: UIImage?
    var lastImageViewSize = CGSize.zero

    @IBOutlet weak var titleLabel: UILabel! {
        didSet {
            titleLabel.font = FontFamily.Roboto.medium.font(size: 16)
            titleLabel.textColor = UIColor.kin.darkGray
        }
    }

    @IBOutlet weak var unavailableLabel: UILabel! {
        didSet {
            unavailableLabel.font = FontFamily.Roboto.regular.font(size: 16)
            unavailableLabel.textColor = UIColor.kin.gray
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

        authorImageView.layer.cornerRadius = 8
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        if lastImageViewSize != offerImageView.bounds.size {
            let path = UIBezierPath(roundedRect: offerImageView.bounds,
                                    byRoundingCorners: [.topRight, .topLeft],
                                    cornerRadii: CGSize(width: 8, height: 8))

            let maskLayer = CAShapeLayer()
            maskLayer.path = path.cgPath
            offerImageView.layer.mask = maskLayer
            lastImageViewSize = offerImageView.bounds.size
        }
    }

    func drawOffer() {
        offerImage = nil
        authorImage = nil

        offerImageView.loadImage(url: offer.imageURL.kinImagePathAdjustedForDevice(),
                                 placeholderImage: Asset.patternPlaceholder.image,
                                 useInMemoryCache: true) { [weak self] image in
                                    self?.offerImage = image
        }

        authorImageView.loadImage(url: offer.author.imageURL.kinImagePathAdjustedForDevice(),
                                  placeholderColor: UIColor.kin.extraLightGray,
                                  useInMemoryCache: true) { [weak self] image in
                                    self?.authorImage = image
        }

        titleLabel.text = offer.title
        authorNameLabel.text = offer.author.name
        let priceString = KinAmountFormatter().string(from: NSNumber(value: offer.price))
            ?? String(describing: offer.price)

        priceLabel.text = offer.shouldDisplayPrice()
            ? "\(priceString) KIN"
            : nil

        offerImageView.alpha = offer.isAvailable ? 1 : 0.1
        unavailableLabel.isHidden = offer.isAvailable
        unavailableLabel.text = offer.unavailableReason
    }
}

extension OfferCollectionViewCell: NibLoadableView { }
