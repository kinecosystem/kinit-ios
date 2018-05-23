//
//  AnswersCollectionViewLayout.swift
//  KinWallet
//
//  Copyright © 2018 KinFoundation. All rights reserved.
//

import UIKit

class AnswersCollectionViewLayout: UICollectionViewFlowLayout {
    struct Constants {
        static let initialAlpha: CGFloat = 0
        static let initialTransform = CGAffineTransform.init(scaleX: 0.85, y: 0.85)
    }

    override init() {
        super.init()

        commonInit()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        commonInit()
    }

    func commonInit() {
        scrollDirection = .vertical
        sectionHeadersPinToVisibleBounds = true
    }

    //swiftlint:disable:next line_length
    override func initialLayoutAttributesForAppearingItem(at itemIndexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        guard let attributes = super.initialLayoutAttributesForAppearingItem(at: itemIndexPath) else {
            return nil
        }

        attributes.alpha = Constants.initialAlpha
        attributes.transform = Constants.initialTransform

        return attributes
    }
}
