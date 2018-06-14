//
//  TransferringKinViewController.swift
//  KinWallet
//
//  Copyright © 2018 KinFoundation. All rights reserved.
//

import UIKit
import Lottie

final class TransferringKinViewController: UIViewController {
    var initialBalance: UInt64!
    var finishTapped: (() -> Void)?

    @IBOutlet weak var balanceExplanationLabel: UILabel!
    let amountFormatter = KinAmountFormatter()
    @IBOutlet weak var fireworksImageView: UIImageView! {
        didSet {
            fireworksImageView.alpha = 0
            fireworksImageView.transform = .init(scaleX: 0.4, y: 0.4)
        }
    }

    @IBOutlet weak var coinsImageView: UIImageView!
    @IBOutlet weak var balanceLabel: UICountingLabel! {
        didSet {
            balanceLabel.formatBlock = { value in
                return self.amountFormatter.string(from: NSNumber(value: value.native))
                    ?? String(describing: value)
            }
            balanceLabel.method = .easeInOut
            balanceLabel.animationDuration = 1.2
        }
    }

    @IBOutlet weak var loaderView: LOTAnimationView! {
        didSet {
            loaderView.backgroundColor = .clear
            loaderView.setAnimation(named: "Loader1.json")
            loaderView.loopAnimation = true
        }
    }

    @IBOutlet weak var loaderStackView: UIStackView!

    @IBOutlet weak var tapToFinishLabel: UILabel! {
        didSet {
            tapToFinishLabel.font = FontFamily.Roboto.bold.font(size: 16)
            tapToFinishLabel.alpha = 0
        }
    }

    @IBOutlet weak var gradientView: GradientView! {
        didSet {
            gradientView.alpha = 0
            gradientView.direction = .vertical
            gradientView.colors = UIColor.blueGradientColors2
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .clear

        balanceLabel.text = String(Kin.shared.balance)
        loaderView.play()
    }

    func transactionSucceeded(newBalance: UInt64) {
        UIView.animate(withDuration: 0.75, animations: {
            self.loaderStackView.alpha = 0
        }, completion: { _ in
            self.loaderView.stop()
        })

        balanceLabel.count(from: CGFloat(initialBalance), to: CGFloat(newBalance))
        balanceLabel.completionBlock = { [weak self] in
            guard let aSelf = self else {
                return
            }

            UIView.transition(with: aSelf.balanceExplanationLabel,
                              duration: 0.1,
                              options: .transitionCrossDissolve,
                              animations: {
                                aSelf.balanceExplanationLabel.text = "Your new balance"
            }, completion: nil)

            aSelf.fireworksImageView.alpha = 0.2
            UIView.animate(withDuration: 0.75, animations: {
                aSelf.coinsImageView.alpha = 0
                aSelf.gradientView.alpha = 1
                aSelf.fireworksImageView.alpha = 1
                aSelf.fireworksImageView.transform = .identity
            }, completion: { _ in
                let tapGesture = UITapGestureRecognizer(target: aSelf, action: #selector(aSelf.viewTapped))
                aSelf.view.addGestureRecognizer(tapGesture)
                UIView.animate(withDuration: 0.3, delay: 0.2, options: [], animations: {
                    aSelf.fireworksImageView.alpha = 0
                }, completion: nil)
            })

            UIView.animate(withDuration: 1,
                           delay: 0,
                           options: [.curveEaseInOut, .autoreverse, .repeat],
                           animations: {
                            aSelf.tapToFinishLabel.alpha = 0.7
            }, completion: nil)
        }
    }

    @objc func viewTapped() {
        finishTapped?()
    }
}
