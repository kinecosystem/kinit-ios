//
//  AppDiscoveryAction.swift
//  KinWallet
//
//  Copyright © 2019 KinFoundation. All rights reserved.
//

import MoveKin

class AppDiscoveryAction {
    let moveKinFlow: MoveKinFlow

    init(moveKinFlow: MoveKinFlow) {
        self.moveKinFlow = moveKinFlow
    }

    func performAppAction(for app: EcosystemApp) {
        guard app.isTransferAvailable,
            let transferData = app.transferData else {
                let url = app.metadata.url

                if #available(iOS 10.0, *) {
                    UIApplication.shared.open(url)
                } else {
                    UIApplication.shared.openURL(url)
                }

                return
        }

        let mApp = MoveKinApp(name: app.name,
                              appStoreURL: app.metadata.url,
                              bundleId: app.bundleId,
                              urlScheme: transferData.urlScheme,
                              appIconURL: app.metadata.iconURL.kinImagePathAdjustedForDevice())
        moveKinFlow.uiProvider = self
//        moveKinFlow.startMoveKinFlow(to: mApp, amountOption: .willInput(SendKinAmountInputViewController()))
        moveKinFlow.startMoveKinFlow(to: mApp, amountOption: .specified(4))
    }
}

extension AppDiscoveryAction: MoveKinFlowUIProvider {
    func viewControllerForConnectingStage(_ app: MoveKinApp) -> UIViewController {
        let connectingAppsViewController = ConnectingAppsViewController()
        connectingAppsViewController.appIconURL = app.appIconURL

        return connectingAppsViewController
    }

    func viewControllerForSendingStage(amount: UInt, app: MoveKinApp) -> UIViewController & MoveKinSendingPage {
        let sendingKinViewController = SendingKinToAppViewController()
        sendingKinViewController.appIconURL = app.appIconURL
        sendingKinViewController.appName = app.name

        return sendingKinViewController
    }

    func viewControllerForSentStage(amount: UInt, app: MoveKinApp) -> UIViewController & MoveKinSentPage {
        let sentVC = SentKinToAppViewController()
        sentVC.amount = amount

        return sentVC
    }

    func errorViewController() -> UIViewController {
        let errorVC = UIViewController()
        errorVC.view.backgroundColor = .red
        return errorVC
    }
}
