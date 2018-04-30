//
//  ConfettiView.swift
//  KinWallet
//
//  Copyright © 2018 KinFoundation. All rights reserved.
//

import UIKit

class ConfettiView: UIView {
    var emitter: CAEmitterLayer?
    var isActive: Bool {
        guard let emitter = emitter else {
            return false
        }

        return emitter.birthRate > 0
    }

    var colors: [UIColor]!
    private let shapes: [ImageAsset] = [Asset.confettiNormal,
                                        Asset.confettiStar,
                                        Asset.confettiDiamond,
                                        Asset.confettiTriangle]
    var intensity = 0.5

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        commonInit()
    }

    public override init(frame: CGRect) {
        super.init(frame: frame)

        commonInit()
    }

    func commonInit() {
        colors = [UIColor(red: 0.95, green: 0.40, blue: 0.27, alpha: 1.0),
                  UIColor(red: 1.00, green: 0.78, blue: 0.36, alpha: 1.0),
                  UIColor(red: 0.48, green: 0.78, blue: 0.64, alpha: 1.0),
                  UIColor(red: 0.30, green: 0.76, blue: 0.85, alpha: 1.0),
                  UIColor(red: 0.58, green: 0.39, blue: 0.55, alpha: 1.0)]
    }

    func start() {
        emitter?.removeFromSuperlayer()

        emitter = {
            let e = CAEmitterLayer()
            e.birthRate = 0.6
            e.emitterPosition = CGPoint(x: frame.size.width / 2.0, y: 0)
            e.emitterShape = kCAEmitterLayerLine
            e.emitterSize = CGSize(width: frame.size.width, height: 1)
            e.emitterCells = confettiCells()

            return e
        }()
        layer.addSublayer(emitter!)
    }

    func stop() {
        emitter?.birthRate = 0
    }

    private func confettiCells() -> [CAEmitterCell] {
        func randomSign() -> CGFloat {
            return arc4random() % 2 == 0 ? 1 : -1
        }

        return colors.flatMap { color in
            return shapes.map { shape in
                let sign = randomSign()
                let cell = CAEmitterCell()
                cell.birthRate = Float(6.0 * intensity)
                cell.lifetime = Float(14.0 * intensity)
                cell.lifetimeRange = 0
                cell.color = color.cgColor
                cell.velocity = CGFloat(350.0 * intensity)
                cell.velocityRange = CGFloat(80.0 * intensity)
                cell.emissionLongitude = CGFloat.pi
                cell.emissionRange = CGFloat.pi/4 * sign
                cell.spin = CGFloat(3.5 * intensity)
                cell.spinRange = CGFloat(4.0 * intensity) * sign
                cell.scaleRange = CGFloat(intensity)
                cell.scaleSpeed = CGFloat(-0.1 * intensity)
                cell.contents = shape.image.cgImage

                return cell
            }
        }
    }
}
