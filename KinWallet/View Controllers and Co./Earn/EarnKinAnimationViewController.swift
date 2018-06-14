//
//  EarnKinAnimationViewController.swift
//  Kinit
//

import UIKit

final class EarnKinAnimationViewController: UIViewController {
    @IBOutlet weak var textLabel: UILabel! {
        didSet {
            textLabel.font = FontFamily.Roboto.regular.font(size: 26)
            textLabel.textColor = UIColor.kin.appTint
        }
    }
}
