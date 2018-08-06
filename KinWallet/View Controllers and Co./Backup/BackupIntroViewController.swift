//
//  BackupIntroViewController.swift
//  KinWallet
//
//  Copyright © 2018 KinFoundation. All rights reserved.
//

import UIKit

class BackupIntroViewController: UIViewController {
    var hints: [String: AvailableBackupHint]?

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .white
        KinLoader.shared.fetchAvailableBackupHints(skipCache: true)

        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel",
                                                           style: .plain,
                                                           target: self,
                                                           action: #selector(cancel))
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    @objc func cancel() {
        dismiss(animated: true, completion: nil)
    }
}
