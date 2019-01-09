//
//  AppDiscoveryAction.swift
//  KinWallet
//
//  Copyright © 2019 KinFoundation. All rights reserved.
//

import MoveKin

class AppDiscoveryAction {
    let moveKinFlow: MoveKinFlow
    fileprivate var app: EcosystemApp!

    init(moveKinFlow: MoveKinFlow) {
        self.moveKinFlow = moveKinFlow
    }

    func performAppAction(for app: EcosystemApp) {
        self.app = app

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

        let mApp = MoveKinApp(appName: app.name,
                              appStoreURL: app.metadata.url,
                              bundleId: app.bundleId,
                              urlScheme: transferData.urlScheme,
                              appIconURL: app.metadata.iconURL)
        moveKinFlow.delegate = self
        moveKinFlow.uiProvider = self
        moveKinFlow.startMoveKinFlow(to: mApp, amountOption: .specified(10))
    }
}

extension AppDiscoveryAction: MoveKinFlowDelegate {
    func sendKin(amount: UInt, to address: String, completion: @escaping (Bool) -> Void) {
        guard Kin.shared.accountStatus == .activated else {
            completion(false)
            return
        }

        Kin.shared.send(UInt64(amount), to: address, memo: nil) { txId, _ in
            completion(txId != nil)
        }
    }
}

extension AppDiscoveryAction: MoveKinFlowUIProvider {
    func provideUserAddress(addressHandler: @escaping (String?) -> Void) {
        let address = Kin.shared.accountStatus == .activated
            ? Kin.shared.publicAddress
            : nil
        addressHandler(address)
    }

    func viewControllerForConnectingStage() -> UIViewController {
        let connectingAppsViewController = ConnectingAppsViewController()
        connectingAppsViewController.appIconURL = app.metadata.iconURL.kinImagePathAdjustedForDevice()

        return connectingAppsViewController
    }

    func viewControllerForSendingStage() -> UIViewController & MoveKinSendingStage {
        return SendingKinToAppViewController()
    }

    func viewControllerForSentStage() -> UIViewController {
        return UIViewController()
    }
}
