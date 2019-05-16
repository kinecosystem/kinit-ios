//
//  UIAlertController+KinWallet.swift
//  KinWallet
//
//  Copyright © 2018 KinFoundation. All rights reserved.
//

import UIKit

extension UIAlertController {
    func addOkAction(handler: (() -> Void)? = nil) {
        addAction(.ok(handler: { _ in
            handler?()
        }))
    }

    func addCancelAction(handler: (() -> Void)? = nil) {
        addAction(.cancel(handler: { _ in
            handler?()
        }))
    }

    func addAction(title: String, style: UIAlertAction.Style = .default, handler: (() -> Void)? = nil) {
        addAction(title: title, style: style) { _ in
            handler?()
        }
    }

    func addAction(title: String, style: UIAlertAction.Style = .default, handler: ((UIAlertAction) -> Void)?) {
        addAction(.init(title: title, style: style, handler: handler))
    }
}
