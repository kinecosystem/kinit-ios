//
//  TaskCompletedViewController.swift
//  Kinit
//

import UIKit
import Lottie
import KinCoreSDK
import KinUtil
import KinitDesignables

extension Notification.Name {
    static let transactionCompleted = Notification.Name(rawValue: "org.kinecosystem.txCompleted")
}

final class TaskCompletedViewController: UIViewController {
    var task: Task!
    var results: TaskResults?
    var watch: PaymentWatch?
    var notificationObserver: NSObjectProtocol?
    let linkBag = LinkBag()
    var failedToSubmitResults = false
    var initialBalance: UInt64!
    var targetBalance: UInt64!
    var processedSuccess = false
    weak var surveyDelegate: SurveyViewControllerDelegate?

    @IBOutlet weak var backgroundGradientView: GradientView! {
        didSet {
            backgroundGradientView.direction = .vertical
            backgroundGradientView.colors = UIColor.blueGradientColors1
        }
    }

    deinit {
        watch = nil
        notificationObserver = nil
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.hidesBackButton = true

        initialBalance = Kin.shared.balance

        if results != nil {
            submitResults()
        } else {
            watchPayment()
        }

        logViewedDone()
        addAndFit(StoryboardScene.Earn.surveyDoneViewController.instantiate())
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        navigationController?.setNavigationBarHidden(true, animated: animated)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            if !self.failedToSubmitResults {
                self.moveToTransferring()
            }
        }
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    private func submitResults() {
        guard let results = results else {
            fatalError("submitResults was called when `results` was nil")
        }

        let tResults = results.applyingAddress(Kin.shared.publicAddress)
        WebRequests.submitTaskResults(tResults)
            .withCompletion { [weak self] success, error in
                guard let self = self else {
                    return
                }

                guard success.boolValue else {
                    self.failedToSubmitResults = true
                    KLogError(String(describing: error?.localizedDescription))
                    DispatchQueue.main.async {
                        self.errorSubmitingResults()
                    }

                    return
                }

                KLogVerbose("Success submitting results for task.")

                self.watchPayment()
            }.load(with: KinWebService.shared)
    }

    private func watchPayment() {
        if let results = results {
            SimpleDatastore.delete(results)
        }

        DataLoaders.tasks.markTaskFinished(taskId: task.identifier, categoryId: task.categoryId)
        DataLoaders.tasks.loadTasks(for: task.categoryId)

        let memo = task.memo

        notificationObserver = NotificationCenter.default.addObserver(forName: .transactionCompleted,
                                                                      object: nil,
                                                                      queue: nil) { [weak self] note in
            guard let self = self,
                let kinData = note.userInfo as? [String: Any],
                let txData = kinData["tx_data"] as? [String: Any],
                let amount = txData["kin"] as? UInt64,
                let pushMemo = txData["memo"] as? String,
                pushMemo == memo,
                let txHash = txData["tx_hash"] as? String else {
                    return
            }

            self.transactionSucceeded(with: amount, txId: txHash)
        }

        watch = try? Kin.shared.watch(cursor: nil)
        watch?.emitter
            .filter { $0.memoText == memo }
            .on(queue: DispatchQueue.main, next: { [weak self] paymentInfo in
                guard let self = self else {
                    return
                }

                Kin.shared.refreshBalance()

                let paymentAmount = (paymentInfo.amount as NSDecimalNumber).uint64Value
                self.transactionSucceeded(with: paymentAmount, txId: paymentInfo.hash)
            }).add(to: linkBag)

        let timeout: TimeInterval

        #if DEBUG
        timeout = 8
        #else
        timeout = 30
        #endif

        DispatchQueue.main.asyncAfter(deadline: .now() + timeout) { [weak self] in
            guard let self = self, self.watch != nil else {
                return
            }

            self.transactionTimedOut()
        }
    }

    private func transactionTimedOut() {
        logEarnTransactionTimeout()

        Kin.shared.refreshBalance()
        DataLoaders.kinit.loadTransactions()

        notificationObserver = nil
        watch = nil

        let message =
        """
            We have received your results but something got stuck along the way.

            Please tap close and check your balance in a few hours. If no change has ocurred, contact support.
            """
        let buttonConfig = NoticeButtonConfiguration(title: "Close", mode: .stroke)
        let noticeViewController = StoryboardScene.Main.noticeViewController.instantiate()
        noticeViewController.delegate = self
        noticeViewController.notice = Notice(image: Asset.paymentDelay.image,
                                             title: "Your Kin is on its way with a brief delay",
                                             subtitle: message,
                                             buttonConfiguration: buttonConfig,
                                             displayType: .imageFirst)
        present(noticeViewController, animated: true)
        logViewedErrorPage(errorType: .reward)
    }

    private func moveToTransferring() {
        guard let doneViewController = children.first else {
            return
        }

        logTransferringKinEvent()
        let transferringViewController = StoryboardScene.Earn.transferringKinViewController.instantiate()
        transferringViewController.initialBalance = initialBalance

        transferringViewController.finishTapped = { [weak self] in
            guard let aSelf = self else {
                return
            }

            aSelf.logClosedEvent()
            aSelf.surveyDelegate?.surveyViewControllerDidFinish(task: aSelf.task)
        }

        addAndFit(transferringViewController) {
            $0.alpha = 0
        }

        UIView.animate(withDuration: 0.35, animations: {
            doneViewController.view.alpha = 0
        }, completion: { _ in
            doneViewController.remove()
            UIView.animate(withDuration: 0.35) {
                transferringViewController.view.alpha = 1
            }
        })
    }

    private func transactionSucceeded(with paymentAmount: UInt64, txId: String) {
        notificationObserver = nil
        watch = nil

        guard let transferringViewController = children.first as? TransferringKinViewController else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.transactionSucceeded(with: paymentAmount, txId: txId)
            }
            return
        }

        guard !processedSuccess else {
            return
        }

        processedSuccess = true

        targetBalance = initialBalance + paymentAmount
        DataLoaders.kinit.loadTransactions()

        logEarnTransactionSucceded(with: paymentAmount, txId: txId)
        Analytics.incrementEarnCount()
        Analytics.incrementTransactionCount()
        Analytics.incrementTotalEarned(by: Int(paymentAmount))

        transferringViewController.transactionSucceeded(newBalance: targetBalance)

        logKinTransferred()
    }

    private func errorSubmitingResults() {
        let viewController = StoryboardScene.Main.noticeViewController.instantiate()
        viewController.delegate = self

        let buttonConfig = NoticeButtonConfiguration(title: L10n.closeAction, mode: .stroke)
        viewController.notice = Notice(image: Asset.errorSign.image,
                                       title: L10n.taskSubmissionFailedErrorTitle,
                                       subtitle: L10n.taskSubmissionFailedErrorMessage,
                                       buttonConfiguration: buttonConfig,
                                       displayType: .imageFirst)

        present(viewController, animated: true)

        logViewedErrorPage(errorType: .taskSubmission)
    }
}

extension TaskCompletedViewController {
    fileprivate func logViewedDone() {
        Events.Analytics
            .ViewTaskEndPage(creator: task.author.name,
                             estimatedTimeToComplete: task.minutesToComplete,
                             kinReward: Int(task.kinReward),
                             taskCategory: task.tags.asString,
                             taskId: task.identifier,
                             taskTitle: task.title,
                             taskType: task.type.toBITaskType())
            .send()
    }

    fileprivate func logTransferringKinEvent() {
        Events.Analytics
            .ViewRewardPage(creator: task.author.name,
                            estimatedTimeToComplete: task.minutesToComplete,
                            kinReward: Int(task.kinReward),
                            taskCategory: task.tags.asString,
                            taskId: task.identifier,
                            taskTitle: task.title,
                            taskType: task.type.toBITaskType())
            .send()
    }

    fileprivate func logKinTransferred() {
        Events.Analytics
            .ViewKinProvidedImageOnRewardPage(creator: task.author.name,
                                              estimatedTimeToComplete: task.minutesToComplete,
                                              kinReward: Int(task.kinReward),
                                              taskCategory: task.tags.asString,
                                              taskId: task.identifier,
                                              taskTitle: task.title,
                                              taskType: task.type.toBITaskType())
            .send()
    }

    fileprivate func logClosedEvent() {
        Events.Analytics
            .ClickCloseButtonOnRewardPage(creator: task.author.name,
                                          estimatedTimeToComplete: task.minutesToComplete,
                                          kinReward: Int(task.kinReward),
                                          taskCategory: task.tags.asString,
                                          taskId: task.identifier,
                                          taskTitle: task.title,
                                          taskType: task.type.toBITaskType())
            .send()
    }

    fileprivate func logEarnTransactionTimeout() {
        Events.Business
            .KINTransactionFailed(failureReason: "Timeout",
                                                         kinAmount: Float(task.kinReward),
                                                         transactionType: .earn)
            .send()
    }

    fileprivate func logEarnTransactionSucceded(with amount: UInt64, txId: String) {
        Events.Business
            .KINTransactionSucceeded(kinAmount: Float(amount),
                                     transactionId: txId,
                                     transactionType: .earn)
            .send()
    }

    fileprivate func logViewedErrorPage(errorType: Events.ErrorType) {
        Events.Analytics
            .ViewErrorPage(errorType: errorType)
            .send()
    }

    fileprivate func logClickedCloseErrorPage(errorType: Events.ErrorType) {
        Events.Analytics
            .ClickCloseButtonOnErrorPage(errorType: errorType)
            .send()
    }
}

extension TaskCompletedViewController: NoticeViewControllerDelegate {
    func noticeViewControllerDidTapButton(_ viewController: NoticeViewController) {
        logClickedCloseErrorPage(errorType: failedToSubmitResults ? .taskSubmission : .reward)
        surveyDelegate?.surveyViewControllerDidFinish(task: failedToSubmitResults ? nil : task)
    }
}
