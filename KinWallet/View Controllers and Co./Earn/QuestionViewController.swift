//
//  QuestionViewController.swift
//  KinWallet
//
//  Copyright © 2018 KinFoundation. All rights reserved.
//

import UIKit

typealias SelectedAnswer = SelectedResult

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
}

final class QuestionViewController: UIViewController {
    let question: Question
    fileprivate let collectionViewDataSource: QuestionCollectionViewDataSource
    let collectionView: UICollectionView
    let isInitialQuestion: Bool
    let nextButton: UIButton?
    private(set) weak var questionDelegate: QuestionViewControllerDelegate?

    let layout: UICollectionViewFlowLayout = {
        let l = AnswersCollectionViewLayout()
        l.scrollDirection = .vertical

        return l
    }()

    init(question: Question, questionDelegate: QuestionViewControllerDelegate, isInitialQuestion: Bool) {
        self.questionDelegate = questionDelegate
        self.question = question
        self.isInitialQuestion = isInitialQuestion
        nextButton = question.allowsMultipleSelection ? UIButton(type: .system) : nil

        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .white
        collectionView.allowsSelection = true
        collectionView.allowsMultipleSelection = question.allowsMultipleSelection
        collectionView.register(nib: SurveyQuestionCollectionViewCell.self)
        collectionView.register(nib: SurveyTextAnswerCollectionViewCell.self)
        collectionView.register(nib: SurveyMultipleTextAnswerCollectionViewCell.self)
        collectionView.register(nib: SurveyTextImageAnswerCollectionViewCell.self)
        collectionViewDataSource = QuestionCollectionViewDataSource(question: question,
                                                                    collectionView: collectionView)

        super.init(nibName: nil, bundle: nil)

        collectionViewDataSource.questionViewController = self

        if let nextButton = nextButton {
            nextButton.isEnabled = false
            nextButton.setTitle("Next", for: .normal)
            nextButton.titleLabel?.font = FontFamily.Roboto.regular.font(size: 18)
            nextButton.addTarget(self,
                                 action: #selector(questionFinished),
                                 for: .touchUpInside)
            addCollectionViewAndButton(nextButton)
        } else {
            view.addAndFit(collectionView, layoutReference: .safeArea)
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        animateAnswerInsertions()
    }

    func addCollectionViewAndButton(_ button: UIButton) {
        let viewGuides: UILayoutGuide

        if #available(iOS 11.0, *) {
            viewGuides = view.safeAreaLayoutGuide
        } else {
            viewGuides = view.layoutMarginsGuide
        }

        let buttonContainer = UIView()
        buttonContainer.backgroundColor = .white
        buttonContainer.applyThinShadow()
        buttonContainer.translatesAutoresizingMaskIntoConstraints = false
        buttonContainer.addAndFit(button)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(collectionView)
        view.addSubview(buttonContainer)

        let constraints = [
            viewGuides.topAnchor.constraint(equalTo: collectionView.topAnchor),
            viewGuides.leadingAnchor.constraint(equalTo: collectionView.leadingAnchor),
            viewGuides.trailingAnchor.constraint(equalTo: collectionView.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: buttonContainer.topAnchor),
            viewGuides.leadingAnchor.constraint(equalTo: buttonContainer.leadingAnchor),
            viewGuides.trailingAnchor.constraint(equalTo: buttonContainer.trailingAnchor),
            viewGuides.bottomAnchor.constraint(equalTo: buttonContainer.bottomAnchor),
            buttonContainer.heightAnchor.constraint(equalToConstant: Constants.nextButtonHeight)
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
                                          section: QuestionnaireSections.answers.rawValue)
                self.collectionView.insertItems(at: [indexPath])
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + Constants.answersInsertionIntervalDuration) {
                self.animateNextAnswerInsertion()
            }
        } else {
            collectionView.flashScrollIndicators()
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
        guard !collectionViewDataSource.selectedAnswerIds.isEmpty else {
            return
        }

        guard let qDelegate = questionDelegate else {
            fatalError("QuestionViewController has no questionDelegate assigned")
        }

        nextButton?.alpha = 0

        let answers = collectionViewDataSource.selectedAnswerIds
        let result = SelectedResult(taskId: question.identifier,
                                    resultIds: Array(answers))
        qDelegate.questionViewController(self,
                                         didSelect: result)
    }

    func surveyAnswerCellDidStartSelecting(_ cell: SurveyAnswerCollectionViewCell) {
        enableCellsInteraction(false)
        cell.isUserInteractionEnabled = true
    }

    func surveyAnswerCellDidCancelSelecting(_ cell: SurveyAnswerCollectionViewCell) {
        enableCellsInteraction(true)
    }

    func enableCellsInteraction(_ enable: Bool) {
        collectionView.visibleCells
            .forEach { $0.isUserInteractionEnabled = enable }
    }
}
