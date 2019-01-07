//
//  ConnectingAppsViewController.swift
//  KinWallet
//
//  Copyright © 2019 KinFoundation. All rights reserved.
//

import UIKit

class ConnectingAppsViewController: UIViewController {
    let titleLabel: UILabel = {
        let l = UILabel()
        l.translatesAutoresizingMaskIntoConstraints = false
        l.text = "Connecting Apps"
        return l
    }()

    override func loadView() {
        let v = UIView()
        v.addSubview(titleLabel)
        titleLabel.centerXAnchor.constraint(equalTo: v.centerXAnchor).isActive = true
        titleLabel.centerYAnchor.constraint(equalTo: v.centerYAnchor).isActive = true

        view = v
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
}
