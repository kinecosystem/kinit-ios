//
//  RootViewController.swift
//  KinWallet
//
//  Copyright © 2018 KinFoundation. All rights reserved.
//

import UIKit
import Crashlytics

private let taskFetchTimeout: TimeInterval = 6
private let creatingAccountTimeout: TimeInterval = 25
let shownTutorialKey = "ShownTutorial"

extension NSNotification.Name {
    static let SplashScreenWillDismiss = NSNotification.Name(rawValue: "SplashScreenWillDismiss")
    static let SplashScreenDidDismiss = NSNotification.Name(rawValue: "SplashScreenDidDismiss")
}

class RootViewController: UIViewController {
    fileprivate var splashScreenNavigationController: UINavigationController? = {
        return UINavigationController(rootViewController: SplashScreenViewController())
    }()

    fileprivate let rootTabBarController = StoryboardScene.Main.rootTabBarController.instantiate()
    weak var walletCreationNoticeViewController: NoticeViewController?

    var isShowingSplashScreen: Bool {
        return splashScreenNavigationController != nil
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        if Kin.shared.accountStatus != .activated {
            //swiftlint:disable:next force_cast
            let splash = splashScreenNavigationController!.viewControllers.first as! SplashScreenViewController
            splash.creatingAccount = true
            startWalletCreationTimeout()
        } else {
            if UserDefaults.standard.bool(forKey: shownTutorialKey) {
                showWelcomeViewController()
            } else {
                DispatchQueue.main.asyncAfter(deadline: .now() + taskFetchTimeout) {
                    self.dismissSplashIfNeeded()
                }
            }
        }

        addAndFit(rootTabBarController)
        addAndFit(splashScreenNavigationController!)
    }

    override var childViewControllerForStatusBarStyle: UIViewController? {
        return childViewControllers.last
    }

    @discardableResult func dismissSplashIfNeeded() -> Bool {
        guard let splash = splashScreenNavigationController else {
            return false
        }

        self.splashScreenNavigationController = nil

        NotificationCenter.default.post(name: .SplashScreenWillDismiss, object: nil)

        UIView.animate(withDuration: 0.25, animations: {
            splash.view.alpha = 0
        }, completion: { _ in
            splash.remove()
            self.setNeedsStatusBarAppearanceUpdate()
            NotificationCenter.default.post(name: .SplashScreenDidDismiss, object: nil)
        })

        return true
    }

    private func showWalletCreationFailed() {
        guard walletCreationNoticeViewController == nil else {
            return
        }

        let supportAttributes: [NSAttributedStringKey: Any] = [.font: FontFamily.Roboto.regular.font(size: 14),
                                                               .foregroundColor: UIColor.kin.appTint,
                                                               .underlineStyle: NSUnderlineStyle.styleSingle.rawValue]
        let supportAttributedString = NSMutableAttributedString(string: "or contact support",
                                                                attributes: supportAttributes)
        let orAttributes: [NSAttributedStringKey: Any] = [.foregroundColor: UIColor.kin.gray,
                                                          .underlineStyle: NSUnderlineStyle.styleNone.rawValue]
        supportAttributedString.addAttributes(orAttributes, range: NSRange(location: 0, length: 3))

        let buttonConfiguration = NoticeButtonConfiguration(title: "Try Again",
                                                            mode: .stroke,
                                                            additionalMessage: supportAttributedString)
        let noticeViewController = StoryboardScene.Main.noticeViewController.instantiate()
        noticeViewController.delegate = self
        noticeViewController.notice = Notice(image: Asset.walletCreationFailed.image,
                                             title: "We were unable to create a wallet for you",
                                             subtitle: "Please check your internet connection & try again.",
                                             buttonConfiguration: buttonConfiguration,
                                             displayType: .imageFirst)
        present(noticeViewController, animated: true)

        walletCreationNoticeViewController = noticeViewController

        logViewedErrorPage()
    }

    func startWalletCreationTimeout() {
        DispatchQueue.main.asyncAfter(deadline: .now() + creatingAccountTimeout) {
            guard let splashNavigationController = self.splashScreenNavigationController,
                splashNavigationController.viewControllers.count == 1 else {
                return
            }

            self.showWalletCreationFailed()
        }
    }

    func appLaunched() {
        if let currentUser = User.current {
            KLogVerbose("User \(currentUser.userId) with device token \(currentUser.deviceToken ?? "No token")")
            Kin.shared.performOnboardingIfNeeded().then {
                self.onboardSucceeded($0)
            }

            #if !TESTS
            if Configuration.shared.testFairyKey != nil {
                TestFairy.setUserId(currentUser.userId)
            }
            #endif

            Crashlytics.sharedInstance().setUserIdentifier(currentUser.userId)

            UIApplication.shared.registerForRemoteNotifications()
            WebRequests.appLaunch().withCompletion { config, _ in
                KLogVerbose("App Launch: \(config != nil ? String(describing: config!) : "No config")")
            }.load(with: KinWebService.shared)

            KinLoader.shared.loadAllData()
        } else {
            Kin.shared.resetKeyStore()
            let user = User.createNew()
            WebRequests.userRegistrationRequest(for: user)
                .withCompletion { [weak self] config, error in
                    KLogVerbose("User registration: \(config != nil ? String(describing: config!) : "No config")")
                    guard config != nil else {
                        self?.logRegistrationFailed(error: error)
                        return
                    }

                    self?.logRegistrationSucceded(userId: user.userId,
                                                  deviceId: user.deviceId)
                    user.save()

                    KinLoader.shared.loadAllData()

                    Kin.shared.performOnboardingIfNeeded().then {
                        self?.onboardSucceeded($0)
                    }

                    DispatchQueue.main.async {
                        UIApplication.shared.registerForRemoteNotifications()
                    }
            }.load(with: KinWebService.shared)
        }
    }

    func onboardSucceeded(_ success: Bool) {
        guard success else {
            showWalletCreationFailed()
            return
        }

        guard var user = User.current else {
            return
        }

        user.publicAddress = Kin.shared.publicAddress
        user.save()

        DispatchQueue.main.async {
            self.showWelcomeViewController()
        }
    }

    func showWelcomeViewController() {
        guard let splashNavigationController = self.splashScreenNavigationController else {
            return
        }

        let containsWelcome = splashNavigationController.viewControllers.contains(where: {
            $0 is WelcomeViewController
        })

        guard !containsWelcome else {
            return
        }

        UserDefaults.standard.set(true, forKey: shownTutorialKey)

        let pushWelcome = {
            let welcome = StoryboardScene.Main.welcomeViewController.instantiate()
            splashNavigationController.pushViewController(welcome, animated: true)
        }

        if let walletCreationNotice = self.walletCreationNoticeViewController {
            walletCreationNotice.dismiss(animated: true, completion: pushWelcome)
        } else {
            pushWelcome()
        }
    }
}

extension RootViewController: NoticeViewControllerDelegate {
    func noticeViewControllerDidTapButton(_ viewController: NoticeViewController) {
        logClickedRetryOnErrorPage()

        dismiss(animated: true) { [weak self] in
            self?.startWalletCreationTimeout()
            self?.appLaunched()
        }
    }

    func noticeViewControllerDidTapAdditionalMessage(_ viewController: NoticeViewController) {
        logClickedSupportOnErrorPage()
        KinSupportViewController.present(from: viewController)
    }
}

extension RootViewController {
    fileprivate func logRegistrationSucceded(userId: String, deviceId: String) {
        Analytics.userId = userId
        Analytics.deviceId = deviceId
        Events.Business.UserRegistered().send()
    }

    fileprivate func logRegistrationFailed(error: Error?) {
        let reason = error?.localizedDescription ?? "Unknown error"
        Events.Log
            .UserRegistrationFailed(failureReason: reason)
            .send()
    }

    fileprivate func logViewedErrorPage() {
        Events.Analytics
            .ViewErrorPage(errorType: .onboarding)
            .send()
    }

    fileprivate func logClickedRetryOnErrorPage() {
        Events.Analytics
            .ClickRetryButtonOnErrorPage(errorType: .onboarding)
            .send()
    }

    fileprivate func logClickedSupportOnErrorPage() {
        Events.Analytics
            .ClickContactLinkOnErrorPage(errorType: .onboarding)
            .send()
    }
}
