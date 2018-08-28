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

        alertController.addAction(UIAlertAction.cancel { _ in
            if let observer = observer {
                NotificationCenter.default.removeObserver(observer)
            }
        })

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

        alertController.addAction(.init(title: "Enable Notifications", style: .default) { _ in
            AppDelegate.shared.requestNotifications()
            })

        alertController.addAction(.init(title: "Copy User ID", style: .default) { _ in
            UIPasteboard.general.string = User.current?.userId
            })

        alertController.addAction(.init(title: "Copy Device Token", style: .default) { _ in
            UIPasteboard.general.string = User.current?.deviceToken
            })

        alertController.addAction(.init(title: "Copy Public Address", style: .default) { _ in
            UIPasteboard.general.string = Kin.shared.publicAddress
            })

        alertController.addAction(.init(title: "Mark Backup Not Done", style: .default) { _ in
            Kin.setPerformedBackup(false)
            })

        alertController.addAction(.init(title: "Delete task and results", style: .destructive, handler: { _ in
            if let task: Task = SimpleDatastore.loadObject(nextTaskIdentifier) {
                SimpleDatastore.delete(objectOf: Task.self, with: nextTaskIdentifier)
                SimpleDatastore.delete(objectOf: TaskResults.self, with: task.identifier)
            }
        }))

        alertController.addAction(.init(title: "Delete Kin Account", style: .destructive) { _ in
            Kin.shared.resetKeyStore()
            })

        alertController.addAction(.cancel())
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
