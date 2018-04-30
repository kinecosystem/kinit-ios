//
//  UIView+KinWallet.swift
//  KinWallet
//
//  Copyright © 2018 KinFoundation. All rights reserved.
//

import UIKit

enum LayoutReference {
    case safeArea
    case superview
}

extension UIView {
    func addAndFit(_ subview: UIView, layoutReference: LayoutReference = .superview) {
        addSubview(subview)
        subview.fitInSuperview()
    }

    func addAndCenter(_ subview: UIView) {
        addSubview(subview)
        subview.centerInSuperview()
    }

    func fitInSuperview(with reference: LayoutReference = .superview) {
        guard let superview = superview else {
            KLogError("fitInSuperview() called when superview is nil")
            return
        }

        translatesAutoresizingMaskIntoConstraints = false

        let g: UILayoutGuide?

        if #available(iOS 11.0, *) {
            g = reference == .safeArea ? superview.safeAreaLayoutGuide : nil
        } else {
            g = nil
        }

        leadingAnchor.constraint(equalTo: g?.leadingAnchor ?? superview.leadingAnchor).isActive = true
        topAnchor.constraint(equalTo: g?.topAnchor ?? superview.topAnchor).isActive = true
        trailingAnchor.constraint(equalTo: g?.trailingAnchor ?? superview.trailingAnchor).isActive = true
        bottomAnchor.constraint(equalTo: g?.bottomAnchor ?? superview.bottomAnchor).isActive = true
    }

    func centerInSuperview() {
        guard let superview = superview else {
            KLogError("centerInSuperview() called when superview is nil")
            return
        }

        translatesAutoresizingMaskIntoConstraints = false

        centerXAnchor.constraint(equalTo: superview.centerXAnchor).isActive = true
        centerYAnchor.constraint(equalTo: superview.centerYAnchor).isActive = true
    }
}

extension UIView {
    var isRightToLeft: Bool {
        return UIView.userInterfaceLayoutDirection(for: semanticContentAttribute) == .rightToLeft
    }
}

extension UIView {
    func drawAsImage() -> UIImage {
        UIGraphicsBeginImageContextWithOptions(bounds.size, true, UIScreen.main.scale)
        drawHierarchy(in: bounds, afterScreenUpdates: true)
        let snapshot = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return snapshot!
    }

    func applyThinShadow(color: UIColor = UIColor.kin.cadetBlue.withAlphaComponent(0.5),
                         radius: CGFloat = 3,
                         opacity: Float = 3,
                         offset: CGSize = .init(width: 0, height: -1)) {
        layer.shadowColor = color.cgColor
        layer.shadowRadius = radius
        layer.shadowOpacity = opacity
        layer.shadowOffset = offset
    }
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
            var p = [NSNumber](NSNumber(value: 0))
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
