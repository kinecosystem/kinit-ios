//
//  MoveKinErrorPageViewController.swift
//  KinWallet
//
//  Copyright © 2019 KinFoundation. All rights reserved.
//

import UIKit
import MoveKin
import KinitDesignables

class MoveKinErrorPageViewController: MoveKinFinalPageViewController {
    override func viewDidLoad() {
        super.viewDidLoad()

        gradientView.colors = [UIColor(red: 237, green: 25, blue: 57),
                               UIColor(red: 255, green: 176, blue: 183)]
        titleLabel.text = L10n.MoveKin.SendingFailed.title
        subtitleLabel.text = L10n.MoveKin.SendingFailed.subtitle
    }
}

extension MoveKinErrorPageViewController: MoveKinErrorPage {
    func setupMoveKinErrorPage(finishHandler: @escaping () -> Void) {
        self.finishHandler = finishHandler
    }
}
