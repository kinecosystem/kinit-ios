//
//  WeakDelegateBox.swift
//  Kinit
//

import Foundation

class WeakBox {
    weak var value: AnyObject?

    init(value: AnyObject) {
        self.value = value
    }
}
