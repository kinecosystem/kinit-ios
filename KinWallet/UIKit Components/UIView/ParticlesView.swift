//
//  ParticlesView.swift
//  Kinit
//

import UIKit

class ParticlesView: UIView {
    var emitter: CAEmitterLayer!
    var images: [UIImage]!
    var emitterSize: CGSize?
    var emitterPosition: CGPoint?

    func start() {
        emitter?.removeFromSuperlayer()
        let intensity = Float(0.5)

        emitter = CAEmitterLayer()
        emitter.emitterShape = .line
        emitter.emitterCells = (0..<16).map {
            let cell = CAEmitterCell()
            cell.birthRate = 10.0 * intensity
            cell.lifetime = 2
            cell.lifetimeRange = 0.5
            cell.alphaRange = 1
            cell.velocity = 80
            cell.yAcceleration = 40
            cell.velocityRange = 40
            cell.emissionLatitude = 0
            cell.emissionRange = .pi / 6
            cell.spin = CGFloat(3.5 * intensity)
            cell.spinRange = CGFloat(4.0 * intensity)
            cell.scaleRange = CGFloat(intensity)
            cell.scaleSpeed = CGFloat(-0.1 * intensity)
            cell.contents = images[$0 % images.count].cgImage
            cell.contentsScale = 2

            return cell
        }

        emitter.emitterPosition = emitterPosition ?? CGPoint(x: frame.width/2, y: frame.height)
        emitter.emitterSize = emitterSize ?? CGSize(width: frame.width, height: 1)
        emitter.beginTime = CACurrentMediaTime()
        layer.addSublayer(emitter)
    }

    func stop() {
        emitter?.birthRate = 0
    }

    func startAndStop(after delay: TimeInterval = 1.0) {
        start()

        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            self.stop()
        }
    }
}
