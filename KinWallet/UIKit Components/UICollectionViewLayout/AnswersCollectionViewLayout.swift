//
//  AnswersCollectionViewLayout.swift
//  Kinit
//

import UIKit

//swiftlint:disable line_length

class AnswersCollectionViewLayout: UICollectionViewFlowLayout {
    let question: Question
    var dualImageMidY: CGFloat = 0
    var shouldInsertDualImageSeparator = false

    struct Constants {
        static let initialAlpha: CGFloat = 0
        static let initialTransform = CGAffineTransform.init(scaleX: 0.85, y: 0.85)
    }

    init(question: Question) {
        self.question = question
        super.init()

        commonInit()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("Use init(question: Question) as the AnswersCollectionViewLayout initializer")
    }

    func commonInit() {
        scrollDirection = .vertical
        sectionHeadersPinToVisibleBounds = true

        let nib = UINib(nibName: DualImageQuestionSeparatorView.nibName, bundle: nil)
        register(nib, forDecorationViewOfKind: DualImageQuestionSeparatorView.kind)
    }

    override func initialLayoutAttributesForAppearingItem(at itemIndexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        guard let attributes = super.initialLayoutAttributesForAppearingItem(at: itemIndexPath) else {
            return nil
        }

        attributes.alpha = Constants.initialAlpha
        attributes.transform = Constants.initialTransform

        return attributes
    }

    override func indexPathsToInsertForDecorationView(ofKind elementKind: String) -> [IndexPath] {
        if !shouldInsertDualImageSeparator || dualImageMidY == 0 {
            return []
        }

        return [IndexPath(item: 0, section: 0)]
    }

    override func initialLayoutAttributesForAppearingDecorationElement(ofKind elementKind: String,
                                                                       at decorationIndexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        guard let attributes = super.initialLayoutAttributesForAppearingDecorationElement(ofKind: elementKind,
                                                                                          at: decorationIndexPath) else {
            return nil
        }

        attributes.alpha = Constants.initialAlpha
        attributes.transform = Constants.initialTransform

        return attributes
    }

    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        guard var fromSuper = super.layoutAttributesForElements(in: rect) else {
            return nil
        }

        if question.type == .dualImage,
            fromSuper.count == 2 {
            let firstCellFrame = fromSuper.first!.frame
            let lastCellFrame = fromSuper.last!.frame
            dualImageMidY = (firstCellFrame.maxY + lastCellFrame.minY)/2

            let kind = DualImageQuestionSeparatorView.kind
            let indexPath = IndexPath(item: 0, section: 0)
            if let dualImageSeparatorAttributes = layoutAttributesForDecorationView(ofKind: kind, at: indexPath) {
                fromSuper.append(dualImageSeparatorAttributes)
            }
        }

        return fromSuper
    }

    override func layoutAttributesForDecorationView(ofKind elementKind: String,
                                                    at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        guard question.type == .dualImage,
            shouldInsertDualImageSeparator,
            dualImageMidY > 0,
            let collectionView = collectionView else {
            return nil
        }

        let height = DualImageQuestionSeparatorView.height
        let attributes = UICollectionViewLayoutAttributes(forDecorationViewOfKind: elementKind, with: indexPath)
        attributes.frame = CGRect(x: 0,
                                  y: dualImageMidY - floor(height/2),
                                  width: collectionView.frame.width,
                                  height: height)
        attributes.zIndex = 10

        return attributes
    }
}

//swiftlint:enable line_length
