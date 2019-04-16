//
//  RootViewController.swift
//  Kinit
//

import UIKit
import Crashlytics

private let taskFetchTimeout: TimeInterval = 6
private let creatingAccountTimeout: TimeInterval = 25
let startedPhoneVerificationKey = "startedPhoneVerification"
let selectedHintIdsKey = "SelectedHintIds"

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

    override var childForStatusBarStyle: UIViewController? {
        return children.last
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

    private func showErrorNotice(error: RegistrationError, failureReason: String) {
        guard errorNoticeViewController == nil else {
            return
        }

        let supportAttributes: [NSAttributedString.Key: Any] = [.font: FontFamily.Roboto.regular.font(size: 14),
                                                               .foregroundColor: UIColor.kin.appTint,
                                                               .underlineStyle: NSUnderlineStyle.single.rawValue]
        let supportAttributedString = NSMutableAttributedString(string: L10n.orContactSupport,
                                                                attributes: supportAttributes)
        let orAttributes: [NSAttributedString.Key: Any] = [.foregroundColor: UIColor.kin.gray,
                                                           .underlineStyle: 0]
        supportAttributedString.addAttributes(orAttributes, range: NSRange(location: 0, length: 3))

        let buttonConfiguration = NoticeButtonConfiguration(title: L10n.tryAgain,
                                                            mode: .stroke,
                                                            additionalMessage: supportAttributedString)
        let noticeViewController = StoryboardScene.Main.noticeViewController.instantiate()
        noticeViewController.delegate = self

        let noticeContent = NoticeContent(title: error.title,
                                          message: L10n.walletOrUserCreationErrorSubtitle,
                                          image: error.image)

        noticeViewController.notice = Notice(content: noticeContent,
                                             buttonConfiguration: buttonConfiguration,
                                             displayType: .imageFirst)
        present(noticeViewController, animated: true)

        errorNoticeViewController = noticeViewController

        logViewedErrorPage(failureReason: failureReason)
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

            self.showErrorNotice(error: .wallet, failureReason: "Wallet creation timeout")
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
            if let storedHintIds: SelectedHintIds = SimpleDatastore.loadObject(selectedHintIdsKey),
                storedHintIds.hints.isNotEmpty {
                showAccountSourceSelection()
            } else if currentUser.publicAddress == nil {
                performOnboarding()
            }
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
        WebRequests.appLaunch().withCompletion { result in
            KLogVerbose("App Launch: \(result.value != nil ? String(describing: result.value!) : "No config")")
            }.load(with: KinWebService.shared)

        DataLoaders.loadAllData()
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

        if User.current?.publicAddress != nil {
            DispatchQueue.main.asyncAfter(deadline: .now() + taskFetchTimeout) {
                self.dismissSplashIfNeeded()
            }
        }
    }

    private func registerUser() {
        let user = User.createNew()
        WebRequests.userRegistrationRequest(for: user)
            .withCompletion { [weak self] result in
                let config = result.value
                KLogVerbose("User registration: \(config != nil ? String(describing: config!) : "No config")")
                guard config != nil else {
                    let reason = result.error?.localizedDescription ?? "Unknown User Registration Error"

                    self?.logRegistrationFailed(error: result.error, reason: reason)
                    DispatchQueue.main.async {
                        self?.showErrorNotice(error: .user, failureReason: reason)
                    }

                    return
                }

                self?.logRegistrationSucceded(userId: user.userId,
                                              deviceId: user.deviceId)
                user.save()

                DataLoaders.loadAllData()

                DispatchQueue.main.async {
                    self?.showWelcomeViewController()
                    UIApplication.shared.registerForRemoteNotifications()
                }
            }.load(with: KinWebService.shared)
    }

    func phoneNumberValidated(with hintIds: [Int]) {
        if hintIds.isEmpty {
            startCreatingWallet()
        } else {
            SimpleDatastore.persist(SelectedHintIds(hints: hintIds), with: selectedHintIdsKey)
            showAccountSourceSelection()
        }
    }

    private func showAccountSourceSelection() {
        let accountSourceViewController = StoryboardScene.Onboard.accountSourceViewController.instantiate()
        splashScreenNavigationController?.pushViewController(accountSourceViewController, animated: true)
    }

    func startCreatingWallet() {
        let creatingWalletViewController = StoryboardScene.Onboard.creatingWalletViewController.instantiate()
        splashScreenNavigationController?.pushViewController(creatingWalletViewController, animated: true)

        performOnboarding()
    }

    private func performOnboarding() {
        let attemptId = UUID().uuidString
        latestWalletCreationAttempt = attemptId

        Kin.shared.performOnboardingIfNeeded().then { [weak self] in
            self?.performedOnboarding($0)
        }

        startWalletCreationTimeout(with: attemptId)
    }

    func performedOnboarding(_ result: OnboardingResult) {
        if case let OnboardingResult.failure(reason) = result {
            DispatchQueue.main.async {
                self.showErrorNotice(error: .wallet, failureReason: reason)
            }
            return
        }

        guard var user = User.current else {
            return
        }

        user.publicAddress = Kin.shared.publicAddress
        user.save()

        DispatchQueue.main.async {
            let accountReady = StoryboardScene.Onboard.accountReadyViewController.instantiate()
            accountReady.walletSource = .new
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
            let welcome = StoryboardScene.Onboard.welcomeViewController.instantiate()
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
        KinSupportViewController.presentSupport(from: viewController)
    }
}

extension RootViewController {
    fileprivate func logRegistrationSucceded(userId: String, deviceId: String) {
        Analytics.userId = userId
        Analytics.deviceId = deviceId
        Events.Business.UserRegistered().send()
    }

    fileprivate func logRegistrationFailed(error: Error?, reason: String) {
        Events.Log
            .UserRegistrationFailed(failureReason: reason)
            .send()
    }

    fileprivate func logViewedErrorPage(failureReason: String) {
        Events.Analytics
            .ViewErrorPage(errorType: .onboarding, failureReason: failureReason)
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
