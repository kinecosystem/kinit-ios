//
//  SurveyHomeViewController.swift
//  Kinit
//

import UIKit
import KinUtil
import SafariServices

final class SurveyHomeViewController: UIViewController {
    var shouldShowEarnAnimation = true
    var animatingEarn = false
    let linkBag = LinkBag()
    var task: Task?

    var backupFlowController: BackupFlowController?

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

//        renderCurrentTask(DataLoaders.kinit.currentTask.value ?? .none(nil))
//
//        DataLoaders.kinit.currentTask
//            .on(queue: .main, next: renderCurrentTask)
//            .add(to: linkBag)

        addBalanceLabel()

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(splashScreenWillDismiss),
                                               name: .SplashScreenWillDismiss,
                                               object: nil)

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(applicationWillEnterForeground),
                                               name: UIApplication.willEnterForegroundNotification,
                                               object: nil)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        showTaskIfAvailable()
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    private func renderCurrentTask(_ taskResult: FetchResult<Task>) {
        switch taskResult {
        case .none(let error):
            self.task = nil
            showTaskUnavailable(nil, error: error)
        case .some(let task):
            self.task = task
            renderTask(task)
        }
    }

    private func renderTask(_ task: Task) {
        if task.isAvailable {
            showTaskAvailable(task)
        } else {
            showTaskUnavailable(task, error: nil)
        }
    }

    @objc func applicationWillEnterForeground() {
        showTaskIfAvailable()
    }

    func showTaskIfAvailable() {
        guard
            let task = task,
            children.first(where: { $0 is SurveyUnavailableViewController }) != nil,
            task.isAvailable else {
            return
        }

        renderTask(task)
    }

    func showTaskAvailable(_ task: Task) {
        assert(task.isAvailable, "showTaskAvailable received a task that is not ready to be displayed.")

        (children.first as? SurveyUnavailableViewController)?.remove()

        let surveyInfo: SurveyInfoViewController

        if let existingSurveyInfo = children.first as? SurveyInfoViewController {
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
        guard let surveyInfo = children.first as? SurveyInfoViewController else {
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
        children.forEach { $0.remove() }

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

    func surveyViewControllerDidFinish(task: Task?) {
        if let actionIconURL = task?.actions?.first?.iconURL {
            ResourceDownloader.shared.requestResource(url: actionIconURL.kinImagePathAdjustedForDevice())
        }

        dismissAnimated { [weak self] in
            guard let task = task else {
                return
            }

            if let action = task.actions?.first,
                action.url != nil && action.type == .externalURL {
                self?.showPostTaskAction(action, taskId: task.identifier)
            } else {
                self?.showBackupNagIfNeeded()
            }
        }
    }

    fileprivate func showBackupNagIfNeeded() {
        guard
            !Kin.performedBackup(),
            let backupNagEnabled = RemoteConfig.current?.backupNag,
            backupNagEnabled else {
                return
        }

        defer {
            BackupNagCounter.incrementIfNeeded()
        }

        let currentNag = BackupNagCounter.count

        guard let nagDay = BackupNagDay(rawValue: currentNag) else {
            return
        }

        let backupNagViewController = BackupNagViewController(nagDay: nagDay) { [weak self] in
            self?.backupNagDidSelectBackupNow(nagDay: nagDay)
        }
        presentAnimated(backupNagViewController)
    }

    fileprivate func showPostTaskAction(_ action: PostTaskAction, taskId: String) {
        let iconImage: UIImage?

        if
            let iconURL = action.iconURL?.kinImagePathAdjustedForDevice(),
            let downloadedIconURL = ResourceDownloader.shared.downloadedResource(url: iconURL),
            let image = UIImage(contentsOfFile: downloadedIconURL.path) {
            iconImage = image
        } else {
            iconImage = nil
        }

        let actionName = action.actionName

        let primaryAction = KinAlertAction(title: action.textPositive) { [weak self] in
            self?.dismissAnimated { [weak self] in
                if let self = self, let url = action.url, action.type == .externalURL {
                    Events.Analytics
                        .ClickLinkButtonOnCampaignPopup(campaignName: actionName, taskId: taskId)
                        .send()
                    let safariViewController = SFSafariViewController(url: url)
                    self.presentAnimated(safariViewController)
                }
            }
        }

        let alertController = KinAlertController(title: action.title,
                                                 titleImage: iconImage,
                                                 message: action.message,
                                                 primaryAction: primaryAction,
                                                 secondaryAction: KinAlertAction(title: action.textNegative))
        presentAnimated(alertController)
        Events.Analytics
            .ViewCampaignPopup(campaignName: actionName, taskId: taskId)
            .send()
    }
}

extension SurveyHomeViewController {
    func backupNagDidSelectBackupNow(nagDay: BackupNagDay) {
        dismissAnimated { [weak self] in
            guard let self = self else {
                return
            }

            self.backupFlowController = BackupFlowController(presenter: self, source: .notificationNag(nagDay))
            self.backupFlowController?.delegate = self
            self.backupFlowController!.startBackup()
        }
    }

    func backupNagDidSelectBackupLater() {
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
