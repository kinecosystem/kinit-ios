//
//  SurveyHomeViewController.swift
//  KinWallet
//
//  Copyright © 2018 KinFoundation. All rights reserved.
//

import UIKit
import KinUtil

final class SurveyHomeViewController: UIViewController {
    var showEarnAnimation = true
    var animatingEarn = false
    let linkBag = LinkBag()

    override func viewDidLoad() {
        super.viewDidLoad()

        renderCurrentTask(KinLoader.shared.currentTask.value ?? .none(nil))

        KinLoader.shared.currentTask
            .on(queue: .main, next: renderCurrentTask)
            .add(to: linkBag)

        addBalanceLabel()
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

        if showEarnAnimation && !animatingEarn {
            let width = view.frame.width
            showEarnAnimation = false
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
    func surveyViewController(_ viewController: SurveyViewController, didCancelWith results: TaskResults) {
        dismiss(animated: true)
    }

    func surveyViewController(_ viewController: SurveyViewController, didFinishWith results: TaskResults) {
        showTaskUnavailable(nil, error: nil)
    }
}
