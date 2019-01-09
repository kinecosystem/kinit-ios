//
//  MoveKinFlow.swift
//  KinWallet
//
//  Copyright © 2019 KinFoundation. All rights reserved.
//

import UIKit

typealias GetAddressFlowCompletion = (GetAddressFlowTypes.Result) -> Void

class GetAddressFlow {
    private(set) var state = GetAddressFlowTypes.State.idle {
        didSet {
            if let result = state.toResult {
                completion?(result)
                completion = nil
                state = .idle
            }
        }
    }

    private var timeoutDispatchWorkItem: DispatchWorkItem?

    private var completion: GetAddressFlowCompletion?

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    init() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(appDidBecomeActive),
                                               name: UIApplication.didBecomeActiveNotification,
                                               object: nil)
    }

    func startMoveKinFlow(to destinationApp: MoveKinApp, completion: @escaping GetAddressFlowCompletion) {
        self.completion = completion

        guard let url = LaunchURLBuilder.requestAddressURL(for: destinationApp) else {
            state = .error(.invalidURLScheme)
            return
        }

        let bundleId = destinationApp.bundleId
        state = .launchingApp

        func triedToLaunchApp(success: Bool) {
            guard success else {
                state = .error(.appLaunchFailed(destinationApp))
                return
            }

            state = .waitingForAddress(bundleId: bundleId)
        }

        if #available(iOS 10.0, *) {
            UIApplication.shared.open(url, completionHandler: triedToLaunchApp)
        } else {
            let success = UIApplication.shared.openURL(url)
            triedToLaunchApp(success: success)
        }
    }

    func canHandleURL(_ url: URL) -> Bool {
        guard url.host == Constants.urlHost, url.path == Constants.receiveAddressURLPath else {
            return false
        }

        return true
    }

    func handleURL(_ url: URL, from appBundleId: String) {
        timeoutDispatchWorkItem?.cancel()

        guard case let GetAddressFlowTypes.State.waitingForAddress(bundleId) = state else {
            return
        }

        //TODO: uncomment
//        guard bundleId == appBundleId else {
//            state = .error(.bundleIdMismatch)
//            return
//        }

        do {
            let address = try kinAddress(from: url)
            state = .success(address)
        } catch let error as GetAddressFlowTypes.Error {
            state = .error(error)
        } catch { }
    }

    private func kinAddress(from url: URL) throws -> PublicAddress {
        guard canHandleURL(url),
            let urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false),
            let queryItems = urlComponents.queryItems,
            let addressQueryItem = queryItems.first(where: {
                $0.name == Constants.receiveAddressQueryItem
            }) else {
                throw GetAddressFlowTypes.Error.invalidHandleURL
        }

        guard
            let sAddress = addressQueryItem.value,
            let pAddress = PublicAddress(rawValue: sAddress),
            sAddress == pAddress.asString else {
            throw GetAddressFlowTypes.Error.invalidAddress
        }

        return pAddress
    }

    @objc func appDidBecomeActive() {
        let item = DispatchWorkItem {
            self.state = .error(.timeout)
        }

        timeoutDispatchWorkItem = item
        DispatchQueue.main.asyncAfter(deadline: .now() + Constants.didBecomeActiveTimeout,
                                      execute: item)
    }
}
