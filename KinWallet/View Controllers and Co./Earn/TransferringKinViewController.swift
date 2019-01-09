//
//  TransferringKinViewController.swift
//  Kinit
//

import UIKit
import Lottie
import KinitDesignables

enum KinTransferType {
    case receive
    case moveToApp(String, URL?)
}

extension KinTransferType: Equatable {}

final class TransferringKinViewController: UIViewController {
    var initialBalance: UInt64!
    var finishTapped: (() -> Void)?
    var transferType = KinTransferType.receive

    @IBOutlet weak var kinOnTheWayLabel: UILabel!

    @IBOutlet weak var balanceExplanationLabel: UILabel!
    let amountFormatter = KinAmountFormatter()
    @IBOutlet weak var fireworksImageView: UIImageView! {
        didSet {
            fireworksImageView.alpha = 0
            fireworksImageView.transform = .init(scaleX: 0.4, y: 0.4)
        }
    }

    @IBOutlet weak var coinsImageView: UIImageView!
    @IBOutlet weak var appIconImageView: UIImageView!

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
            loaderView.setAnimation(named: "CirclesLoader.json")
            loaderView.loopAnimation = true
        }
    }

    @IBOutlet weak var loaderStackView: UIStackView!

    @IBOutlet weak var tapToFinishLabel: UILabel! {
        didSet {
            tapToFinishLabel.font = FontFamily.Roboto.bold.font(size: 16)
            tapToFinishLabel.alpha = 0
            tapToFinishLabel.text = L10n.tapToFinish
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

        switch transferType {
        case .receive:
            appIconImageView.isHidden = true
            kinOnTheWayLabel.text = L10n.TransferringKinOnItsWay.receive
        case .moveToApp(let appName, let appIconUrl):
            if let url = appIconUrl {
                appIconImageView.loadImage(url: url)
                kinOnTheWayLabel.text = L10n.TransferringKinOnItsWay.sendToApp
            } else {
                appIconImageView.isHidden = true
                kinOnTheWayLabel.text = L10n.TransferringKinOnItsWay.sendToApp + appName
            }
        }
    }

    func transactionSucceeded(newBalance: UInt64, completion: (() -> Void)? = nil) {
        UIView.animate(withDuration: 0.75, animations: {
            self.loaderStackView.alpha = 0
        }, completion: { _ in
            self.loaderView.stop()
        })

        balanceLabel.count(from: CGFloat(initialBalance), to: CGFloat(newBalance))
        balanceLabel.completionBlock = { [weak self] in
            guard let self = self else {
                return
            }

            if let completion = completion {
                completion()
            }

            if self.transferType == .receive {
                UIView.transition(with: self.balanceExplanationLabel,
                                  duration: 0.1,
                                  options: .transitionCrossDissolve,
                                  animations: {
                                    self.balanceExplanationLabel.text = L10n.transferringKinNewBalance
                }, completion: nil)

                self.fireworksImageView.alpha = 0.2
                UIView.animate(withDuration: 0.75, animations: {
                    self.coinsImageView.alpha = 0
                    self.gradientView.alpha = 1
                    self.fireworksImageView.alpha = 1
                    self.fireworksImageView.transform = .identity
                }, completion: { _ in
                    let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.viewTapped))
                    self.view.addGestureRecognizer(tapGesture)
                    UIView.animate(withDuration: 0.3, delay: 0.2, options: [], animations: {
                        self.fireworksImageView.alpha = 0
                    }, completion: nil)
                })

                UIView.animate(withDuration: 1,
                               delay: 0,
                               options: [.curveEaseInOut, .autoreverse, .repeat],
                               animations: {
                                self.tapToFinishLabel.alpha = 0.7
                }, completion: nil)
            }
        }
    }

    @objc func viewTapped() {
        finishTapped?()
    }
}
