//
//  EmptyStateView.swift
//  KinWallet
//
//  Copyright © 2018 KinFoundation. All rights reserved.
//

import UIKit

class EmptyStateView: UIView {
    private struct Constants {
        static let floatingLedgerAnimationDuration: TimeInterval = 3
    }

    @IBOutlet weak var shadowView: UIView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var textLabel: UILabel! {
        didSet {
            textLabel.font = FontFamily.Roboto.regular.font(size: 14)
            textLabel.textColor = UIColor.kin.gray
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()

        isUserInteractionEnabled = false
    }

    func startAnimating() {
        imageView.transform = .identity
        shadowView.transform = .identity
        shadowView.alpha = 0.5

        UIView.animate(withDuration: Constants.floatingLedgerAnimationDuration,
                       delay: 0,
                       options: [.curveEaseInOut, .autoreverse, .repeat],
                       animations: {
                        self.imageView.transform = CGAffineTransform(translationX: 0, y: 25)
                        self.shadowView.transform = CGAffineTransform(scaleX: 0.6, y: 0.6)
                        self.shadowView.alpha = 1
        }, completion: nil)
    }

    func stopAnimating() {
        imageView.layer.removeAllAnimations()
        shadowView.layer.removeAllAnimations()
    }
}
