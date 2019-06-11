//
//  TopupViewController.swift
//  KinWallet
//
//  Copyright © 2019 KinFoundation. All rights reserved.
//

import UIKit

class TopupViewController: UIViewController {
    let appBundleIdentifier: String
    let destinationAddress: String
    let appURLScheme: String
    let appName: String

    let amountInputViewController = KinAmountInputViewController()
    let actionBar: KinInputActionBar

    var completionBarTopConstraint: NSLayoutConstraint?

    let navigationBar = with(UINavigationBar()) {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.isTranslucent = false
        $0.setBackgroundImage(.from(.white), for: .default)
        $0.shadowImage = .init()
        $0.titleTextAttributes = [.font: FontFamily.Sailec.regular.font(size: 18),
                                  .foregroundColor: UIColor.black]
    }

    init(topupRequest: OneWalletTopupRequest) {
        appBundleIdentifier = topupRequest.appBundleIdentifier
        destinationAddress = topupRequest.publicAddress
        appURLScheme = topupRequest.appURLScheme
        appName = topupRequest.appName

        actionBar = KinInputActionBar(title: "Top up",
                                      progressText: "Topping up",
                                      style: .default)

        super.init(nibName: nil, bundle: nil)

        actionBar.delegate = self

        let navigationItem = UINavigationItem(title: "Top up \(appName)")
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
        FeedbackGenerator.notifySuccessIfAvailable()

        let result = TopupCompletionResult.success((appName, amountInputViewController.amount))

        actionBar.finishProgress(duration: 0.2) { _ in
            self.addCompletionBar(result: result)
        }
    }

    @objc private func cancelTapped() {
        launchBackApp()
        dismiss(animated: false)
    }

    fileprivate func topupFailed(_ error: Error) {
        print("Topup failed: \(error)")

        FeedbackGenerator.notifyErrorIfAvailable()
        actionBar.reset(isEnabled: true)
        amountInputViewController.isEnabled = true
        addCompletionBar(result: .failure(error))
    }

    fileprivate func launchBackApp() {
        guard let url = URL(string: appURLScheme + "://") else {
            return
        }

        UIApplication.shared.open(url)
    }

    fileprivate func addCompletionBar(result: TopupCompletionResult) {
        let completionBar = TopupCompletionBar(result: result, delegate: self)
        completionBar.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(completionBar)

        let constraintToDeactivate = completionBar.topAnchor.constraint(equalTo: view.bottomAnchor)
        NSLayoutConstraint.activate([
            completionBar.heightAnchor.constraint(equalTo: actionBar.heightAnchor),
            completionBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            completionBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            constraintToDeactivate
            ])

        completionBarTopConstraint = completionBar.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        view.layoutIfNeeded()

        UIView.animate(withDuration: 0.3,
                       delay: 0.1,
                       usingSpringWithDamping: 0.8,
                       initialSpringVelocity: 0.8,
                       options: [],
                       animations: {
            self.completionBarTopConstraint?.isActive = true
            constraintToDeactivate.isActive = false
            self.view.layoutIfNeeded()
        }, completion: nil)
    }

    fileprivate func removeCompletionBar(_ completionBar: TopupCompletionBar) {
        let constraintToActivate = completionBar.topAnchor.constraint(equalTo: view.bottomAnchor)
        UIView.animate(withDuration: 0.3, animations: {
            self.completionBarTopConstraint?.isActive = false
            constraintToActivate.isActive = true
            self.view.layoutIfNeeded()
        }, completion: { _ in
            completionBar.removeFromSuperview()
        })
    }
}

extension TopupViewController: KinAmountInputDelegate {
    func amountInputDidChange(_ amount: UInt64) {
        if let completionBar = view.subviews.compactMap({ $0 as? TopupCompletionBar }).first {
            removeCompletionBar(completionBar)
        }

        actionBar.isEnabled = amount > 0
    }
}

extension TopupViewController: KinInputActionBarDelegate {
    func kinInputActionBarDidTap() {
        amountInputViewController.isEnabled = false
        actionBar.startProgress(duration: 35)
        let tempOrderId = "Topup\(appBundleIdentifier)".replacingOccurrences(of: "-", with: "")

        let cancelButton = navigationBar.topItem?.leftBarButtonItem
        cancelButton?.isEnabled = false

        Kin.shared.send(amountInputViewController.amount,
                        orderId: tempOrderId,
                        to: destinationAddress,
                        type: .crossApp) { [weak self] result in
            DispatchQueue.main.async {
                cancelButton?.isEnabled = true
                switch result {
                case .success: self?.topupSucceded()
                case .failure(let error): self?.topupFailed(error)
                }
            }
        }
    }
}

extension TopupViewController: TopupCompletionBarDelegate {
    func topupCompletionBarDidTapClose(_ completionBar: TopupCompletionBar) {
        removeCompletionBar(completionBar)
    }

    func topupCompletionBarDidTapBackToApp(_ completionBar: TopupCompletionBar) {
        launchBackApp()
        dismiss(animated: false)
    }
}
