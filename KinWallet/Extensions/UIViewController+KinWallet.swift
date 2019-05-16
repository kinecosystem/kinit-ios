//
//  UIViewController+KinWallet.swift
//  KinWallet
//
//  Copyright © 2019 KinFoundation. All rights reserved.
//

import UIKit

extension UIViewController {
    func addBalanceLabel() {
        let label = BalanceLabel(kin: Kin.shared)
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: label)
    }
}

extension UIViewController {
    func presentSupportAlert(title: String, message: String) {
        let alertController = UIAlertController(title: title,
                                                message: message,
                                                preferredStyle: .alert)
        alertController.addAction(title: L10n.support, style: .default) { [weak self] in
            guard let self = self else {
                return
            }

            KinSupportViewController.presentSupport(from: self)
        }

        alertController.addAction(title: L10n.tryAgain, style: .default)

        presentAnimated(alertController)
    }
}
