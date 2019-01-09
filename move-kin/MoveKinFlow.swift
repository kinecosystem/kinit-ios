//
//  MoveKinFlow.swift
//  KinWallet
//
//  Copyright © 2019 KinFoundation. All rights reserved.
//

import UIKit

public protocol MoveKinSelectAmountStage: class {
    var amountSelectionBlock: ((UInt) -> Void)? { get set }
}

public extension MoveKinSelectAmountStage {
    func setAmountSelectionBlock(_ selectionBlock: @escaping (UInt) -> Void) {
        amountSelectionBlock = selectionBlock
    }
}

public enum MoveKinAmountOption {
    case specified(UInt)
    case willInput(UIViewController & MoveKinSelectAmountStage)
}

public protocol MoveKinSendingStage {
    func sendKinDidStart()
    func sendKinDidSucceed(moveToSentPage: @escaping () -> Void)
    func sendKinDidFail()
}

public protocol MoveKinFlowUIProvider: class {
    func viewControllerForConnectingStage() -> UIViewController
    func viewControllerForSendingStage() -> UIViewController & MoveKinSendingStage
    func viewControllerForSentStage() -> UIViewController
}

public protocol MoveKinFlowDelegate: class {
    func sendKin(amount: UInt, to address: String, completion: @escaping (Bool) -> Void)
    func provideUserAddress(addressHandler: @escaping (String?) -> Void)

}

public class MoveKinFlow {
    public static let shared = MoveKinFlow()

    fileprivate var destinationAddress: PublicAddress?
    fileprivate var amountOption: MoveKinAmountOption?

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

        self.amountOption = amountOption

        navigationController = UINavigationController(rootViewController: uiProvider.viewControllerForConnectingStage())
        navigationController!.setNavigationBarHidden(true, animated: false)
        presenter?.present(navigationController!, animated: true) { [weak self] in
            self?.connectingAppsDidPresent(to: destinationApp)
        }
    }

    fileprivate func amountSelected(_ amount: UInt) {
        guard
            let delegate = delegate,
            let uiProvider = uiProvider else {
            fatalError("MoveKin flow is in progress, but no delegate or uiProvider are set")
        }

        guard let destinationAddress = destinationAddress else {
            fatalError("MoveKin flow will start sending, but no destinationAddress is set.")
        }

        //TODO: look for retain cycles

        let sendingViewController = uiProvider.viewControllerForSendingStage()
        navigationController!.pushViewController(sendingViewController, animated: true)
        sendingViewController.sendKinDidStart()
        delegate.sendKin(amount: amount, to: destinationAddress.asString) { success in
            self.destinationAddress = nil
            self.amountOption = nil

            if success {
                sendingViewController.sendKinDidSucceed {
                    let sentViewController = uiProvider.viewControllerForSentStage()
                    self.navigationController!.pushViewController(sentViewController, animated: true)
                }
            } else {
                sendingViewController.sendKinDidFail()
                //TODO: dismiss screen
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

        destinationAddress = publicAddress

        switch amountOption! {
        case .specified(let amount):
            amountSelected(amount)
        case .willInput(let inputViewController):
            inputViewController.setAmountSelectionBlock { [weak self] amount in
                self?.amountSelected(amount)
            }

            navigationController!.pushViewController(inputViewController, animated: true)
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
