//
//  SurveyHomeViewController.swift
//  Kinit
//

import UIKit
import KinUtil

final class SurveyHomeViewController: UIViewController {
    var shouldShowEarnAnimation = true
    var animatingEarn = false
    let linkBag = LinkBag()

    var backupFlowController: BackupFlowController?

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        renderCurrentTask(KinLoader.shared.currentTask.value ?? .none(nil))

        KinLoader.shared.currentTask
            .on(queue: .main, next: renderCurrentTask)
            .add(to: linkBag)

        addBalanceLabel()

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(splashScreenWillDismiss),
                                               name: .SplashScreenWillDismiss,
                                               object: nil)
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    private func renderCurrentTask(_ taskResult: FetchResult<Task>) {
        switch taskResult {
        case .none(let error):
            showTaskUnavailable(nil, error: error)
        case .some(let task):
            renderTask(task)
        }
    }

    private func renderTask(_ task: Task) {
        if task.daysToUnlock() == 0 {
            showTaskAvailable(task)
        } else {
            showTaskUnavailable(task, error: nil)
        }
    }

    func showTaskAvailable(_ task: Task) {
        assert(task.daysToUnlock() == 0,
               "SurveyUnavailableViewController received a task that is ready to be displayed.")
        if let surveryUnavailable = childViewControllers.first as? SurveyUnavailableViewController {
            surveryUnavailable.remove()
        }

        let surveyInfo: SurveyInfoViewController

        if let existingSurveyInfo = childViewControllers.first as? SurveyInfoViewController {
            surveyInfo = existingSurveyInfo
            surveyInfo.task = task
        } else {
            surveyInfo = SurveyInfoViewController.instantiateFromStoryboard()
            surveyInfo.task = task
            surveyInfo.surveyDelegate = self
            addAndFit(surveyInfo)
        }

        showEarnAnimationIfNeeded(surveyInfo: surveyInfo)
    }

    @objc func splashScreenWillDismiss() {
        guard let surveyInfo = childViewControllers.first as? SurveyInfoViewController else {
            return
        }

        showEarnAnimationIfNeeded(surveyInfo: surveyInfo)
    }

    func showEarnAnimationIfNeeded(surveyInfo: SurveyInfoViewController) {
        guard
            !AppDelegate.shared.isShowingSplashScreen,
            shouldShowEarnAnimation,
            !animatingEarn else {
            return
        }

        let width = view.frame.width
        shouldShowEarnAnimation = false
        animatingEarn = true

        let earnAnimationViewController = StoryboardScene.Earn.earnKinAnimationViewController.instantiate()
        addAndFit(earnAnimationViewController)

        surveyInfo.view.transform = .init(translationX: width, y: 0)
        UIView.animate(withDuration: 0.7,
                       delay: 1.5,
                       options: [],
                       animations: {
                        earnAnimationViewController.view.transform = .init(translationX: -width, y: 0)
                        earnAnimationViewController.view.alpha = 0
                        surveyInfo.view.transform = .identity
        }, completion: { _ in
            earnAnimationViewController.remove()
            self.animatingEarn = false
        })
    }

    func showTaskUnavailable(_ task: Task?, error: Error?) {
        childViewControllers.forEach { $0.remove() }

        let surveyUnavailable = SurveyUnavailableViewController()
        surveyUnavailable.task = task
        surveyUnavailable.error = error
        add(surveyUnavailable) { $0.fitInSuperview(with: .safeArea) }
    }
}

extension SurveyHomeViewController: SurveyViewControllerDelegate {
    func surveyViewControllerDidCancel() {
        dismissAnimated()
    }

    func surveyViewControllerDidFinish() {
        dismissAnimated { [weak self] in
            self?.showBackupNagIfNeeded()
        }
    }

    fileprivate func showBackupNagIfNeeded() {
        guard
            !Kin.performedBackup(),
            let backupNagEnabled = RemoteConfig.current?.backupNag,
            backupNagEnabled,
            (childViewControllers.first as? SurveyUnavailableViewController) != nil else {
                return
        }

        defer {
            BackupNagCounter.incrementIfNeeded()
        }

        let currentNag = BackupNagCounter.count

        guard let nagDay = BackupNagDay(rawValue: currentNag) else {
            return
        }

        let backupNagViewController = StoryboardScene.Backup.backupNagViewController.instantiate()
        backupNagViewController.nagDay = nagDay
        backupNagViewController.delegate = self
        presentAnimated(backupNagViewController)
    }
}

extension SurveyHomeViewController: BackupNagDelegate {
    func backupNagDidSelectBackupNow(_ backupNagViewController: BackupNagViewController) {
        let nagDay = backupNagViewController.nagDay!
        dismissAnimated { [weak self] in
            guard let `self` = self else {
                return
            }

            self.backupFlowController = BackupFlowController(presenter: self, source: .notificationNag(nagDay))
            self.backupFlowController?.delegate = self
            self.backupFlowController!.startBackup()
        }
    }

    func backupNagDidSelectBackupLater(_ backupNagViewController: BackupNagViewController) {
        dismissAnimated()
    }
}

extension SurveyHomeViewController: BackupFlowDelegate {
    func backupFlowDidCancel() {
        backupFlowController = nil
    }

    func backupFlowDidFinish() {
        backupFlowController = nil
    }
}
