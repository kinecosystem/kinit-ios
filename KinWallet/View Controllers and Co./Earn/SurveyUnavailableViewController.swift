//
//  SurveyUnavailableViewController.swift
//  Kinit
//

import UIKit

final class SurveyUnavailableViewController: UIViewController, AddNoticeViewController {
    var task: Task?
    var error: Error?
    var noticeViewController: NoticeViewController?

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        displayUnavailabilityReason()
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(displayUnavailabilityReason),
                                               name: .UIApplicationWillEnterForeground,
                                               object: nil)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        if task == nil {
            if error != nil {
                Events.Analytics
                    .ViewErrorPage(errorType: .internetConnection)
                    .send()
            } else {
                Events.Analytics
                    .ViewEmptyStatePage(menuItemName: .earn)
                    .send()
            }
        }
    }

    @objc func displayUnavailabilityReason() {
        let title: String
        let subtitle: String?
        let image: UIImage
        var displayType = Notice.DisplayType.imageFirst

        if let task = task {
            let toUnlock = task.daysToUnlock()
            displayType = .titleFirst
            assert(toUnlock > 0, "SurveyUnavailableViewController received a task that is ready to be displayed.")

            title = L10n.nextActivityOnTitle(task.nextAvailableDay())
            subtitle = L10n.nextActivityOnSubtitle
            image = Asset.nextTask.image

            Events.Analytics
                .ViewLockedTaskPage(timeToUnlock: Int(toUnlock))
                .send()
        } else {
            if error != nil {
                image = noInternetImage
                title = L10n.internetErrorTitle
                subtitle = L10n.internetErrorMessage
            } else {
                image = Asset.sowingIllustration.image
                title = L10n.noActivitiesTitle
                subtitle = L10n.noActivitiesMessage
            }
        }

        notifyButtonIfNeeded { [weak self] buttonConfiguration in
            self?.childViewControllers.first?.remove()
            self?.noticeViewController = self?.addNoticeViewController(with: title,
                                                                       subtitle: subtitle,
                                                                       image: image,
                                                                       buttonConfiguration: buttonConfiguration,
                                                                       displayType: displayType,
                                                                       delegate: self)
        }
    }

    private func notifyButtonIfNeeded(completion: @escaping (NoticeButtonConfiguration?) -> Void) {
        guard
            let notificationHandler = AppDelegate.shared.notificationHandler,
            error == nil else {
            completion(nil)
            return
        }

        notificationHandler.arePermissionsGranted { granted in
            let buttonConfiguration = granted
                ? nil
                : NoticeButtonConfiguration(title: L10n.notifyMe, mode: .fill)
            completion(buttonConfiguration)
        }
    }

    fileprivate func alertNotificationsDenied() {
        let alertController = UIAlertController(title: L10n.notificationsDeniedTitle,
                                                message: L10n.notificationsDeniedMessage,
                                                preferredStyle: .alert)
        if let url = URL(string: UIApplicationOpenSettingsURLString) {
            alertController.addAction(UIAlertAction(title: L10n.notificationsDeniedAction, style: .default) { _ in
                if #available(iOS 10.0, *) {
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                } else {
                    UIApplication.shared.openURL(url)
                }
            })
        } else {
            alertController.addAction(.ok)
        }

        present(alertController, animated: true)
    }
}

extension SurveyUnavailableViewController: NoticeViewControllerDelegate {
    func noticeViewControllerDidTapButton(_ viewController: NoticeViewController) {
        Events.Analytics
            .ClickReminderButtonOnLockedTaskPage()
            .send()

        guard let notificationHandler = AppDelegate.shared.notificationHandler else {
            return
        }

        notificationHandler.hasUserBeenAskedAboutPushNotifications { [weak self] asked in
            guard let aSelf = self else {
                return
            }

            if asked {
                aSelf.alertNotificationsDenied()
            } else {
                AppDelegate.shared.requestNotifications { [weak self] granted in
                    if granted {
                        self?.noticeViewController?.hideButton()
                    }
                }
            }
        }
    }
}
