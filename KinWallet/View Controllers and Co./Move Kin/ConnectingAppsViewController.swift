//
//  ConnectingAppsViewController.swift
//  KinWallet
//
//  Copyright © 2018 KinFoundation. All rights reserved.
//

import UIKit
import KinitDesignables

private let iconSide: CGFloat = 52

private extension UIImageView {
    func applyAppIconProperties() {
        translatesAutoresizingMaskIntoConstraints = false
        widthAnchor.constraint(equalToConstant: iconSide).isActive = true
        heightAnchor.constraint(equalToConstant: iconSide).isActive = true
        layer.cornerRadius = 8
        layer.masksToBounds = true
    }
}

class ConnectingAppsViewController: UIViewController {
    var appIconURL: URL!

    let gradientView: GradientView = {
        let v = GradientView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.direction = .vertical
        v.colors = UIColor.blueGradientColors1

        return v
    }()

    let connectingAppsLabel: UILabel = {
        let l = UILabel()
        l.translatesAutoresizingMaskIntoConstraints = false
        l.text = "Connecting Apps"
        l.font = FontFamily.Roboto.regular.font(size: 14)
        l.textColor = .white

        return l
    }()

    let kinitIcon: UIImageView = {
        let iv = UIImageView()
        iv.applyAppIconProperties()
        iv.image = UIImage(named: "AppIcon60x60")

        return iv
    }()

    let otherAppIcon: UIImageView = {
        let iv = UIImageView()
        iv.applyAppIconProperties()

        return iv
    }()

    let loaderView: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.widthAnchor.constraint(equalToConstant: iconSide).isActive = true
        v.heightAnchor.constraint(equalToConstant: 3).isActive = true
        v.backgroundColor = UIColor.darkGray

        return v
    }()

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    override func loadView() {
        let v = UIView()
        v.addAndFit(gradientView)

        v.addSubview(connectingAppsLabel)
        v.centerXAnchor.constraint(equalTo: connectingAppsLabel.centerXAnchor).isActive = true
        NSLayoutConstraint(item: connectingAppsLabel,
                           attribute: .centerY,
                           relatedBy: .equal,
                           toItem: v,
                           attribute: .centerY,
                           multiplier: 0.4,
                           constant: 0)
            .isActive = true

        let iconsStackView = UIStackView(arrangedSubviews: [kinitIcon, loaderView, otherAppIcon])
        iconsStackView.spacing = 0
        iconsStackView.axis = .horizontal
        iconsStackView.alignment = .center
        v.addAndCenter(iconsStackView)

        self.view = v
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        otherAppIcon.loadImage(url: appIconURL,
                               placeholderColor: UIColor.kin.lightGray,
                               useInMemoryCache: true)
    }
}
