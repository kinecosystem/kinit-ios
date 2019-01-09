//
//  SendingKinToAppViewController.swift
//  KinWallet
//
//  Copyright © 2019 KinFoundation. All rights reserved.
//

import UIKit
import MoveKin

class SendingKinToAppViewController: UIViewController {

}

extension SendingKinToAppViewController: MoveKinSendingStage {
    func sendKinDidStart() {

    }

    func sendKinDidSucceed(moveToSentPage: @escaping () -> Void) {
        moveToSentPage()
    }

    func sendKinDidFail() {

    }
}
