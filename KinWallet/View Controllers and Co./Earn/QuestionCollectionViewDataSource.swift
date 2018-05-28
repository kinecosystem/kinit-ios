//
//  QuestionCollectionViewDataSource.swift
//  KinWallet
//
//  Copyright © 2018 KinFoundation. All rights reserved.
//

import UIKit

final class QuestionCollectionViewDataSource: NSObject {
    private struct Constants {
        static let imageQuestionCellSize = CGSize(width: 134, height: 124)
        static let questionViewHeight: CGFloat = 140
        static let questionViewWithImageHeight: CGFloat = 260
        static let textAnswerCellHeight: CGFloat = 46
        static let textMultipleAnswerCellHeight: CGFloat = 60
        static let textMultipleAnswerCellHeightCompact: CGFloat = 44
        static let collectionViewMinimumSpacing: CGFloat = 15
        static let numberOfColumns: CGFloat = 2
    }

    let question: Question
    let collectionView: UICollectionView

    weak var questionViewController: QuestionViewController?
    var selectedAnswerIds = Set<String>()
    var recognizedCell: SurveyAnswerCollectionViewCell?
    fileprivate(set) var animationIndex = 0
    var answersCount: Int {
        return question.results.count
    }

    init(question: Question, collectionView: UICollectionView) {
        self.question = question
        self.collectionView = collectionView

        super.init()

        collectionView.dataSource = self
        collectionView.delegate = self
    }

    func answerCell(_ collectionView: UICollectionView,
                    indexPath: IndexPath) -> UICollectionViewCell {
        let answer = question.results[indexPath.item]

        let cell: SurveyAnswerCollectionViewCell = {
            switch question.type {
            case .text, .textEmoji:
                return collectionView.dequeueReusableCell(forIndexPath: indexPath)
                    as SurveyTextAnswerCollectionViewCell
            case .multipleText:
                return collectionView.dequeueReusableCell(forIndexPath: indexPath)
                    as SurveyMultipleTextAnswerCollectionViewCell
            case .textAndImage:
                if answer.hasOnlyImage() {
                    return collectionView.dequeueReusableCell(forIndexPath: indexPath)
                        as SurveyImageAnswerCollectionViewCell
                }

                return collectionView.dequeueReusableCell(forIndexPath: indexPath)
                    as SurveyTextImageAnswerCollectionViewCell
            }
        }()

        cell.indexPath = indexPath
        cell.delegate = self
        SurveyViewsFactory.drawCell(cell, for: answer, questionType: question.type)
        cell.isSelected = selectedAnswerIds.contains(answer.identifier)

        return cell
    }

    func incrementAnimationIndex() -> Bool {
        if answersCount == animationIndex {
            return false
        }

        animationIndex += 1

        return true
    }

    func answer(at index: Int, didSelect selected: Bool) {
        guard let viewController = questionViewController else {
            fatalError("QuestionCollectionViewDataSource has no questionViewController assigned.")
        }

        let answer = question.results[index]
        let aId = answer.identifier

        if selected {
            selectedAnswerIds.insert(aId)
        } else {
            selectedAnswerIds.remove(aId)
        }

        viewController.dataSource(didChange: selectedAnswerIds)
    }
}

extension QuestionCollectionViewDataSource: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        return animationIndex
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return answerCell(collectionView, indexPath: indexPath)
    }

    func collectionView(_ collectionView: UICollectionView,
                        viewForSupplementaryElementOfKind kind: String,
                        at indexPath: IndexPath) -> UICollectionReusableView {
        let questionView: SurveyQuestionCollectionReusableView =
            collectionView.dequeueReusableView(ofKind: UICollectionElementKindSectionHeader,
                                               forIndexPath: indexPath)
        SurveyViewsFactory.draw(questionView, for: question, size: questionViewSize())

        return questionView
    }
}

extension QuestionCollectionViewDataSource: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.bounds.width
        let widthWithLateralInset = width - Constants.collectionViewMinimumSpacing * 2

        switch question.type {
        case .text, .textEmoji:
            return CGSize(width: widthWithLateralInset, height: Constants.textAnswerCellHeight)
        case .multipleText:
            let height = UIDevice.isiPhone5()
                ? Constants.textMultipleAnswerCellHeightCompact
                : Constants.textMultipleAnswerCellHeight

            return CGSize(width: width, height: height)
        case .textAndImage:
            return Constants.imageQuestionCellSize
        }
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        if question.type == .text || question.allowsMultipleSelection {
            return .zero
        }

        let widthInsets = question.type == .textAndImage
            ? spacing(for: collectionView)
            : Constants.collectionViewMinimumSpacing

        return UIEdgeInsets(top: 0,
                            left: widthInsets,
                            bottom: widthInsets,
                            right: widthInsets)
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        referenceSizeForHeaderInSection section: Int) -> CGSize {
        return questionViewSize()
    }

    fileprivate func questionViewSize() -> CGSize {
        let width = collectionView.bounds.width

        if question.imageURL != nil {
            return CGSize(width: width,
                          height: Constants.questionViewWithImageHeight)
        }

        return CGSize(width: width,
                      height: Constants.questionViewHeight)
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        if question.type == .text {
            return Constants.collectionViewMinimumSpacing
        }

        if question.allowsMultipleSelection {
            return 0
        }

        return spacing(for: collectionView)
    }

    func collectionView(_ collectionView: UICollectionView,
                        willDisplaySupplementaryView view: UICollectionReusableView,
                        forElementKind elementKind: String,
                        at indexPath: IndexPath) {
        view.layer.zPosition = 0
    }

    private func spacing(for collectionView: UICollectionView) -> CGFloat {
        let width = collectionView.frame.width
        let emptySpace = width - Constants.numberOfColumns * Constants.imageQuestionCellSize.width
        return emptySpace/(Constants.numberOfColumns + 1)
    }

    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        collectionView.visibleCells
            .compactMap {
                $0 as? SurveyAnswerCollectionViewCell
            }.forEach {
                $0.cancelTouchIfNeeded()
        }
    }
}

extension QuestionCollectionViewDataSource: SurveyAnswerDelegate {
    func surveyAnswerCellDidSelect(_ cell: SurveyAnswerCollectionViewCell) {
        answer(at: cell.indexPath.item, didSelect: true)
    }

    func surveyAnswerCellDidDeselect(_ cell: SurveyAnswerCollectionViewCell) {
        answer(at: cell.indexPath.item, didSelect: false)
    }

    func surveyAnswerCellDidStartSelecting(_ cell: SurveyAnswerCollectionViewCell) {
        guard let viewController = questionViewController else {
            KLogWarn("QuestionCollectionViewDataSource has no questionViewController assigned.")
            return
        }

        viewController.surveyAnswerCellDidStartSelecting(cell)
    }

    func surveyAnswerCellDidCancelSelecting(_ cell: SurveyAnswerCollectionViewCell) {
        guard let viewController = questionViewController else {
            KLogWarn("QuestionCollectionViewDataSource has no questionViewController assigned.")
            return
        }

        viewController.surveyAnswerCellDidCancelSelecting(cell)
    }
}
