//
//  TutorialPageView.swift
//  Kinit
//

import UIKit

class TutorialPageView: UIView {
    @IBOutlet weak var leadingMinimumConstraint: NSLayoutConstraint!
    @IBOutlet weak var topConstraint: NSLayoutConstraint!

    class func create(with title: String, message: String, image: UIImage) -> TutorialPageView {
        let nib = Bundle.main.loadNibNamed("TutorialPageView", owner: nil, options: nil)
        guard let pageView = nib?.first as? TutorialPageView else {
            fatalError("TutorialPageView could not be loaded from main bundle.")
        }

        pageView.titleLabel.text = title
        pageView.messageLabel.text = message
        pageView.imageView.image = image

        return pageView
    }

    @IBOutlet weak var titleLabel: UILabel! {
        didSet {
            titleLabel.textColor = .white
            titleLabel.font = FontFamily.Roboto.medium.font(size: 32)
        }
    }

    @IBOutlet weak var messageLabel: UILabel! {
        didSet {
            messageLabel.textColor = .white
            messageLabel.font = FontFamily.Roboto.regular.font(size: 16)
        }
    }

    @IBOutlet weak var imageView: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()

        backgroundColor = .clear

        if UIDevice.isiPhone5() {
            leadingMinimumConstraint.constant = 20
            topConstraint.constant /= 3
        }
    }
}
