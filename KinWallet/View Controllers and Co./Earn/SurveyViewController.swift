//
//  SurveyViewController.swift
//  KinWallet
//
//  Copyright © 2018 KinFoundation. All rights reserved.
//

import UIKit

protocol SurveyViewControllerDelegate: class {
    func surveyViewController(_ viewController: SurveyViewController, didCancelWith results: TaskResults)
    func surveyViewController(_ viewController: SurveyViewController, didFinishWith results: TaskResults)
}

private enum SurveyTransitionState {
    case appearing
    case showing
    case disappearing
}

private struct Constants {
    struct ProgressView {
        static let height: CGFloat = 4
        static let width: CGFloat = {
            return UIScreen.main.bounds.width * 0.65
        }()
    }

    struct QuestionChangeAnimation {
        static let duration = 0.6
    }

    struct ProgressLabelTransition {
        static let duration = 0.4
    }

    struct ProgressViewAnimation {
        static let duration = 0.8
        static let springDamping: CGFloat = 0.7
        static let velocity: CGFloat = 0.9
    }
}

final class SurveyViewController: UIViewController {
    private let task: Task
    private let progressLabel: UILabel = {
        let l = UILabel(frame: CGRect(x: 0, y: 0, width: 40, height: 16))
        l.textAlignment = .right
        l.font = FontFamily.Roboto.regular.font(size: 14)
        l.textColor = .white
        return l
    }()

    fileprivate let progressView: UIProgressView = {
        let p = UIProgressView(progressViewStyle: .bar)
        p.trackImage = Asset.progressViewTrack.image
        p.progressImage = Asset.progressViewGradient.image
        p.widthAnchor.constraint(equalToConstant: Constants.ProgressView.width).isActive = true
        p.heightAnchor.constraint(equalToConstant: Constants.ProgressView.height).isActive = true

        return p
    }()

    private(set) weak var surveyDelegate: SurveyViewControllerDelegate?
    private(set) var currentQuestionIndex = 0
    private var selectedAnswers = [SelectedAnswer]()

    class func embeddedInNavigationController(with task: Task,
                                              delegate: SurveyViewControllerDelegate) -> UINavigationController {
        let surveyVC = SurveyViewController(task: task, delegate: delegate)
        return KinNavigationController(rootViewController: surveyVC)
    }

    init(task: Task, delegate: SurveyViewControllerDelegate) {
        self.task = task
        self.surveyDelegate = delegate

        super.init(nibName: nil, bundle: nil)

        navigationItem.leftBarButtonItem = UIBarButtonItem(image: Asset.closeXButton.image,
                                                           style: .plain,
                                                           target: self,
                                                           action: #selector(cancelTapped(_:)))
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: progressLabel)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .white
        navigationItem.titleView = progressView

        loadCurrentProgress()
    }

    @objc func cancelTapped(_ sender: UIBarButtonItem) {
        logClosedOnQuestion(task.questions[currentQuestionIndex],
                            questionIndex: currentQuestionIndex)
        let results = TaskResults(identifier: task.identifier,
                                  results: selectedAnswers)
        surveyDelegate?.surveyViewController(self, didCancelWith: results)
    }

    func loadCurrentProgress() {
        SimpleDatastore.loadObject(task.identifier) { (tResults: TaskResults?) in
            DispatchQueue.main.async {
                if let tResults = tResults {
                    self.selectedAnswers = tResults.results
                    self.currentQuestionIndex = tResults.results.count
                }

                self.showNextQuestion()
            }
        }
    }

    func showNextQuestion() {
        let numberOfQuestions = task.questions.count
        guard currentQuestionIndex < task.questions.count else {
            return
        }

        let question = task.questions[currentQuestionIndex]
        let animateProgress: Bool

        if let current = childViewControllers.first as? QuestionViewController {
            let questionViewController = QuestionViewController(question: question,
                                                                questionDelegate: self,
                                                                isInitialQuestion: false)
            let width = view.frame.width
            addAndFit(questionViewController)
            questionViewController.view.applyTransitionAttributes(for: .appearing, width: width)

            UIView.animateKeyframes(withDuration: Constants.QuestionChangeAnimation.duration,
                                    delay: 0.1,
                                    options: [],
                                    animations: {
                UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 0.5) {
                    current.view.applyTransitionAttributes(for: .disappearing, width: width)
                }
                UIView.addKeyframe(withRelativeStartTime: 0.4, relativeDuration: 1.0) {
                    questionViewController.view.applyTransitionAttributes(for: .showing, width: 0)
                }
            }, completion: { _ in
                current.remove()
            })

            animateProgress = true
        } else {
            let questionViewController = QuestionViewController(question: question,
                                                                questionDelegate: self,
                                                                isInitialQuestion: true)
            addAndFit(questionViewController)
            animateProgress = false
        }

        let progress = Float(currentQuestionIndex)/Float(numberOfQuestions)
        updateProgress(progress, animated: animateProgress)
        logQuestionShown(question, at: currentQuestionIndex)
    }

    func updateProgress(_ progress: Float, animated: Bool, completion: (() -> Void)? = nil) {
        let percentText = "\(Int(progress*100))%"

        if !animated {
            progressLabel.text = percentText
            progressView.setProgress(progress, animated: false)
            completion?()
            return
        }

        let duration = Constants.ProgressViewAnimation.duration

        UIView.transition(with: progressLabel,
                          duration: Constants.ProgressLabelTransition.duration,
                          options: .transitionCrossDissolve,
                          animations: {
            self.progressLabel.text = percentText
        }, completion: nil)

        UIView.animate(withDuration: duration,
                       delay: 0,
                       usingSpringWithDamping: Constants.ProgressViewAnimation.springDamping,
                       initialSpringVelocity: Constants.ProgressViewAnimation.velocity,
                       options: [], animations: {
                        self.progressView.setProgress(progress, animated: true)
        }, completion: nil)

        //weird bug that I have no explanation for it:
        //UIView animation completion fires right away
        //This is why I'm using GCD to fire the completion block
        if let completion = completion {
            DispatchQueue.main.asyncAfter(deadline: .now() + duration, execute: completion)
        }
    }

    func showSurveyComplete(results: TaskResults) {
        let surveyComplete = StoryboardScene.Earn.surveyCompletedViewController.instantiate()
        surveyComplete.task = task
        surveyComplete.results = results
        navigationController?.pushViewController(surveyComplete, animated: true)
    }

    func logTaskCompleted() {
        let event = Events.Business.EarningTaskCompleted(creator: task.author.name,
                                                         estimatedTimeToComplete: task.minutesToComplete,
                                                         kinReward: Int(task.kinReward),
                                                         taskCategory: task.tags.asString,
                                                         taskId: task.identifier,
                                                         taskTitle: task.title,
                                                         taskType: .questionnaire)
        Analytics.logEvent(event)
    }
}

extension SurveyViewController: QuestionViewControllerDelegate {
    func questionViewController(_ viewController: QuestionViewController, didSelect selectedAnswer: SelectedAnswer) {
        viewController.view.isUserInteractionEnabled = false

        let question = task.questions[currentQuestionIndex]
        let answerIds = selectedAnswer.resultIds.asString

        let answerIndex: Int?

        if question.allowsMultipleSelection {
            answerIndex = nil
        } else {
            answerIndex = question.results.enumerated()
                .filter { $0.element.identifier == selectedAnswer.resultIds.first }
                .first?.offset
        }

        logQuestionAnswered(question,
                            questionIndex: currentQuestionIndex,
                            answerIds: answerIds,
                            answerIndex: answerIndex)

        selectedAnswers.append(selectedAnswer)
        let results = TaskResults(identifier: task.identifier,
                                   results: selectedAnswers)
        SimpleDatastore.persist(results)

        currentQuestionIndex = selectedAnswers.count

        if currentQuestionIndex < task.questions.count {
            showNextQuestion()
        } else {
            updateProgress(1, animated: true) {
                self.showSurveyComplete(results: results)
            }
            logTaskCompleted()
        }
    }
}

// MARK: Analytics
extension SurveyViewController {
    func logQuestionShown(_ question: Question, at questionIndex: Int) {
        let event = Events.Analytics
            .ViewQuestionPage(creator: task.author.name,
                estimatedTimeToComplete: task.minutesToComplete,
                kinReward: Int(task.kinReward),
                numberOfQuestions: task.questions.count,
                questionId: question.identifier,
                questionOrder: questionIndex + 1,
                questionType: question.type == .text ? .text : .textImage,
                taskCategory: task.tags.asString,
                taskId: task.identifier,
                taskTitle: task.title)
        Analytics.logEvent(event)
    }

    func logQuestionAnswered(_ question: Question, questionIndex: Int, answerIds: String, answerIndex: Int?) {
        let event = Events.Analytics
            .ClickAnswerButtonOnQuestionPage(answerId: answerIds,
                                             answerOrder: answerIndex != nil ? answerIndex! + 1 : -1,
                                             creator: task.author.name,
                                             estimatedTimeToComplete: task.minutesToComplete,
                                             kinReward: Int(task.kinReward),
                                             numberOfAnswers: question.results.count,
                                             numberOfQuestions: task.questions.count,
                                             questionId: question.identifier,
                                             questionOrder: questionIndex + 1,
                                             questionType: question.type.toBIQuestionType(),
                                             taskCategory: task.tags.asString,
                                             taskId: task.identifier,
                                             taskTitle: task.title)
        Analytics.logEvent(event)
    }

    func logClosedOnQuestion(_ question: Question, questionIndex: Int) {
        let event = Events.Analytics
            .ClickCloseButtonOnQuestionPage(creator: task.author.name,
                                            estimatedTimeToComplete: task.minutesToComplete,
                                            kinReward: Int(task.kinReward),
                                            numberOfAnswers: question.results.count,
                                            numberOfQuestions: task.questions.count,
                                            questionId: question.identifier,
                                            questionOrder: questionIndex + 1,
                                            questionType: question.type == .text ? .text : .textImage,
                                            taskCategory: task.tags.asString,
                                            taskId: task.identifier,
                                            taskTitle: task.title)
        Analytics.logEvent(event)
    }
}

fileprivate extension UIView {
    func applyTransitionAttributes(for state: SurveyTransitionState, width: CGFloat = 0) {
        switch state {
        case .showing:
            alpha = 1
            transform = .identity
        case .appearing, .disappearing:
            alpha = 0
            transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
        }
    }
}

fileprivate extension QuestionType {
    func toBIQuestionType() -> Events.QuestionType {
        switch self {
        case .multipleText:
            return .textMultiple
        case .textAndImage:
            return .textImage
        case .textEmoji:
            return .textEmoji
        case .text:
            return .text
        }
    }
}
