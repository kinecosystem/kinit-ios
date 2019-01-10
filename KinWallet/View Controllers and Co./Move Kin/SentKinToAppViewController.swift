//
//  SentKinToAppViewController.swift
//  KinWallet
//
//  Copyright © 2019 KinFoundation. All rights reserved.
//

import UIKit
import KinitDesignables
import MoveKin

class SentKinToAppViewController: MoveKinFinalPageViewController {
    var amount: UInt = 0

    override func viewDidLoad() {
        super.viewDidLoad()

        gradientView.colors = UIColor.blueGradientColors2
        
        titleLabel.text = L10n.MoveKin.SendingKinCompleted.title
        let attributedString = NSMutableAttributedString()
        attributedString.append(.init(string: L10n.MoveKin.SendingKinCompleted.Subtitle.prefix))
        attributedString.append(.init(string: " "))
        attributedString.append(.init(string: "K",
                                      attributes: [.font: FontFamily.KinK.regular.font(size: 8)]))
        attributedString.append(.init(string: " " + String(describing: amount) + ", "))
        attributedString.append(.init(string: L10n.MoveKin.SendingKinCompleted.Subtitle.postfix))
        subtitleLabel.attributedText = attributedString
    }
}

extension SentKinToAppViewController: MoveKinSentPage {
    func setupSentKinPage(amount: UInt, finishHandler: @escaping () -> Void) {
        self.amount = amount
        self.finishHandler = finishHandler
    }
}
