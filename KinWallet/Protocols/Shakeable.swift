//
//  Shakeable.swift
//  Kinit
//

import UIKit

enum ShakeDirection: Int {
    case horizontal
    case vertical
}

protocol Shakeable {
    func shake(times: UInt, delta: CGFloat, direction: ShakeDirection)
}
