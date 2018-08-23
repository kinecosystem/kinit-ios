//
//  AppDelegate.swift
//  Kinit
//

import Fabric
import Crashlytics
import UIKit
import KinSDK
import Firebase
import FirebaseAuth

@UIApplicationMain
final class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    var notificationHandler: NotificationHandler?

    fileprivate let rootViewController = RootViewController()

    //swiftlint:disable:next line_length
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        if !runningTests() {
            Fabric.with([Crashlytics.self])

            #if !TESTS
            if let testFairyKey = Configuration.shared.testFairyKey {
                TestFairy.begin(testFairyKey)
            }
            #endif
        }

        generateUserAgent()

        let filePath = Bundle.main.path(forResource: firebaseFileName(), ofType: "plist")!
        let firebaseOptions = FirebaseOptions(contentsOfFile: filePath)!
        FirebaseApp.configure(options: firebaseOptions)

        #if DEBUG
            logLevel = .debug
        #endif

        if #available(iOS 10.0, *) {
            notificationHandler = iOS10NotificationHandler()
        }

        applyAppearance()

        let currentUser = User.current
        Analytics.start(userId: currentUser?.userId, deviceId: currentUser?.deviceId)

        window = UIWindow()
        window!.makeKeyAndVisible()
        window!.rootViewController = rootViewController
        rootViewController.appLaunched()

        notificationHandler?.arePermissionsGranted { granted in
            Analytics.setUserProperty(Events.UserProperties.pushEnabled, with: granted)
        }

        if
            let launchOptions = launchOptions,
            let notificationUserInfo = launchOptions[.remoteNotification] as? [AnyHashable: Any] {
            PushHandler.handlePush(with: notificationUserInfo)
        }

        return true
    }

    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        User.current?.updateDeviceTokenIfNeeded(deviceToken.hexString)

        let tokenType: AuthAPNSTokenType

        #if DEBUG
        tokenType = .sandbox
        #else
        tokenType = .prod
        #endif

        Auth.auth().setAPNSToken(deviceToken, type: tokenType)
    }

    func application(_ application: UIApplication,
                     didReceiveRemoteNotification userInfo: [AnyHashable: Any],
                     fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        KLogVerbose("Received push:\n\(userInfo)")

        if Auth.auth().canHandleNotification(userInfo) {
            completionHandler(.noData)
            return
        }

        PushHandler.handlePush(with: userInfo)
    }
}

extension AppDelegate {
    @discardableResult func dismissSplashIfNeeded() -> Bool {
        return rootViewController.dismissSplashIfNeeded()
    }

    var isShowingSplashScreen: Bool {
        return rootViewController.isShowingSplashScreen
    }
}

private func runningTests() -> Bool {
    return ProcessInfo().environment["XCInjectBundleInto"] != nil
}
