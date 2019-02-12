//
//  UIViewController+KinWallet.swift
//  Kinit
//

import UIKit

extension UIViewController {
    func addAndFit(_ child: UIViewController, to view: UIView? = nil, viewConfiguration: ((UIView) -> Void)? = nil) {
        add(child, to: view) {
            $0.fitInSuperview()
            viewConfiguration?($0)
        }
    }

    func add(_ child: UIViewController, to view: UIView? = nil, viewConfiguration: (UIView) -> Void) {
        addChild(child)
        (view ?? self.view).addSubview(child.view)
        viewConfiguration(child.view)
        child.didMove(toParent: self)
    }

    func remove() {
        guard parent != nil else {
            return
        }

        willMove(toParent: nil)
        removeFromParent()
        view.removeFromSuperview()
    }

    func setOrientation(_ orientation: UIInterfaceOrientation) {
        UIDevice.current.setValue(orientation.rawValue, forKey: "orientation")
    }
}

extension UIViewController {
    func addBalanceLabel() {
        let label = BalanceLabel(kin: Kin.shared)
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: label)
    }
}

extension UIViewController {
    func presentAnimated(_ viewController: UIViewController, completion: (() -> Void)? = nil) {
        present(viewController, animated: true, completion: completion)
    }

    func dismissAnimated(completion: (() -> Void)? = nil) {
        dismiss(animated: true, completion: completion)
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

            let helpCenterViewController = HelpCenterViewController()
            helpCenterViewController.setPageToLoad(page: HelpCenterViewController.Page.support,
                                                   category: HelpCenterViewController.Category.backup_restore,
                                                   subCategory: HelpCenterViewController.SubCategory.other)
            self.navigationController?.pushViewController(helpCenterViewController, animated: true)
        }

        alertController.addAction(title: L10n.tryAgain, style: .default)

        presentAnimated(alertController)
    }
}
