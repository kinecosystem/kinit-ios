//
//  SendingKinToAppViewController.swift
//  KinWallet
//
//  Copyright © 2019 KinFoundation. All rights reserved.
//

import UIKit
import MoveKin
import KinitDesignables

class SendingKinToAppViewController: UIViewController {
    var appIconURL: URL!
    var appName: String!
    let initialBalance = Kin.shared.balance

    let transferringKinViewController: TransferringKinViewController = {
        let transferringViewController = StoryboardScene.Earn.transferringKinViewController.instantiate()
        transferringViewController.initialBalance = Kin.shared.balance

        return transferringViewController
    }()

    let gradientView: GradientView = {
        let v = GradientView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.direction = .vertical
        v.colors = UIColor.blueGradientColors1

        return v
    }()

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.addAndFit(gradientView)
        transferringKinViewController.transferType = .moveToApp(appName, appIconURL)
        addAndFit(transferringKinViewController)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
}

extension SendingKinToAppViewController: MoveKinSendingPage {
    func sendKinDidStart(amount: UInt) {

    }

    func sendKinDidSucceed(amount: UInt, moveToSentPage: @escaping () -> Void) {
        transferringKinViewController.transactionSucceeded(newBalance: initialBalance - UInt64(amount)) {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4, execute: moveToSentPage)
        }
    }

    func sendKinDidFail(moveToErrorPage: @escaping () -> Void) {
        moveToErrorPage()
    }
}
