//
//  QuestionViewController.swift
//  Kinit
//

import UIKit

typealias SelectedAnswer = SelectedResult

enum AnswerCelebration {
    case none
    case particles([UIImage])
    case centeredEmoji(String)
    case quiz(correctAnswerId: String)
}

extension AnswerCelebration: Equatable {
    static func == (lhs: AnswerCelebration, rhs: AnswerCelebration) -> Bool {
        switch (lhs, rhs) {
        case (.none, .none):
            return true
        case (.particles(let imagesLhs), .particles(let imagesRhs)):
            return imagesLhs == imagesRhs
        case (.centeredEmoji(let emojiLhs), .centeredEmoji(let emojiRhs)):
            return emojiLhs == emojiRhs
        default:
            return false
        }
    }
}

protocol QuestionViewControllerDelegate: class {
    func questionViewController(_ viewController: QuestionViewController, didSelect selectedAnswer: SelectedAnswer)
}

private struct Constants {
    static let collectionViewSpacing: CGFloat = 15
    struct AnswersInsertionDelay {
        static let firstQuestion = 0.7
        static let notFirstQuestion = 1.2
    }

    static let answerInsertionAnimationDuration = 0.2
    static let answersInsertionIntervalDuration = 0.1
    static let nextButtonHeight: CGFloat = 66
    static let questionViewHeight: CGFloat = 140
    static let questionViewWithImageHeight: CGFloat = 260
}

final class QuestionViewController: UIViewController {
    let question: Question
    fileprivate let collectionViewDataSource: QuestionCollectionViewDataSource
    let collectionView: UICollectionView
    let isInitialQuestion: Bool
    let nextButton: UIButton?
    let questionViewContainer = UIView()
    private(set) weak var questionDelegate: QuestionViewControllerDelegate?

    let layout: AnswersCollectionViewLayout

    init(question: Question, questionDelegate: QuestionViewControllerDelegate, isInitialQuestion: Bool) {
        self.layout = AnswersCollectionViewLayout(question: question)
        self.questionDelegate = questionDelegate
        self.question = question
        self.isInitialQuestion = isInitialQuestion
        nextButton = question.allowsMultipleSelection ? UIButton(type: .system) : nil

        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .white
        collectionView.allowsSelection = true
        collectionView.allowsMultipleSelection = question.allowsMultipleSelection

        collectionViewDataSource = QuestionCollectionViewDataSource(question: question,
                                                                    collectionView: collectionView)

        super.init(nibName: nil, bundle: nil)

        collectionViewDataSource.questionViewController = self

        nextButton?.isEnabled = false
        nextButton?.setTitle(L10n.nextAction, for: .normal)
        nextButton?.titleLabel?.font = FontFamily.Roboto.regular.font(size: 18)
        nextButton?.addTarget(self,
                              action: #selector(questionFinished),
                              for: .touchUpInside)
        addCollectionView(with: nextButton)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        animateAnswerInsertions()
    }

    func addCollectionView(with button: UIButton?) {
        let questionViewHeight = question.imageURL != nil
            ? Constants.questionViewWithImageHeight
            : Constants.questionViewHeight

        let viewGuides: Anchorable
        if #available(iOS 11.0, *) {
            viewGuides = view.safeAreaLayoutGuide
        } else {
            viewGuides = view
        }

        let qViewId = SurveyQuestionCollectionReusableView.reuseIdentifier
        let questionView = Bundle.main
            .loadNibNamed(qViewId, owner: nil, options: nil)!
            .first as! SurveyQuestionCollectionReusableView //swiftlint:disable:this force_cast
        questionView.translatesAutoresizingMaskIntoConstraints = false
        let questionViewSize = CGSize(width: UIScreen.main.bounds.width, height: questionViewHeight)
        SurveyViewsFactory.draw(questionView, for: question, size: questionViewSize)

        let buttonContainer = UIView()
        let buttonContainerHeight = button != nil ? Constants.nextButtonHeight : 0
        buttonContainer.backgroundColor = .white
        buttonContainer.translatesAutoresizingMaskIntoConstraints = false

        if let button = button {
            buttonContainer.applyThinShadow()
            buttonContainer.addAndFit(button)
        }

        collectionView.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(questionView)
        view.addSubview(collectionView)
        view.addSubview(buttonContainer)

        let constraints = [
            viewGuides.topAnchor.constraint(equalTo: questionView.topAnchor),
            viewGuides.leadingAnchor.constraint(equalTo: questionView.leadingAnchor),
            viewGuides.trailingAnchor.constraint(equalTo: questionView.trailingAnchor),
            questionView.bottomAnchor.constraint(equalTo: collectionView.topAnchor),
            questionView.heightAnchor.constraint(equalToConstant: questionViewHeight),
            viewGuides.leadingAnchor.constraint(equalTo: collectionView.leadingAnchor),
            viewGuides.trailingAnchor.constraint(equalTo: collectionView.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: buttonContainer.topAnchor),
            viewGuides.leadingAnchor.constraint(equalTo: buttonContainer.leadingAnchor),
            viewGuides.trailingAnchor.constraint(equalTo: buttonContainer.trailingAnchor),
            viewGuides.bottomAnchor.constraint(equalTo: buttonContainer.bottomAnchor),
            buttonContainer.heightAnchor.constraint(equalToConstant: buttonContainerHeight)
        ]
        NSLayoutConstraint.activate(constraints)
    }

    func animateAnswerInsertions() {
        let delay = isInitialQuestion
            ? Constants.AnswersInsertionDelay.firstQuestion
            : Constants.AnswersInsertionDelay.notFirstQuestion
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            self.animateNextAnswerInsertion()
        }
    }

    func animateNextAnswerInsertion() {
        let currentIndex = self.collectionViewDataSource.animationIndex
        let shouldContinue = collectionViewDataSource.incrementAnimationIndex()

        if shouldContinue {
            UIView.animate(withDuration: Constants.answerInsertionAnimationDuration) {
                let indexPath = IndexPath(item: currentIndex,
                                          section: 0)
                self.collectionView.insertItems(at: [indexPath])
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + Constants.answersInsertionIntervalDuration) {
                self.animateNextAnswerInsertion()
            }
        } else {
            collectionView.flashScrollIndicators()

            if question.type == .dualImage {
                collectionView.performBatchUpdates({
                    self.layout.shouldInsertDualImageSeparator = true
                }, completion: nil)
            }
        }
    }

    func dataSource(didChange answers: Set<String>) {
        if let nextButton = nextButton {
            enableCellsInteraction(true)
            nextButton.isEnabled = !answers.isEmpty
        } else {
            questionFinished()
        }
    }

    @objc func questionFinished() {
        guard
            let answerId = collectionViewDataSource.selectedAnswerIds.first,
            let answer = question.results.filter({ $0.identifier == answerId }).first else {
                KLogError(KinitErrorCodes.noSelectedAnswer.rawValue, domain: KinErrorDomain)
                return
        }

        guard let qDelegate = questionDelegate else {
            fatalError("QuestionViewController has no questionDelegate assigned")
        }

        nextButton?.alpha = 0

        let answers = collectionViewDataSource.selectedAnswerIds
        let selectedResult = SelectedResult(questionId: question.identifier,
                                    resultIds: Array(answers))
        let updateDelegateSelection = {
            qDelegate.questionViewController(self,
                                             didSelect: selectedResult)
        }

        guard let answerIndex = question.results.index(of: answer) else {
            updateDelegateSelection()
            return
        }

        guard let cell = collectionView.cellForItem(at: IndexPath(item: answerIndex, section: 0))
            as? SurveyAnswerCollectionViewCell else {
                KLogError(KinitErrorCodes.selectedAnswerCellNotFound.rawValue, domain: KinErrorDomain)
                return
        }

        let celebrationToUse = celebration(forSelecting: answer)
        switch celebrationToUse {
        case .centeredEmoji(let emojiString):
            celebrateCenteredEmoji(at: cell, with: emojiString, completion: updateDelegateSelection)
        case .particles(let images):
            celebrateParticles(from: cell, with: images, completion: updateDelegateSelection)
        case .quiz(let correctAnswerId):
            let correctAnswerIndex = question.results.index(where: { $0.identifier == correctAnswerId })!
            let correctAnswerCell: SurveyAnswerCollectionViewCell

            if cell.indexPath.item == correctAnswerIndex {
                correctAnswerCell = cell
            } else {
                let indexPath = IndexPath(item: correctAnswerIndex, section: 0)
                //swiftlint:disable:next force_cast
                correctAnswerCell = collectionView.cellForItem(at: indexPath) as! SurveyAnswerCollectionViewCell
            }

            celebrateQuizAnswer(selected: cell, correct: correctAnswerCell, completion: updateDelegateSelection)
        default:
            updateDelegateSelection()
        }
    }

    func surveyAnswerCellDidStartSelecting(_ cell: SurveyAnswerCollectionViewCell) {
        enableCellsInteraction(false)
        cell.isUserInteractionEnabled = true
    }

    func surveyAnswerCellDidCancelSelecting(_ cell: SurveyAnswerCollectionViewCell) {
        enableCellsInteraction(true)
    }

    private func enableCellsInteraction(_ enable: Bool) {
        collectionView.visibleCells
            .forEach { $0.isUserInteractionEnabled = enable }
    }
}
