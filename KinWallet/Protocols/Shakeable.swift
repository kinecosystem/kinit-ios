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

extension UIView: Shakeable {
    func shake(times: UInt = 2,
               delta: CGFloat = 10,
               direction: ShakeDirection = .horizontal) {
        let animation = CAKeyframeAnimation()
        animation.isAdditive = true

        animation.keyPath = {
            switch direction {
            case .horizontal: return "position.x"
            case .vertical: return "position.y"
            }
        }()

        animation.duration = 0.25 * Double(times)
        let values: [NSNumber] = {
            var p = [NSNumber(value: 0)]
            p += (0...times).flatMap { _ -> [NSNumber] in
                return [NSNumber(value: Float(delta)), NSNumber(value: 0), NSNumber(value: Float(-delta))]
            }
            p.append(NSNumber(value: 0))

            return p
        }()

        animation.values = values
        let valuesCount = values.count
        animation.keyTimes = (0..<valuesCount).map {
            return NSNumber(value: Float($0)/Float(valuesCount))
        }

        layer.add(animation, forKey: "ShakeAnimation")
    }
}
