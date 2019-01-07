//
//  MoveKinFlow.swift
//  KinWallet
//
//  Copyright © 2019 KinFoundation. All rights reserved.
//

import UIKit

protocol MoveKinFlowDelegate: class {
    func sendKin(amount: UInt, to address: String, completion: (Bool) -> Void)
}

public class MoveKinFlow {
    public let shared = MoveKinFlow()

    let getAddressFlow = GetAddressFlow()
    let provideAddressFlow = ProvideAddressFlow()

    weak var delegate: MoveKinFlowDelegate?

    private var presentedViewController: UIViewController?

    private var presenter: UIViewController? {
        guard let appDelegate = UIApplication.shared.delegate,
            var viewController = appDelegate.window??.rootViewController else {
            return nil
        }

        while let presented = viewController.presentedViewController {
            viewController = presented
        }

        return viewController
    }

    public func startMoveKinFlow(to destinationApp: MoveKinApp) {
        guard getAddressFlow.state == .idle else {
            return
        }

        presentedViewController = UINavigationController(rootViewController: ConnectingAppsViewController())
        presenter?.present(presentedViewController!, animated: true) { [weak self] in
            self?.connectingAppsDidPresent(to: destinationApp)
        }
    }

    private func connectingAppsDidPresent(to destinationApp: MoveKinApp) {
        getAddressFlow.startMoveKinFlow(to: destinationApp) { result in
            switch result {
            case .success(let publicAddress):
                self.getAddressFlowDidSucceed(with: publicAddress)
            case .cancelled:
                self.presentedViewController?.dismiss(animated: true, completion: nil)
            case .error(let error):
                self.getAddressFlowDidFail(error)
            }
        }
    }

    public func canHandleURL(_ url: URL) -> Bool {
        guard url.host == MoveKinConstants.urlHost else {
            return false
        }

        guard url.path == MoveKinConstants.receiveAddressURLPath
            || url.path == MoveKinConstants.requestAddressURLPath else {
                return false
        }

        return true
    }

    public func handleURL(_ url: URL, from appBundleId: String) {
        guard url.host == MoveKinConstants.urlHost else {
            return
        }

        switch url.path {
        case MoveKinConstants.receiveAddressURLPath:
            getAddressFlow.handleURL(url, from: appBundleId)
        case MoveKinConstants.requestAddressURLPath:
            print("YO")
        default:
            break
        }
    }
}

// MARK: - Success Handling
extension MoveKinFlow {
    func getAddressFlowDidSucceed(with publicAddress: PublicAddress) {
        print("Got public address: \(publicAddress.asString)")
        presentedViewController?.dismiss(animated: true, completion: nil)
    }
}

// MARK: - Error Handling
extension MoveKinFlow {
    func getAddressFlowDidFail(_ error: GetAddressFlowTypes.Error) {
        switch error {
        case .timeout:
            presentedViewController?.dismiss(animated: true, completion: nil)
        case .appLaunchFailed(let app):
            handleOpenAppStore(for: app)
        case .bundleIdMismatch, .invalidAddress, .invalidHandleURL, .invalidURLScheme:
            displayGeneralErrorAlert()
        }
    }

    private func displayGeneralErrorAlert() {
        let message = "There was a problem establishing a connection. Please try again in a bit."
        let alertController = UIAlertController(title: "Echo… Echo… Echo…",
                                                message: message,
                                                preferredStyle: .alert)
        alertController.addAction(.init(title: "Back", style: .default) { _ in
            self.presentedViewController?.dismiss(animated: true)
        })
        presentedViewController?.present(alertController, animated: true)
    }

    private func handleOpenAppStore(for destinationApp: MoveKinApp) {
        guard let presented = presentedViewController else {
            return
        }

        let alertController = UIAlertController(title: "That app’s not here… yet ",
                                                message: "Download the app and create a wallet to send your Kin",
                                                preferredStyle: .alert)
        alertController.addAction(.init(title: "To the store", style: .default) { _ in
            presented.dismiss(animated: true) {
                if #available(iOS 10.0, *) {
                    UIApplication.shared.open(destinationApp.appStoreURL)
                } else {
                    UIApplication.shared.openURL(destinationApp.appStoreURL)
                }
            }
        })

        alertController.addAction(.init(title: "Back", style: .cancel) { _ in
            presented.dismiss(animated: true)
        })
        presented.present(alertController, animated: true, completion: nil)
    }
}
