//
//  EarnKinAnimationViewController.swift
//  KinWallet
//
//  Copyright © 2018 KinFoundation. All rights reserved.
//

import UIKit

class EarnKinAnimationViewController: UIViewController {
    @IBOutlet weak var textLabel: UILabel! {
        didSet {
            textLabel.font = FontFamily.Roboto.regular.font(size: 26)
            textLabel.textColor = UIColor.kin.appTint
        }
    }
}
