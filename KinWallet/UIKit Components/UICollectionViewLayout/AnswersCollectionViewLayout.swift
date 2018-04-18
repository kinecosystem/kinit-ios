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

    //swiftlint:disable:next line_length
    override func initialLayoutAttributesForAppearingItem(at itemIndexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        guard let attributes = super.initialLayoutAttributesForAppearingItem(at: itemIndexPath) else {
            return nil
        }

        guard itemIndexPath.section == QuestionnaireSections.answers.rawValue else {
            return attributes
        }

        attributes.alpha = Constants.initialAlpha
        attributes.transform = Constants.initialTransform

        return attributes
    }
}
