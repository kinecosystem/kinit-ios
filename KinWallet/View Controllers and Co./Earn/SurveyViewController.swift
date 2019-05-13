//
//  SurveyViewController.swift
//  Kinit
//

import UIKit

protocol SurveyViewControllerDelegate: class {
    func surveyViewControllerDidCancel()
    func surveyViewControllerDidFinish(task: Task?)
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
    private var finishedVideoReproduction = false

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
        p.translatesAutoresizingMaskIntoConstraints = false
        p.trackImage = Asset.progressViewTrack.image
        p.progressImage = Asset.progressViewGradient.image
        p.widthAnchor.constraint(equalToConstant: Constants.ProgressView.width).isActive = true
        p.heightAnchor.constraint(equalToConstant: Constants.ProgressView.height).isActive = true

        return p
    }()

    private(set) weak var surveyDelegate: SurveyViewControllerDelegate?
    private(set) var currentQuestionIndex = 0
    private var selectedAnswers = [SelectedAnswer]()

    private var currentChildViewController: UIViewController? {
        return children.first
    }

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

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    @objc func cancelTapped(_ sender: UIBarButtonItem) {
        logClosedOnQuestion(task.questions[min(currentQuestionIndex, task.questions.count - 1)],
                            questionIndex: currentQuestionIndex)
        surveyDelegate?.surveyViewControllerDidCancel()
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

        if let current = currentChildViewController {
            let questionViewController = QuestionViewController(question: question,
                                                                questionDelegate: self,
                                                                isInitialQuestion: false)
            insertNext(questionViewController, insteadOf: current)
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

    fileprivate func insertNext(_ viewController: UIViewController, insteadOf current: UIViewController) {
        let width = view.frame.width
        addAndFit(viewController)
        viewController.view.applyTransitionAttributes(for: .appearing, width: width)
        let duration = Constants.QuestionChangeAnimation.duration

        UIView.animateKeyframes(withDuration: duration, delay: 0.1, options: [], animations: {
            UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 0.5) {
                current.view.applyTransitionAttributes(for: .disappearing, width: width)
            }
            UIView.addKeyframe(withRelativeStartTime: 0.4, relativeDuration: 1.0) {
                viewController.view.applyTransitionAttributes(for: .showing, width: 0)
            }
        }, completion: nil)

        // When calling remove() in a UIViewController in the completion block,
        // apparently the view's safe area insets are changed immediately.
        // Doing so makes sure they are removed a few seconds later, which
        // has no harm and also don't change the safe area insets.
        DispatchQueue.main.asyncAfter(deadline: .now() + 4) { [weak current] in
            current?.remove()
        }
    }

    fileprivate func updateProgress(_ progress: Float, animated: Bool, completion: (() -> Void)? = nil) {
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
        let taskCompleted = StoryboardScene.Earn.taskCompletedViewController.instantiate()
        taskCompleted.surveyDelegate = surveyDelegate
        taskCompleted.task = task
        taskCompleted.results = results
        navigationController?.pushViewController(taskCompleted, animated: true)
    }
}

extension SurveyViewController: QuestionViewControllerDelegate {
    func questionViewController(_ viewController: QuestionViewController, didSelect selectedAnswer: SelectedAnswer) {
        guard !selectedAnswers.contains(where: { selectedAnswer.questionId == $0.questionId }) else {
            return
        }

        viewController.view.isUserInteractionEnabled = false

        let question = task.questions[currentQuestionIndex]
        let answerIds = selectedAnswer.resultIds.asString

        let answerIndex: Int?

        if question.allowsMultipleSelection {
            answerIndex = nil
        } else {
            answerIndex = question.results.enumerated()
                .first(where: { $0.element.identifier == selectedAnswer.resultIds.first })?
                .offset
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

        if let quizData = question.quizData {
            let quizQuestionExplanation = StoryboardScene.Earn.quizQuestionExplanationViewController.instantiate()
            quizQuestionExplanation.explanation = quizData.explanation
            quizQuestionExplanation.delegate = self
            insertNext(quizQuestionExplanation, insteadOf: currentChildViewController!)
        } else {
            moveToNextQuestionOrFinish(results: results)
        }
    }

    fileprivate func moveToNextQuestionOrFinish(results: TaskResults? = nil) {
        if currentQuestionIndex < task.questions.count {
            showNextQuestion()
        } else {
            let resultsToUse = results ?? TaskResults(identifier: task.identifier, results: selectedAnswers)
            updateProgress(1, animated: true) {
                self.showSurveyComplete(results: resultsToUse)
            }
            logTaskCompleted()
        }
    }
}

extension SurveyViewController: QuizQuestionExplanationDelegate {
    func quizQuestionExplanationDidTapNext() {
        moveToNextQuestionOrFinish()
    }
}

// MARK: Analytics
extension SurveyViewController {
    func logQuestionShown(_ question: Question, at questionIndex: Int) {
        Events.Analytics
            .ViewQuestionPage(creator: task.author.name,
                estimatedTimeToComplete: task.minutesToComplete,
                kinReward: Int(task.kinReward),
                numberOfQuestions: task.questions.count,
                questionId: question.identifier,
                questionOrder: questionIndex + 1,
                questionType: question.type == .text ? .text : .textImage,
                taskCategory: task.categoryNameOrId,
                taskId: task.identifier,
                taskTitle: task.title)
            .send()
    }

    func logQuestionAnswered(_ question: Question, questionIndex: Int, answerIds: String, answerIndex: Int?) {
        Events.Analytics
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
                                             taskCategory: task.categoryNameOrId,
                                             taskId: task.identifier,
                                             taskTitle: task.title)
            .send()
    }

    fileprivate func logClosedOnQuestion(_ question: Question, questionIndex: Int) {
        Events.Analytics
            .ClickCloseButtonOnQuestionPage(creator: task.author.name,
                                            estimatedTimeToComplete: task.minutesToComplete,
                                            kinReward: Int(task.kinReward),
                                            numberOfAnswers: question.results.count,
                                            numberOfQuestions: task.questions.count,
                                            questionId: question.identifier,
                                            questionOrder: questionIndex + 1,
                                            questionType: question.type == .text ? .text : .textImage,
                                            taskCategory: task.categoryNameOrId,
                                            taskId: task.identifier,
                                            taskTitle: task.title)
            .send()
    }

    fileprivate func logTaskCompleted() {
        Events.Business
            .EarningTaskCompleted(creator: task.author.name,
                                  estimatedTimeToComplete: task.minutesToComplete,
                                  kinReward: Int(task.kinReward),
                                  taskCategory: task.categoryNameOrId,
                                  taskId: task.identifier,
                                  taskTitle: task.title,
                                  taskType: task.type.toBITaskType())
            .send()
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
        case .multipleText: return .textMultiple
        case .textAndImage: return .textImage
        case .textEmoji: return .textEmoji
        case .text: return .text
        case .tip: return .tip
        case .dualImage: return .dualImage
        }
    }
}
