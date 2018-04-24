//
//  SurveyCompletedViewController.swift
//  KinWallet
//
//  Copyright © 2018 KinFoundation. All rights reserved.
//

import UIKit
import Lottie
import KinSDK
import KinUtil

class SurveyCompletedViewController: UIViewController {
    var task: Task!
    var results: TaskResults!
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
        targetBalance = initialBalance + UInt64(task.kinReward)

        submitResults()

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
        let tResults = results.applyingAddress(Kin.shared.publicAddress)
        WebRequests.submitTaskResults(tResults)
            .withCompletion { [weak self] memo, error in
                guard let aSelf = self else {
                    return
                }

                guard let memo = memo, error == nil else {
                    aSelf.failedToSubmitResults = true
                    KLogError(String(describing: error?.localizedDescription))
                    DispatchQueue.main.async {
                        aSelf.errorSubmitingResults()
                    }

                    return
                }

                KLogVerbose("Success submitting results for task. Memo is \(memo)")

                SimpleDatastore.delete(aSelf.results)
                KinLoader.shared.deleteNextTask()

                aSelf.watchPayment(with: memo)
            }.load(with: KinWebService.shared)
    }

    private func watchPayment(with memo: String) {
        watch = try? Kin.shared.watch(cursor: nil)
        watch?.emitter
            .filter { $0.memoText == memo }
            .on(next: { [weak self] paymentInfo in
                guard let aSelf = self else {
                    return
                }

                KinLoader.shared.loadTransactions()
                
                KLogVerbose("Transaction succeeded!")
                aSelf.watch = nil

                aSelf.logEarnTransactionSucceded(with: paymentInfo)

                Analytics.incrementEarnCount()
                Analytics.incrementTransactionCount()
                Analytics.incrementTotalEarned(by: Int((paymentInfo.amount as NSDecimalNumber).intValue))
            })
            .on(queue: DispatchQueue.main, next: { [weak self] _ in
                self?.transactionSucceeded()
            }).add(to: linkBag)

        DispatchQueue.main.asyncAfter(deadline: .now() + 20) { [weak self] in
            guard
                let aSelf = self,
                aSelf.watch != nil else {
                return
            }

            aSelf.logEarnTransactionTimeout()

            aSelf.watch = nil
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
            aSelf.present(noticeViewController, animated: true)

            Analytics.logEvent(Events.Analytics.ViewErrorPage(errorType: .reward))
        }
    }

    private func moveToTransferring() {
        guard let doneViewController = childViewControllers.first else {
            return
        }

        logTransferringKinEvent()
        let transferringViewController = StoryboardScene.Earn.transferringKinViewController.instantiate()
        transferringViewController.initialBalance = initialBalance
        transferringViewController.targetBalance = targetBalance
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

        logKinTransferred()
        transferringViewController.transactionSucceeded()
    }

    private func errorSubmitingResults() {
        let viewController = StoryboardScene.Main.noticeViewController.instantiate()
        viewController.delegate = self
        let subtitle =
        """
        To receive your Kin, please do the following:
        Hit close and continue on the next screen so we can make sure you get your Kin.
        """
        let buttonConfig = NoticeButtonConfiguration(title: "Close", mode: .stroke)
        viewController.notice = Notice(image: Asset.errorSign.image,
                                       title: "Error Submiting Answers",
                                       subtitle: subtitle,
                                       buttonConfiguration: buttonConfig,
                                       displayType: .imageFirst)

        present(viewController, animated: true)

        Analytics.logEvent(Events.Analytics.ViewErrorPage(errorType: .taskSubmission))
    }
}

extension SurveyCompletedViewController {
    func logViewedDone() {
        let event = Events.Analytics
            .ViewTaskEndPage(creator: task.author.name,
                             estimatedTimeToComplete: task.minutesToComplete,
                             kinReward: Int(task.kinReward),
                             taskCategory: task.tags.asString,
                             taskId: task.identifier,
                             taskTitle: task.title,
                             taskType: .questionnaire)
        Analytics.logEvent(event)
    }

    func logTransferringKinEvent() {
        let event = Events.Analytics
            .ViewRewardPage(creator: task.author.name,
                            estimatedTimeToComplete: task.minutesToComplete,
                            kinReward: Int(task.kinReward),
                            taskCategory: task.tags.asString,
                            taskId: task.identifier,
                            taskTitle: task.title,
                            taskType: .questionnaire)
        Analytics.logEvent(event)
    }

    func logKinTransferred() {
        let event = Events.Analytics
            .ViewKinProvidedImageOnRewardPage(creator: task.author.name,
                                              estimatedTimeToComplete: task.minutesToComplete,
                                              kinReward: Int(task.kinReward),
                                              taskCategory: task.tags.asString,
                                              taskId: task.identifier,
                                              taskTitle: task.title,
                                              taskType: .questionnaire)
        Analytics.logEvent(event)
    }

    func logClosedEvent() {
        let event = Events.Analytics
            .ClickCloseButtonOnRewardPage(creator: task.author.name,
                                          estimatedTimeToComplete: task.minutesToComplete,
                                          kinReward: Int(task.kinReward),
                                          taskCategory: task.tags.asString,
                                          taskId: task.identifier,
                                          taskTitle: task.title,
                                          taskType: .questionnaire)
        Analytics.logEvent(event)
    }

    func logEarnTransactionTimeout() {
        let event = Events.Business.KINTransactionFailed(failureReason: "Timeout",
                                                         kinAmount: Float(task.kinReward),
                                                         transactionType: .earn)
        Analytics.logEvent(event)
    }

    func logEarnTransactionSucceded(with payment: PaymentInfo) {
        let event = Events.Business.KINTransactionSucceeded(kinAmount: Float(task.kinReward),
                                                            transactionId: payment.hash,
                                                            transactionType: .earn)
        Analytics.logEvent(event)
    }
}

extension SurveyCompletedViewController: NoticeViewControllerDelegate {
    func noticeViewControllerDidTapButton(_ viewController: NoticeViewController) {
        let errorType: Events.ErrorType = failedToSubmitResults ? .taskSubmission : .reward
        Analytics.logEvent(Events.Analytics.ClickCloseButtonOnErrorPage(errorType: errorType))

        presentingViewController!.dismiss(animated: true)
    }
}
