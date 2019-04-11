//
//  QuestionViewController+Celebration.swift
//  KinWallet
//
//  Copyright © 2018 KinFoundation. All rights reserved.
//

import UIKit

extension QuestionViewController {
    func celebration(forSelecting result: TaskResult) -> AnswerCelebration {
        if let quizData = question.quizData {
            return .quiz(correctAnswerId: quizData.correctAnswerId)
        }

        switch question.type {
        case .tip:
            guard let tipAmount = result.tipAmount, tipAmount > 0 else {
                return .none
            }

            return .particles([Asset.smallHeart.image, Asset.kinCoin.image])
        case .dualImage:
            return .centeredEmoji("😍")
        default:
            return .none
        }
    }

    func celebrateParticles(from originView: UIView,
                            with images: [UIImage],
                            completion: @escaping () -> Void) {
        let particlesView = ParticlesView()
        particlesView.images = [Asset.smallHeart.image, Asset.kinCoin.image]

        let originInViewFrame = collectionView
            .convert(originView.frame, to: view)
        particlesView.frame = CGRect(x: 0,
                                     y: 0,
                                     width: view.frame.width,
                                     height: originInViewFrame.minY)
        particlesView.emitterSize = CGSize(width: originInViewFrame.width, height: 1)
        particlesView.emitterPosition = CGPoint(x: originInViewFrame.minX + originInViewFrame.width/2,
                                                y: particlesView.frame.height)
        view.addSubview(particlesView)
        particlesView.startAndStop()

        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
            completion()
        }
    }

    func celebrateCenteredEmoji(at view: UIView,
                                with string: String,
                                completion: @escaping () -> Void) {
        let blueAlphaView = UIView()
        blueAlphaView.backgroundColor = UIColor.kin.appTint.withAlphaComponent(0.5)
        let emojiLabel = UILabel()
        emojiLabel.font = UIFont.systemFont(ofSize: 40)
        emojiLabel.text = string
        emojiLabel.transform = .init(scaleX: 0.5, y: 0.5)
        emojiLabel.alpha = 0.8

        blueAlphaView.addAndCenter(emojiLabel)
        blueAlphaView.alpha = 0

        view.addAndFit(blueAlphaView)
        UIView.animate(withDuration: 0.2) {
            blueAlphaView.alpha = 1
            emojiLabel.transform = .identity
            emojiLabel.alpha = 1
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            completion()
        }
    }

    func celebrateQuizAnswer(selected: SurveyAnswerCollectionViewCell,
                             correct: SurveyAnswerCollectionViewCell,
                             completion: @escaping () -> Void) {
        let choseCorrectAnswer = selected == correct

        let animations = { [unowned self] in
            let tDuration: TimeInterval = 0.5
            let animationsDuration: TimeInterval = 1.5
            let completionDelay: TimeInterval = tDuration + animationsDuration
            let confetti: QuizConfettiView? = choseCorrectAnswer ? QuizConfettiView() : nil
            let correctAnswerStartTime = choseCorrectAnswer ? 0 : tDuration
            let correctAnswerFrame = selected.superview!.convert(selected.frame, to: self.view)

            if choseCorrectAnswer {
                let correctButtonFakeView = UIImageView(image: correct.drawAsImage())
                correctButtonFakeView.frame = correctAnswerFrame
                self.view.addSubview(correctButtonFakeView)
                correct.markQuizAnswered(correct: true)
                let newFakeButtonImage = correct.drawAsImage()

                correctButtonFakeView.crossDissolve(duration: tDuration, delay: correctAnswerStartTime) {
                    correctButtonFakeView.image = newFakeButtonImage
                }

                confetti!.frame = correctAnswerFrame
                self.view.insertSubview(confetti!, belowSubview: correctButtonFakeView)
                confetti!.start()

                DispatchQueue.main.asyncAfter(deadline: .now() + tDuration) {
                    var labelFrame = correctAnswerFrame.insetBy(dx: 20, dy: 0)
                    labelFrame.size.height = 20
                    let rewardLabel = self.rewardLabel(for: self.question.quizData!.reward)
                    rewardLabel.frame = labelFrame
                    self.view.addSubview(rewardLabel)

                    UIView.animate(withDuration: animationsDuration * 6, delay: 0, options: .curveEaseOut, animations: {
                        rewardLabel.frame.origin.y -= 90
                    }, completion: nil)
                }
            } else {
                correct.crossDissolve(duration: tDuration, delay: correctAnswerStartTime) {
                    correct.markQuizAnswered(correct: true)
                }

                selected.crossDissolve(duration: tDuration) {
                    selected.markQuizAnswered(correct: false)
                }
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + completionDelay, execute: completion)
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3, execute: animations)
    }

    private func rewardLabel(for reward: UInt) -> UILabel {
        let label = UILabel()
        label.textColor = UIColor.kin.quizAnswerCorrect
        label.font = FontFamily.Roboto.bold.font(size: 17)
        label.text = "+ \(reward) KIN"
        label.textAlignment = .right

        return label
    }
}

extension UIView {
    func crossDissolve(duration: TimeInterval, delay: TimeInterval = 0, animations: @escaping () -> Void) {
        let transition = {
            UIView.transition(with: self,
                              duration: duration,
                              options: .transitionCrossDissolve,
                              animations: animations,
                              completion: nil)
        }

        if delay > 0 {
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                transition()
            }
        } else {
            transition()
        }
    }
}

private class QuizConfettiView: UIView {
    var emitter: CAEmitterLayer?
    var isActive: Bool {
        guard let emitter = emitter else {
            return false
        }

        return emitter.birthRate > 0
    }

    var colors: [UIColor]!
    var intensity = 0.5
    let images: [UIImage] = [
        Asset.quizConfettiOval.image,
        Asset.quizConfettiTriangle.image,
        Asset.quizConfettiRectangle.image
        ]

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        commonInit()
    }

    public override init(frame: CGRect) {
        super.init(frame: frame)

        commonInit()
    }

    func commonInit() {
        colors = [
            UIColor(red: 255, green: 225, blue: 100),
            UIColor(red: 121, green: 102, blue: 255),
            UIColor(red: 130, green: 255, blue: 238)
        ]
    }

    func start() {
        emitter?.removeFromSuperlayer()

        emitter = {
            let e = CAEmitterLayer()
            e.birthRate = 0.2
            e.emitterPosition = CGPoint(x: bounds.midX, y: bounds.midY)
            e.emitterShape = .rectangle
            e.emitterSize = CGSize(width: bounds.width / 2, height: bounds.height / 2)
            e.emitterCells = confettiCells()
            e.beginTime = CACurrentMediaTime()

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

        return images.compactMap { image in
            let sign = randomSign()
            let cell = CAEmitterCell()
            cell.birthRate = Float(70 * intensity)
            cell.lifetime = Float(14.0 * intensity)
            cell.lifetimeRange = 0
            cell.velocity = CGFloat(300 * intensity)
            cell.velocityRange = CGFloat(30.0 * intensity)
            cell.emissionLongitude = CGFloat.pi
            cell.emissionRange = CGFloat.pi
            cell.spin = CGFloat(3.5 * intensity)
            cell.spinRange = CGFloat(4.0 * intensity) * sign
            cell.scaleRange = CGFloat(intensity)
            cell.scaleSpeed = CGFloat(-0.1 * intensity)
            cell.contents = image.cgImage
            cell.contentsScale = UIScreen.main.scale

            return cell
        }
    }
}
