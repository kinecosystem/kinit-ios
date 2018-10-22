//
//  TaskCategoryViewController.swift
//  KinWallet
//
//  Copyright © 2018 KinFoundation. All rights reserved.
//

import UIKit
import KinUtil
import SafariServices

class TaskCategoryTitleView: UIView {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var tasksCountStackView: UIStackView!
    @IBOutlet weak var tasksCountLabel: UILabel!
    @IBOutlet weak var iconImageView: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()

        let textColor = UIColor.white
        let font = FontFamily.Roboto.regular

        titleLabel.textColor = textColor
        titleLabel.font = font.font(size: 20)

        tasksCountLabel.textColor = textColor
        tasksCountLabel.font = font.font(size: 12)
    }
}

extension TaskCategoryTitleView: NibLoadableView {}

class TaskCategoryViewController: UIViewController {
    var categoryId: CategoryId!
    var navBarColor: UIColor?
    var headerImage: UIImage?
    private let linkBag = LinkBag()
    private let titleView = TaskCategoryTitleView.loadFromNib()
    fileprivate var previousNavigationBarImage: UIImage!

    deinit {
        DataLoaders.tasks.releaseObservables(categoryId: categoryId)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .white
        navigationItem.titleView = titleView

        bindObservables()
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
                let categoryNavBarImage = backgroundColorImage.addingAnotherToBottomLeftCorner(headerImage)
                navBar.setBackgroundImage(categoryNavBarImage, for: .default)
            }
        }
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
            .on(queue: .main, next: { [weak self] result in self?.renderCurrentTask(result) })
            .add(to: linkBag)
    }

    private func reloadTitleView(with category: TaskCategory) {
        let count = category.availableTasksCount
        titleView.titleLabel.text = category.title.capitalized
        titleView.tasksCountLabel.text = L10n.availableActivitesCount(count)
        titleView.tasksCountStackView.isHidden = count <= 1
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
        if task.isAvailable {
            showTaskAvailable(task)
        } else {
            showTaskUnavailable(task, error: nil)
        }
    }

    func showTaskAvailable(_ task: Task) {
        assert(task.daysToUnlock == 0,
               "SurveyUnavailableViewController received a task that is ready to be displayed.")
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
        surveyUnavailable.error = error
        add(surveyUnavailable) { $0.fitInSuperview(with: .safeArea) }
    }

    fileprivate func showBackupNagIfNeeded() {

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
    func addingAnotherToBottomLeftCorner(_ another: UIImage, padding: CGFloat = 5) -> UIImage {
        let scale = UIScreen.main.scale
        let anotherImageSize = CGSize(width: another.size.width/scale,
                                      height: another.size.height/scale)
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
