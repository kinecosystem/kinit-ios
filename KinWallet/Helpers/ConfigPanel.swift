//
//  ConfigPanel.swift
//  KinWallet
//
//  Copyright © 2018 KinFoundation. All rights reserved.
//

import UIKit

class ConfigPanel {
    class func show(from presenter: UIViewController) {
        #if DEBUG
        displayConfigPanel(from: presenter)
        #else
        let alertController = UIAlertController(title: "Config Panel",
                                                message: "Please insert the password",
                                                preferredStyle: .alert)
        var observer: AnyObject?

        let passwordAction = UIAlertAction(title: "Confirm", style: .default) { _ in
            if let observer = observer {
                NotificationCenter.default.removeObserver(observer)
            }

            guard let password = alertController.textFields?[0].text else {
                return
            }

            if password.md5Hex == Configuration.shared.moreScreenTapsPassword {
                self.displayConfigPanel()
            } else {
                self.wrongConfigPassword()
            }
        }

        alertController.addTextField { textField in
            textField.isSecureTextEntry = true
            observer = NotificationCenter.default.addObserver(forName: .UITextFieldTextDidChange,
                                                              object: nil,
                                                              queue: nil) { _ in
                                                                passwordAction.isEnabled = !(textField.text?.isEmpty ?? false)
            }
        }
        passwordAction.isEnabled = false

        alertController.addCancelAction {
            if let observer = observer {
                NotificationCenter.default.removeObserver(observer)
            }
        }

        alertController.addAction(passwordAction)
        presenter.present(alertController, animated: true)
        #endif
    }

    class func displayConfigPanel(from presenter: UIViewController) {
        let currentServerIdentifier = KinWebService.shared.identifier
        let message =
        """
        User ID: \(User.current!.userId)
        Phone Number: \(User.current!.phoneNumber ?? "No number registered")
        Public Address: \(Kin.shared.publicAddress)
        Device Token: \(User.current!.deviceToken ?? "No token")
        Current server is \(currentServerIdentifier) (\(KinWebService.shared.serverHost)).
        """

        let alertController = UIAlertController(title: nil,
                                                message: message,
                                                preferredStyle: .actionSheet)

        alertController.addAction(title: "Enable Notifications", style: .default) {
            AppDelegate.shared.requestNotifications()
        }

        alertController.addAction(title: "Copy User ID", style: .default) {
            UIPasteboard.general.string = User.current?.userId
        }

        alertController.addAction(title: "Copy Device Token", style: .default) {
            UIPasteboard.general.string = User.current?.deviceToken
        }

        alertController.addAction(title: "Copy Public Address", style: .default) {
            UIPasteboard.general.string = Kin.shared.publicAddress
        }

        alertController.addAction(title: "Mark Backup Not Done", style: .default) {
            Kin.setPerformedBackup(false)
        }

        alertController.addAction(title: "Delete task and results", style: .destructive) {
            if let task: Task = SimpleDatastore.loadObject(nextTaskIdentifier) {
                SimpleDatastore.delete(objectOf: Task.self, with: nextTaskIdentifier)
                SimpleDatastore.delete(objectOf: TaskResults.self, with: task.identifier)
            }
        }

        alertController.addAction(title: "Delete Kin Account", style: .destructive) {
            Kin.shared.resetKeyStore()
        }

        alertController.addCancelAction()
        presenter.present(alertController, animated: true)
    }

    class func wrongConfigPassword(from presenter: UIViewController) {
        let alertController = UIAlertController(title: "Wrong config password",
                                                message: nil,
                                                preferredStyle: .alert)
        alertController.addAction(.ok)
        presenter.present(alertController, animated: true)
    }
}
