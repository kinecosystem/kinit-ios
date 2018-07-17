//
//  UIControl+KinWallet.swift
//  KinWallet
//
//  Copyright © 2018 KinFoundation. All rights reserved.
//

import UIKit

extension UIControl {
    func removeAllTargets() {
        removeTarget(nil, action: nil, for: .allEvents)
    }
}
