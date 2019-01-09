//
//  SendKinAmountInputViewController.swift
//  KinWallet
//
//  Copyright © 2019 KinFoundation. All rights reserved.
//

import UIKit
import MoveKin

class SendKinAmountInputViewController: UIViewController, MoveKinSelectAmountStage {
    var amountSelectionBlock: ((UInt) -> Void)?
}
