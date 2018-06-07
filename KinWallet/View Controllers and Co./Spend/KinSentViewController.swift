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

        let formattedAmount = KinAmountFormatter().string(from: NSNumber(value: amount))!
        let message = "You’ve succesfully sent K \(formattedAmount).\nYou can see the details under Balance"
        let kRange = (message as NSString).range(of: " K ")
        let attributedMessage = NSMutableAttributedString(string: message)
        attributedMessage.addAttribute(.font, value: FontFamily.KinK.regular.font(size: 10), range: kRange)
        amountLabel.attributedText = attributedMessage
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

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
}
