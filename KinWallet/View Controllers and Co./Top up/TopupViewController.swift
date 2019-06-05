//
//  TopupViewController.swift
//  KinWallet
//
//  Copyright © 2019 KinFoundation. All rights reserved.
//

import UIKit

class TopupSuccessView {

}

class TopupFailureView {

}

class TopupViewController: UIViewController {
    let appBundleIdentifier: String
    let destinationAddress: String
    let appURLScheme: String

    let amountInputViewController = KinAmountInputViewController()
    let actionBar: KinInputActionBar

    let navigationBar = with(UINavigationBar()) {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.isTranslucent = false
        $0.setBackgroundImage(.from(.white), for: .default)
        $0.shadowImage = .init()
        $0.titleTextAttributes = [.font: FontFamily.Sailec.regular.font(size: 18),
                                  .foregroundColor: UIColor.black]
    }

    init(topupRequest: OneWalletTopupRequest) {
        self.appBundleIdentifier = topupRequest.appBundleIdentifier
        self.destinationAddress = topupRequest.publicAddress
        self.appURLScheme = topupRequest.appURLScheme

        actionBar = KinInputActionBar(title: "Top up",
                                      progressText: "Topping up",
                                      style: .default)

        super.init(nibName: nil, bundle: nil)

        actionBar.delegate = self

        let navigationItem = UINavigationItem(title: "Top up \(topupRequest.appName)")
        let xImage = Asset.closeButtonBlack.image.withRenderingMode(.alwaysOriginal)
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: xImage,
                                                           landscapeImagePhone: nil,
                                                           style: .plain,
                                                           target: self,
                                                           action: #selector(cancelTapped))
        navigationBar.items = [navigationItem]
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        actionBar.isEnabled = false
        actionBar.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(actionBar)
        view.leadingAnchor.constraint(equalTo: actionBar.leadingAnchor).isActive = true
        view.bottomAnchor.constraint(equalTo: actionBar.bottomAnchor).isActive = true
        view.trailingAnchor.constraint(equalTo: actionBar.trailingAnchor).isActive = true
        actionBar.heightAnchor.constraint(equalToConstant: 72).isActive = true

        amountInputViewController.delegate = self
        add(amountInputViewController, to: view) {
            $0.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                view.topAnchor.constraint(equalTo: $0.topAnchor),
                view.trailingAnchor.constraint(equalTo: $0.trailingAnchor),
                view.leadingAnchor.constraint(equalTo: $0.leadingAnchor),
                actionBar.topAnchor.constraint(equalTo: $0.bottomAnchor)
                ])
        }

        view.addSubview(navigationBar)
        view.leadingAnchor.constraint(equalTo: navigationBar.leadingAnchor).isActive = true
        let topAnchor: NSLayoutYAxisAnchor

        if #available(iOS 11.0, *) {
            topAnchor = view.safeAreaLayoutGuide.topAnchor
        } else {
            topAnchor = topLayoutGuide.topAnchor
        }

        topAnchor.constraint(equalTo: navigationBar.topAnchor).isActive = true

        view.trailingAnchor.constraint(equalTo: navigationBar.trailingAnchor).isActive = true
    }

    fileprivate func topupSucceded() {
        print("Success topping up")

        DispatchQueue.main.async {
            self.actionBar.finishProgress(duration: 0.3) { _ in
                //TODO: Replace action bar with option to take the user back to the app
                //for now: launch the app back
                self.launchBackApp()
                self.dismissAnimated()
            }
        }
    }

    @objc private func cancelTapped() {
        launchBackApp()
        dismiss(animated: false)
    }

    fileprivate func topupFailed(_ error: Error) {
        print("Failure topping up: \(error)")
    }

    fileprivate func launchBackApp() {
        guard let url = URL(string: appURLScheme + "://") else {
            return
        }

        UIApplication.shared.open(url)
    }
}

extension TopupViewController: KinAmountInputDelegate {
    func amountInputDidChange(_ amount: UInt64) {
        actionBar.isEnabled = amount > 0
    }
}

extension TopupViewController: KinInputActionBarDelegate {
    func kinInputActionBarDidTap() {
        amountInputViewController.isEnabled = false
        actionBar.startProgress(duration: 30)
        let tempOrderId = "Topup\(appBundleIdentifier)".replacingOccurrences(of: "-", with: "")

        Kin.shared.send(amountInputViewController.amount,
                        orderId: tempOrderId,
                        to: destinationAddress,
                        type: .crossApp) { [weak self] result in
            switch result {
            case .success: self?.topupSucceded()
            case .failure(let error): self?.topupFailed(error)
            }
        }
    }
}
