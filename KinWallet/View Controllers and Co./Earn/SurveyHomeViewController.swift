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
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(splashScreenDidDismiss),
                                               name: .SplashScreenDidDismiss,
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

    private func requestToVerifyPhoneIfNeeded() {
        guard User.current?.phoneNumber == nil,
            RemoteConfig.current?.phoneVerificationEnabled == true,
            !AppDelegate.shared.isShowingSplashScreen,
            presentedViewController == nil else {
                return
        }

        let alertController = UIAlertController(title: "Help us keep your Kin safe",
                                                message: "Please verify your phone number",
                                                preferredStyle: .alert)
        alertController.addAction(.init(title: "Verify my account", style: .default) { [weak self] _ in
            guard let aSelf = self else {
                return
            }

            aSelf.logClickedVerifyPhoneAuthPopup()

            #if !targetEnvironment(simulator)
            let phoneVerification = StoryboardScene.Main.phoneVerificationRequestViewController.instantiate()
            let navController = UINavigationController(rootViewController: phoneVerification)
            aSelf.present(navController, animated: true, completion: nil)
            #endif
            })

        present(alertController, animated: true, completion: nil)

        logViewedPhoneAuthPopup()
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

    @objc func splashScreenDidDismiss() {
        if (childViewControllers.first as? SurveyInfoViewController) != nil {
            return
        }

        requestToVerifyPhoneIfNeeded()
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
            self.requestToVerifyPhoneIfNeeded()
        })
    }

    func showTaskUnavailable(_ task: Task?, error: Error?) {
        childViewControllers.forEach { $0.remove() }

        let surveyUnavailable = SurveyUnavailableViewController()
        surveyUnavailable.task = task
        surveyUnavailable.error = error
        add(surveyUnavailable) { $0.fitInSuperview(with: .safeArea) }

        if error == nil {
            requestToVerifyPhoneIfNeeded()
        }
    }
}

extension SurveyHomeViewController: SurveyViewControllerDelegate {
    func surveyViewController(_ viewController: SurveyViewController, didCancelWith results: TaskResults) {
        dismiss(animated: true)
    }

    func surveyViewController(_ viewController: SurveyViewController, didFinishWith results: TaskResults) {
        showTaskUnavailable(nil, error: nil)
    }
}

extension SurveyHomeViewController {
    fileprivate func logViewedPhoneAuthPopup() {
        Events.Analytics.ViewPhoneAuthPopup().send()
    }

    fileprivate func logClickedVerifyPhoneAuthPopup() {
        Events.Analytics.ClickVerifyButtonOnPhoneAuthPopup().send()
    }
}
