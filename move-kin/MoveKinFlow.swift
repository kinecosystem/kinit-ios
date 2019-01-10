//
//  MoveKinFlow.swift
//  KinWallet
//
//  Copyright © 2019 KinFoundation. All rights reserved.
//

import UIKit

public protocol MoveKinSelectAmountPage: class {
    func setupSelectAmountPage(selectionHandler: @escaping (UInt) -> Void)
}

public enum MoveKinAmountOption {
    case specified(UInt)
    case willInput(UIViewController & MoveKinSelectAmountPage)
}

public protocol MoveKinSendingPage {
    func sendKinDidStart(amount: UInt)
    func sendKinDidSucceed(amount: UInt, moveToSentPage: @escaping () -> Void)
    func sendKinDidFail(moveToErrorPage: @escaping () -> Void)
}

public protocol MoveKinSentPage {
    func setupSentKinPage(amount: UInt, finishHandler: @escaping () -> Void)
}

public protocol MoveKinErrorPage {
    func setupMoveKinErrorPage(finishHandler: @escaping () -> Void)
}

public protocol MoveKinFlowUIProvider: class {
    func viewControllerForConnectingStage(_ app: MoveKinApp) -> UIViewController
    func viewControllerForSendingStage(amount: UInt, app: MoveKinApp) -> UIViewController & MoveKinSendingPage
    func viewControllerForSentStage(amount: UInt, app: MoveKinApp) -> UIViewController & MoveKinSentPage
    func errorViewController() -> UIViewController & MoveKinErrorPage
}

public protocol MoveKinFlowDelegate: class {
    func sendKin(amount: UInt, to address: String, completion: @escaping (Bool) -> Void)
    func provideUserAddress(addressHandler: @escaping (String?) -> Void)
}

public class MoveKinFlow {
    public static let shared = MoveKinFlow()

    fileprivate var destinationAddress: PublicAddress?
    fileprivate var amountOption: MoveKinAmountOption?
    fileprivate var app: MoveKinApp?

    let getAddressFlow = GetAddressFlow()
    let provideAddressFlow = ProvideAddressFlow()

    public weak var delegate: MoveKinFlowDelegate?
    public weak var uiProvider: MoveKinFlowUIProvider?

    private var navigationController: UINavigationController?

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

    public func startMoveKinFlow(to destinationApp: MoveKinApp, amountOption: MoveKinAmountOption) {
        guard let uiProvider = uiProvider else {
            fatalError("MoveKin flow started, but no uiProvider set: MoveKinFlow.shared.uiProvider = x")
        }

        guard getAddressFlow.state == .idle else {
            return
        }

        self.app = destinationApp
        self.amountOption = amountOption

        let connectingViewController = uiProvider.viewControllerForConnectingStage(destinationApp)
        navigationController = MoveKinNavigationController(rootViewController: connectingViewController)
        navigationController!.setNavigationBarHidden(true, animated: false)
        presenter?.present(navigationController!, animated: true) { [weak self] in
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.6, execute: {
                self?.connectingAppsDidPresent(to: destinationApp)
            })
        }
    }

    fileprivate func amountSelected(_ amount: UInt) {
        guard
            let delegate = delegate,
            let uiProvider = uiProvider else {
            fatalError("MoveKin flow is in progress, but no delegate or uiProvider are set")
        }

        guard
            let destinationAddress = destinationAddress,
            let app = app else {
            fatalError("MoveKin flow will start sending, but no destinationAddress or app are set.")
        }

        //TODO: MoveKin look for retain cycles

        let sendingViewController = uiProvider.viewControllerForSendingStage(amount: amount, app: app)
        navigationController!.pushViewController(sendingViewController, animated: true)
        sendingViewController.sendKinDidStart(amount: amount)
        delegate.sendKin(amount: amount, to: destinationAddress.asString) { success in
            DispatchQueue.main.async {
                self.destinationAddress = nil
                self.amountOption = nil

                if success {
                    sendingViewController.sendKinDidSucceed(amount: amount) {
                        let sentViewController = uiProvider.viewControllerForSentStage(amount: amount, app: app)
                        sentViewController.setupSentKinPage(amount: amount, finishHandler: {
                            self.navigationController!.dismiss(animated: true)
                            self.navigationController = nil
                        })
                        self.navigationController!.pushViewController(sentViewController, animated: true)
                    }
                } else {
                    sendingViewController.sendKinDidFail {
                        let errorPageViewController = uiProvider.errorViewController()
                        errorPageViewController.setupMoveKinErrorPage {
                            self.navigationController!.dismiss(animated: true)
                            self.navigationController = nil
                        }
                        self.navigationController!.pushViewController(errorPageViewController, animated: true)
                    }
                }
            }
        }
    }

    private func connectingAppsDidPresent(to destinationApp: MoveKinApp) {
        getAddressFlow.startMoveKinFlow(to: destinationApp) { result in
            switch result {
            case .success(let publicAddress):
                self.getAddressFlowDidSucceed(with: publicAddress)
            case .cancelled:
                self.navigationController?.dismiss(animated: true, completion: nil)
            case .error(let error):
                self.getAddressFlowDidFail(error)
            }
        }
    }

    public func canHandleURL(_ url: URL) -> Bool {
        guard url.host == Constants.urlHost else {
            return false
        }

        guard url.path == Constants.receiveAddressURLPath
            || url.path == Constants.requestAddressURLPath else {
                return false
        }

        return true
    }

    public func handleURL(_ url: URL, from appBundleId: String) {
        guard url.host == Constants.urlHost else {
            return
        }

        switch url.path {
        case Constants.receiveAddressURLPath:
            getAddressFlow.handleURL(url, from: appBundleId)
        case Constants.requestAddressURLPath:
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

        // Network requests fail when the app didn't finish to transition to foreground.
        // Also, for a better transition, delay the calls below by 0.5s
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
            self.destinationAddress = publicAddress

            switch self.amountOption! {
            case .specified(let amount):
                self.amountSelected(amount)
            case .willInput(let inputViewController):
                inputViewController.setupSelectAmountPage { [weak self] amount in
                    self?.amountSelected(amount)
                }

                self.navigationController!.pushViewController(inputViewController, animated: true)
            }
        }
    }
}

// MARK: - Error Handling
extension MoveKinFlow {
    func getAddressFlowDidFail(_ error: GetAddressFlowTypes.Error) {
        switch error {
        case .timeout:
            navigationController?.dismiss(animated: true, completion: nil)
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
            self.navigationController?.dismiss(animated: true)
        })
        navigationController?.present(alertController, animated: true)
    }

    private func handleOpenAppStore(for destinationApp: MoveKinApp) {
        guard let presented = navigationController else {
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
