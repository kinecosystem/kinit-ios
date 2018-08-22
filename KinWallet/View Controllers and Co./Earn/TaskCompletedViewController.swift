//
//  TaskCompletedViewController.swift
//  Kinit
//

import UIKit
import Lottie
import KinCoreSDK
import KinUtil
import KinitDesignables

final class TaskCompletedViewController: UIViewController {
    var task: Task!
    var results: TaskResults?
    var watch: PaymentWatch?
    let linkBag = LinkBag()
    var failedToSubmitResults = false
    var initialBalance: UInt64!
    var targetBalance: UInt64!

    @IBOutlet weak var backgroundGradientView: GradientView! {
        didSet {
            backgroundGradientView.direction = .vertical
            backgroundGradientView.colors = UIColor.blueGradientColors1
        }
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
                guard let `self` = self else {
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

        KinLoader.shared.deleteCachedAndFetchNextTask()

        let memo = task.memo
        watch = try? Kin.shared.watch(cursor: nil)
        watch?.emitter
            .filter { $0.memoText == memo }
            .on(queue: DispatchQueue.main, next: { [weak self] paymentInfo in
                guard let aSelf = self else {
                    return
                }

                let paymentAmount = (paymentInfo.amount as NSDecimalNumber).uint64Value
                aSelf.targetBalance = aSelf.initialBalance + paymentAmount
                KinLoader.shared.loadTransactions()

                aSelf.watch = nil
                aSelf.logEarnTransactionSucceded(with: paymentInfo)
                Analytics.incrementEarnCount()
                Analytics.incrementTransactionCount()
                Analytics.incrementTotalEarned(by: Int(paymentAmount))

                aSelf.transactionSucceeded()
            }).add(to: linkBag)

        DispatchQueue.main.asyncAfter(deadline: .now() + 20) { [weak self] in
            guard let `self` = self, self.watch != nil else {
                return
            }

            self.transactionTimedOut()
        }
    }

    private func transactionTimedOut() {
        logEarnTransactionTimeout()

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
        guard let doneViewController = childViewControllers.first else {
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
            aSelf.dismiss(animated: true)
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

    private func transactionSucceeded() {
        guard let transferringViewController = childViewControllers.first as? TransferringKinViewController else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.transactionSucceeded()
            }
            return
        }

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

    fileprivate func logEarnTransactionSucceded(with payment: PaymentInfo) {
        Events.Business
            .KINTransactionSucceeded(kinAmount: Float(task.kinReward),
                                                            transactionId: payment.hash,
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
        presentingViewController!.dismiss(animated: true)
    }
}
