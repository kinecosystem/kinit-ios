//
//  Shakeable.swift
//  KinWallet
//
//  Copyright © 2018 KinFoundation. All rights reserved.
//

import UIKit

enum ShakeDirection: Int {
    case horizontal
    case vertical
}

protocol Shakeable {
    func shake(times: UInt, delta: CGFloat, direction: ShakeDirection)
}
