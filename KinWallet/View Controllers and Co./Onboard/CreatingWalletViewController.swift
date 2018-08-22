//
//  CreatingWalletViewController.swift
//  KinWallet
//
//  Copyright © 2018 KinFoundation. All rights reserved.
//

import UIKit
import Lottie

class CreatingWalletViewController: UIViewController {
    @IBOutlet weak var creatingWalletLabel: UILabel! {
        didSet {
            creatingWalletLabel.text = L10n.creatingYourWallet
            creatingWalletLabel.font = FontFamily.Roboto.medium.font(size: 16)
            creatingWalletLabel.textColor = UIColor.kin.gray
        }
    }

    @IBOutlet weak var patienceLabel: UILabel! {
        didSet {
            patienceLabel.text = L10n.creatingYourWalletBePatient
            patienceLabel.font = FontFamily.Roboto.regular.font(size: 12)
            patienceLabel.textColor = UIColor.kin.gray
        }
    }

    @IBOutlet weak var loaderView: LOTAnimationView! {
        didSet {
            loaderView.backgroundColor = .clear
            loaderView.setAnimation(named: "WalletLoader.json")
            loaderView.loopAnimation = true
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        loaderView.play()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
}
