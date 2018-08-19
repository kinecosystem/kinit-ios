//
//  RootViewController.swift
//  Kinit
//

import UIKit
import Crashlytics

private let taskFetchTimeout: TimeInterval = 6
private let creatingAccountTimeout: TimeInterval = 25
let startedPhoneVerificationKey = "startedPhoneVerification"

private enum RegistrationError {
    case user
    case wallet

    var title: String {
        switch self {
        case .user: return L10n.userRegistrationErrorTitle
        case .wallet: return L10n.walletCreationErrorTitle
        }
    }

    var image: UIImage {
        switch self {
        case .user: return Asset.errorSign.image
        case .wallet: return Asset.walletCreationFailed.image
        }
    }
}

extension NSNotification.Name {
    static let SplashScreenWillDismiss = NSNotification.Name(rawValue: "SplashScreenWillDismiss")
    static let SplashScreenDidDismiss = NSNotification.Name(rawValue: "SplashScreenDidDismiss")
}

class RootViewController: UIViewController {
    fileprivate var splashScreenNavigationController: KinNavigationController? = {
        return KinNavigationController(rootViewController: SplashScreenViewController())
    }()

    fileprivate let rootTabBarController = StoryboardScene.Main.rootTabBarController.instantiate()
    weak var errorNoticeViewController: NoticeViewController?

    var isShowingSplashScreen: Bool {
        return splashScreenNavigationController != nil
    }

    var latestWalletCreationAttempt: String?

    override func viewDidLoad() {
        super.viewDidLoad()

        addAndFit(rootTabBarController)
        addAndFit(splashScreenNavigationController!)
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
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

    private func showErrorNotice(error: RegistrationError) {
        guard errorNoticeViewController == nil else {
            return
        }

        let supportAttributes: [NSAttributedStringKey: Any] = [.font: FontFamily.Roboto.regular.font(size: 14),
                                                               .foregroundColor: UIColor.kin.appTint,
                                                               .underlineStyle: NSUnderlineStyle.styleSingle.rawValue]
        let supportAttributedString = NSMutableAttributedString(string: L10n.orContactSupport,
                                                                attributes: supportAttributes)
        let orAttributes: [NSAttributedStringKey: Any] = [.foregroundColor: UIColor.kin.gray,
                                                          .underlineStyle: NSUnderlineStyle.styleNone.rawValue]
        supportAttributedString.addAttributes(orAttributes, range: NSRange(location: 0, length: 3))

        let buttonConfiguration = NoticeButtonConfiguration(title: L10n.tryAgain,
                                                            mode: .stroke,
                                                            additionalMessage: supportAttributedString)
        let noticeViewController = StoryboardScene.Main.noticeViewController.instantiate()
        noticeViewController.delegate = self
        noticeViewController.notice = Notice(image: error.image,
                                             title: error.title,
                                             subtitle: L10n.walletOrUserCreationErrorSubtitle,
                                             buttonConfiguration: buttonConfiguration,
                                             displayType: .imageFirst)
        present(noticeViewController, animated: true)

        errorNoticeViewController = noticeViewController

        logViewedErrorPage()
    }

    func startWalletCreationTimeout(with attempt: String) {
        DispatchQueue.main.asyncAfter(deadline: .now() + creatingAccountTimeout) {
            guard self.latestWalletCreationAttempt == attempt else {
                return
            }

            guard let splashNavigationController = self.splashScreenNavigationController,
                splashNavigationController.topViewController is SplashScreenViewController else {
                return
            }

            self.showErrorNotice(error: .wallet)
        }
    }

    func appLaunched() {
        verifyAccountMatchesUserAddress()

        guard let currentUser = User.current else {
            Kin.shared.resetKeyStore()
            registerUser()
            return
        }

        KLogVerbose("User \(currentUser.userId) with device token \(currentUser.deviceToken ?? "No token")")

        if currentUser.phoneNumber != nil {
            //Backup: Show here the two options.
            //For now, just create the wallet.
            performOnboarding()
        } else {
            showWelcomeViewController()
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
    }

    private func verifyAccountMatchesUserAddress() {
        //In some cases, when the user makes a backup in iTunes without encryption,
        //the keychain is not recovered, and therefore, the keystore is lost.
        //At every launch, we check if the address stored in the current user matches
        //the address given by Kin.shared. If they don't match, we currently delete
        //all data and start like a clean install: Delete user, the cached next task, and task results.
        if let address = User.current?.publicAddress,
            address != Kin.shared.publicAddress {
            User.reset()

            if let task: Task = SimpleDatastore.loadObject(nextTaskIdentifier) {
                SimpleDatastore.delete(objectOf: Task.self, with: nextTaskIdentifier)
                SimpleDatastore.delete(objectOf: TaskResults.self, with: task.identifier)
            }

            Kin.shared.resetKeyStore()
        }

        if Kin.shared.accountStatus == .activated {
            DispatchQueue.main.asyncAfter(deadline: .now() + taskFetchTimeout) {
                self.dismissSplashIfNeeded()
            }
        }
    }

    private func registerUser() {
        let user = User.createNew()
        WebRequests.userRegistrationRequest(for: user)
            .withCompletion { [weak self] config, error in
                KLogVerbose("User registration: \(config != nil ? String(describing: config!) : "No config")")
                guard config != nil else {
                    self?.logRegistrationFailed(error: error)
                    DispatchQueue.main.async {
                        self?.showErrorNotice(error: .user)
                    }

                    return
                }

                self?.logRegistrationSucceded(userId: user.userId,
                                              deviceId: user.deviceId)
                user.save()

                KinLoader.shared.loadAllData()

                DispatchQueue.main.async {
                    self?.showWelcomeViewController()
                    UIApplication.shared.registerForRemoteNotifications()
                }
            }.load(with: KinWebService.shared)
    }

    func phoneNumberValidated(with hintIds: [Int]) {
        let splash = SplashScreenViewController()
        splash.creatingAccount = true
        splashScreenNavigationController?.pushViewController(splash, animated: true)

        performOnboarding()
    }

    private func performOnboarding() {
        let thisAttempt = UUID().uuidString
        latestWalletCreationAttempt = thisAttempt

        Kin.shared.performOnboardingIfNeeded().then { [weak self] in
            self?.onboardSucceeded($0)
        }

        startWalletCreationTimeout(with: thisAttempt)
    }

    func onboardSucceeded(_ success: Bool) {
        guard success else {
            DispatchQueue.main.async {
                self.showErrorNotice(error: .wallet)
            }
            return
        }

        guard var user = User.current else {
            return
        }

        user.publicAddress = Kin.shared.publicAddress
        user.save()

        DispatchQueue.main.async {
            let accountReady = StoryboardScene.Main.accountReadyViewController.instantiate()
            self.splashScreenNavigationController?.pushViewController(accountReady, animated: true)
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

        let pushWelcome = {
            let welcome = StoryboardScene.Main.welcomeViewController.instantiate()
            splashNavigationController.pushViewController(welcome, animated: true)
        }

        if let walletCreationNotice = self.errorNoticeViewController {
            walletCreationNotice.dismiss(animated: true, completion: pushWelcome)
        } else {
            pushWelcome()
        }
    }
}

extension RootViewController: NoticeViewControllerDelegate {
    func noticeViewControllerDidTapButton(_ viewController: NoticeViewController) {
        logClickedRetryOnErrorPage()

        let userExists = User.current != nil

        dismiss(animated: true) { [weak self] in
            if userExists {
                self?.performOnboarding()
            } else {
                self?.registerUser()
            }
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
