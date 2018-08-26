//
//  BackupDoneViewController.swift
//  KinWallet
//
//  Copyright © 2018 KinFoundation. All rights reserved.
//

import UIKit
import Lottie

class BackupDoneViewController: UIViewController {
    @IBOutlet weak var backupDoneTitleLabel: UILabel! {
        didSet {
            backupDoneTitleLabel.textColor = UIColor.kin.appTint
        }
    }

    @IBOutlet weak var backupDoneMessageLabel: UILabel! {
        didSet {
            backupDoneMessageLabel.text = L10n.backupCompleteMessage
            backupDoneMessageLabel.textColor = UIColor.kin.gray
        }
    }

    @IBOutlet weak var lockView: LOTAnimationView! {
        didSet {
            lockView.backgroundColor = .clear
            lockView.setAnimation(named: "LockAnimation.json")
            lockView.loopAnimation = false
            lockView.alpha = 0
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        navigationController?.setNavigationBarHidden(true, animated: animated)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        Events.Business.WalletBackedUp().send()
        Kin.setPerformedBackup()

        UIView.animate(withDuration: 0.8, delay: 0.8, options: [], animations: {
            self.lockView.alpha = 1
        }, completion: { _ in
            FeedbackGenerator.notifySuccessIfAvailable()
            self.lockView.play { _ in
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
                    self.navigationController?.transitioningDelegate = self
                    self.dismiss(animated: true, completion: nil)
                }
            }
        })
    }
}

extension BackupDoneViewController: UIViewControllerTransitioningDelegate {
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return AlphaTransitionAnimator(duration: 0.6)
    }
}
