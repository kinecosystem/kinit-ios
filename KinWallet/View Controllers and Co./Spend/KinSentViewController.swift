//
//  KinSentViewController.swift
//  KinWallet
//
//  Copyright © 2018 KinFoundation. All rights reserved.
//

import UIKit

class KinSentViewController: UIViewController {
    var amount: UInt64 = 0
    @IBOutlet weak var amountLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()

        assert(amount > 0)
        
        amountLabel.text = "You’ve succesfully sent    K \(amount).\nYou can see the details under Balance"
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(viewTapped))
        view.addGestureRecognizer(tapGesture)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        navigationController?.setNavigationBarHidden(true, animated: animated)
    }

    @objc func viewTapped() {
        dismiss(animated: true)
    }
}
