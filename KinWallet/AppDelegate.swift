//
//  AppDelegate.swift
//  KinWallet
//
//  Copyright © 2018 KinFoundation. All rights reserved.
//

import Fabric
import Crashlytics
import UIKit
import KinSDK

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

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

        #if DEBUG
            logLevel = .verbose
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
            logNotificationOpened(with: notificationUserInfo)
        }

        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {

    }

    func applicationDidEnterBackground(_ application: UIApplication) {

    }

    func applicationWillEnterForeground(_ application: UIApplication) {

    }

    func applicationDidBecomeActive(_ application: UIApplication) {

    }

    func applicationWillTerminate(_ application: UIApplication) {

    }

    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        User.current?.updateDeviceTokenIfNeeded(deviceToken.hexString)
    }

    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any]) {
        guard application.applicationState == .inactive else {
            KLogVerbose("Received push while in foreground:\n\(userInfo)")
            return
        }

        logNotificationOpened(with: userInfo)
    }
}

extension AppDelegate {
    func dismissSplashIfNeeded() {
        rootViewController.dismissSplashIfNeeded()
    }
}

private func runningTests() -> Bool {
    return ProcessInfo().environment["XCInjectBundleInto"] != nil
}
