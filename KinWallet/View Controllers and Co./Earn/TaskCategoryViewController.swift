//
//  TaskCategoryViewController.swift
//  KinWallet
//
//  Copyright © 2018 KinFoundation. All rights reserved.
//

import UIKit
import KinUtil
import SafariServices

class TaskCategoryViewController: UIViewController {
    var categoryId: CategoryId!
    var navBarColor: UIColor?
    var headerImage: UIImage?
    var task: Task?
    var categoryName: String?
    private let linkBag = LinkBag()
    private let titleView = TaskCategoryTitleView.loadFromNib()
    fileprivate var previousNavigationBarImage: UIImage!
    fileprivate var backupFlowController: BackupFlowController?

    deinit {
        DataLoaders.tasks.releaseObservables(categoryId: categoryId)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .white
        navigationItem.titleView = titleView

        bindObservables()

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(applicationWillEnterForeground),
                                               name: UIApplication.willEnterForegroundNotification,
                                               object: nil)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if previousNavigationBarImage == nil {
            previousNavigationBarImage = navigationController?.navigationBar.backgroundImage(for: .default)!
        }

        if let color = navBarColor,
            let navBar = navigationController?.navigationBar,
            let backgroundColorImage = UIImage.from(color) {

            navBar.setBackgroundImage(backgroundColorImage, for: .default)

            if let headerImage = headerImage {
                let maxHeight = navigationController?.navigationBar.frame.maxY
                let categoryNavBarImage = backgroundColorImage.addingAnotherToBottomLeftCorner(headerImage,
                                                                                               maxHeight: maxHeight)
                navBar.setBackgroundImage(categoryNavBarImage, for: .default)
            }
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        showTaskIfAvailable()
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    private func bindObservables() {
        DataLoaders.tasks.categoryObservable(for: categoryId)
            .on(queue: .main, next: { [weak self] result in
                switch result {
                case .some(let category):
                    self?.reloadTitleView(with: category)
                case .none://(let error):
                    break
                }
            }).add(to: linkBag)

        DataLoaders.tasks.taskObservable(for: categoryId)
            .on(queue: .main, next: { [weak self] result in self?.renderTask(result) })
            .add(to: linkBag)
    }

    private func reloadTitleView(with category: TaskCategory) {
        categoryName = category.title

        let count = category.availableTasksCount
        titleView.titleLabel.text = category.title.capitalized
        titleView.tasksCountLabel.text = L10n.availableActivitesCount(count)
        titleView.tasksCountStackView.isHidden = count <= 1
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

    private func renderTask(_ taskResult: FetchResult<Task>) {
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

    func showTaskAvailable(_ task: Task) {
        assert(task.isAvailable, "TaskCategoryViewController received a task that is not ready to be displayed.")
        if let surveryUnavailable = children.first as? SurveyUnavailableViewController {
            surveryUnavailable.remove()
        }

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
    }

    func showTaskUnavailable(_ task: Task?, error: Error?) {
        children.forEach { $0.remove() }

        let surveyUnavailable = SurveyUnavailableViewController()
        surveyUnavailable.task = task
        surveyUnavailable.taskCategory = categoryName ?? categoryId
        surveyUnavailable.error = error
        add(surveyUnavailable) { $0.fitInSuperview(with: .safeArea) }
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

extension TaskCategoryViewController: KinNavigationControllerDelegate {
    func shouldPopViewController() -> Bool {
        navigationController?.navigationBar.setBackgroundImage(previousNavigationBarImage, for: .default)
        return true
    }
}

extension TaskCategoryViewController: SurveyViewControllerDelegate {
    func surveyViewControllerDidCancel() {
        dismissAnimated()
    }

    func surveyViewControllerDidFinish(task: Task?) {
        let action = task?.actions?.first
        if let actionIconURL = action?.iconURL {
            ResourceDownloader.shared.requestResource(url: actionIconURL.kinImagePathAdjustedForDevice())
        }

        dismissAnimated { [weak self] in
            if
                let aAction = action,
                aAction.url != nil, aAction.type == .externalURL,
                let taskId = task?.identifier {
                self?.showPostTaskAction(aAction, taskId: taskId)
            } else {
                self?.showBackupNagIfNeeded()
            }
        }
    }
}

private extension UIImage {
    func addingAnotherToBottomLeftCorner(_ another: UIImage,
                                         padding: CGFloat = 1,
                                         maxHeight: CGFloat? = nil) -> UIImage {
        let scale = UIScreen.main.scale
        var anotherImageSize = CGSize(width: another.size.width/scale,
                                      height: another.size.height/scale)

        if let maxHeight = maxHeight,
            anotherImageSize.height > maxHeight {
            let scale = anotherImageSize.height/maxHeight
            anotherImageSize.height = maxHeight
            anotherImageSize.width /= scale
        }

        let contextSize = CGSize(width: anotherImageSize.width + padding,
                                 height: anotherImageSize.height + padding)

        UIGraphicsBeginImageContextWithOptions(contextSize, true, scale)
        defer {
            UIGraphicsEndImageContext()
        }

        draw(in: CGRect(origin: .zero, size: contextSize))
        another.draw(in: CGRect(origin: CGPoint(x: padding, y: padding), size: anotherImageSize))
        let resizeInsets = UIEdgeInsets(top: 0, left: 0, bottom: another.size.height, right: another.size.width)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()!
            .resizableImage(withCapInsets: resizeInsets,
                            resizingMode: .stretch)
        return newImage
    }
}

extension TaskCategoryViewController {
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

extension TaskCategoryViewController: BackupFlowDelegate {
    func backupFlowDidCancel() {
        backupFlowController = nil
    }

    func backupFlowDidFinish() {
        backupFlowController = nil
    }
}

