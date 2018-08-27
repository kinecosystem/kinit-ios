//
//  UIAlertAction+KinWallet.swift
//  Kinit
//

import UIKit

extension UIAlertAction {
    static func cancel(handler: ((UIAlertAction) -> Void)? = nil) -> UIAlertAction {
        return UIAlertAction(title: L10n.cancel, style: .cancel, handler: handler)
    }

    static var ok: UIAlertAction {
        return .ok()
    }

    static func ok(handler: ((UIAlertAction) -> Void)? = nil) -> UIAlertAction {
        return UIAlertAction(title: L10n.ok, style: .default, handler: handler)
    }
}
