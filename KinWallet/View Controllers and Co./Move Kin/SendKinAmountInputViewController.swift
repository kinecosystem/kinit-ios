//
//  SendKinAmountInputViewController.swift
//  KinWallet
//
//  Copyright © 2019 KinFoundation. All rights reserved.
//

import UIKit
import MoveKin

class SendKinAmountInputViewController: UIViewController {
    var amountSelectionBlock: ((UInt) -> Void)?
}

extension SendKinAmountInputViewController: MoveKinSelectAmountPage {
    func setupSelectAmountPage(selectionHandler: @escaping (UInt) -> Void) {
        amountSelectionBlock = selectionHandler
    }
}
