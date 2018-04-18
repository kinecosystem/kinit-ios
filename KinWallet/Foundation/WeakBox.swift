//
//  WeakDelegateBox.swift
//  KinWallet
//
//  Copyright © 2018 KinFoundation. All rights reserved.
//

import Foundation

class WeakBox {
    weak var value: AnyObject?

    init(value: AnyObject) {
        self.value = value
    }
}
