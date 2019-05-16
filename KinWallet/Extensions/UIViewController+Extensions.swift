//
//  UIViewController+Extensions.swift
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
    func presentAnimated(_ viewController: UIViewController, completion: (() -> Void)? = nil) {
        present(viewController, animated: true, completion: completion)
    }

    func dismissAnimated(completion: (() -> Void)? = nil) {
        dismiss(animated: true, completion: completion)
    }
}
