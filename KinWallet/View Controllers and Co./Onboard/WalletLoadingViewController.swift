//
//  CreatingWalletViewController.swift
//  KinWallet
//
//  Copyright © 2018 KinFoundation. All rights reserved.
//

import UIKit
import Lottie

class WalletLoadingViewController: UIViewController {
    @IBOutlet weak var descriptionLabel: UILabel! {
        didSet {
            descriptionLabel.font = FontFamily.Roboto.medium.font(size: 16)
            descriptionLabel.textColor = UIColor.kin.gray
        }
    }

    @IBOutlet weak var bottomContainerView: UIView!

    let timeEstimationLabel: UILabel = {
        let l = UILabel()
        l.textAlignment = .center
        l.translatesAutoresizingMaskIntoConstraints = false
        l.text = L10n.creatingYourWalletBePatient
        l.font = FontFamily.Roboto.regular.font(size: 12)
        l.textColor = UIColor.kin.gray

        return l
    }()

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

        addTimeEstimationLabel()
    }

    func addTimeEstimationLabel() {
        addToBottomView(timeEstimationLabel)
    }

    func addToBottomView(_ subview: UIView) {
        bottomContainerView.removeAllSubviews()
        bottomContainerView.addSubview(subview)
        bottomContainerView.leadingAnchor.constraint(equalTo: subview.leadingAnchor).isActive = true
        bottomContainerView.bottomAnchor.constraint(equalTo: subview.bottomAnchor).isActive = true
        bottomContainerView.trailingAnchor.constraint(equalTo: subview.trailingAnchor).isActive = true
    }
}
