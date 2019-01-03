//
//  HorizontalGalleryCollectionViewLayout.swift
//  KinWallet
//
//  Copyright © 2018 KinFoundation. All rights reserved.
//

import UIKit

class HorizontalGalleryCollectionViewLayout: UICollectionViewFlowLayout {
    override func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint,
                                      withScrollingVelocity velocity: CGPoint) -> CGPoint {

        guard let collectionView = collectionView else {
            return super.targetContentOffset(forProposedContentOffset: proposedContentOffset,
                                             withScrollingVelocity: velocity)
        }

        let maxOffset = collectionViewContentSize.width - collectionView.bounds.width
        var lastOffset: CGFloat = 0
        var availableOffsets = [lastOffset, maxOffset]

        let itemWidth = itemSize.width
        for index in stride(from: 0, to: collectionView.numberOfItems(inSection: 0), by: 1) {
            if index == 0 {
                let offset = itemWidth + sectionInset.right/2
                lastOffset = offset
                availableOffsets.append(offset)
            } else {
                let offset = lastOffset + itemWidth + sectionInset.right/2
                lastOffset = offset
                if offset < maxOffset {
                    availableOffsets.append(offset)
                }
            }
        }

        guard availableOffsets.isNotEmpty else {
            return super.targetContentOffset(forProposedContentOffset: proposedContentOffset,
                                             withScrollingVelocity: velocity)
        }

        availableOffsets.sort()

        var closestValidOffset = availableOffsets.reduce(maxOffset) { (offset, availableOffset) -> CGFloat in
            if  abs(proposedContentOffset.x - availableOffset) < abs(proposedContentOffset.x - offset) {
                return availableOffset
            }

            return offset
        }

        guard let index = availableOffsets.index(of: closestValidOffset) else {
            return super.targetContentOffset(forProposedContentOffset: proposedContentOffset,
                                             withScrollingVelocity: velocity)
        }

        if collectionView.contentOffset.x > closestValidOffset, velocity.x > 0, index + 1 < availableOffsets.count {
            closestValidOffset = availableOffsets[index + 1]
        } else if collectionView.contentOffset.x < closestValidOffset, velocity.x < 0, index - 1 >= 0 {
            closestValidOffset = availableOffsets[index - 1]
        }

        return CGPoint(x: closestValidOffset, y: 0)
    }

    override var itemSize: CGSize {
        get {
            guard let cv = collectionView else { return .zero }
            return cv.frame
                .inset(by: sectionInset)
                .size
        }
        set {
            super.itemSize = newValue
        }
    }
}
