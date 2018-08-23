//
//  MoreViewController.swift
//  Kinit
//

import UIKit

class MoreViewController: UIViewController {
    @IBOutlet var separators: [UIView]! {
        didSet {
            separators.forEach { $0.backgroundColor = UIColor.kin.lightGray }
        }
    }

    @IBOutlet weak var versionLabel: UILabel! {
        didSet {
            versionLabel.font = FontFamily.Roboto.regular.font(size: 14)
            versionLabel.textColor = UIColor.kin.gray
            versionLabel.text = "V. \(Bundle.appVersion) (Build \(Bundle.buildNumber))"
        }
    }

    @IBOutlet weak var supportLabel: UILabel! {
        didSet {
            supportLabel.font = FontFamily.Roboto.regular.font(size: 18)
            supportLabel.textColor = UIColor.kin.gray
            supportLabel.text = L10n.support
        }
    }

    @IBOutlet weak var emailButton: UIButton! {
        didSet {
            emailButton.makeKinButtonFilled()
            emailButton.setTitle(L10n.emailUs, for: .normal)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        let fourTapGesture = UITapGestureRecognizer(target: self, action: #selector(tapGestureRecognized))
        fourTapGesture.numberOfTapsRequired = 4

        #if DEBUG
        fourTapGesture.numberOfTouchesRequired = 2
        #else
        fourTapGesture.numberOfTouchesRequired = 4
        #endif

        view.addGestureRecognizer(fourTapGesture)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        Events.Analytics.ViewProfilePage().send()
    }

    @IBAction func emailTapped(_ sender: Any) {
        KinSupportViewController.present(from: self)
    }
}

extension MoreViewController {
    @objc func tapGestureRecognized() {
        #if DEBUG
        displayConfigPanel()
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
        present(alertController, animated: true)
        #endif
    }

    func displayConfigPanel() {
        let currentServerIdentifier = KinWebService.shared.identifier
        let message =
        """
        User ID: \(User.current!.userId)
        Device Token: \(User.current!.deviceToken ?? "No token")
        Current server is \(currentServerIdentifier) (\(KinWebService.shared.serverHost)).
        Changing servers will delete all user data, including the Stellar account!
        """

        let alertController = UIAlertController(title: "Would you like to change the server URL?",
                                                message: message,
                                                preferredStyle: .actionSheet)

        let possibleServices: [IdentifiableWebService.Type] = [KinStagingService.self, KinProductionService.self]
        if let toUse = possibleServices.filter({ $0.identifier != currentServerIdentifier }).first {
            alertController.addAction(UIAlertAction(title: toUse.identifier, style: .default) { _ in
                KinWebService.setAlternateService(type: toUse)
            })
        }

        alertController.addAction(.init(title: "Enable Notifications", style: .default, handler: { _ in
            AppDelegate.shared.requestNotifications()
        }))

        alertController.addAction(.init(title: "Copy User ID", style: .default, handler: { _ in
            UIPasteboard.general.string = User.current?.userId
        }))

        alertController.addAction(.init(title: "Copy Device Token", style: .default, handler: { _ in
            UIPasteboard.general.string = User.current?.deviceToken
        }))

        alertController.addAction(.init(title: "Delete task and results", style: .default, handler: { _ in
            if let task: Task = SimpleDatastore.loadObject(nextTaskIdentifier) {
                SimpleDatastore.delete(objectOf: Task.self, with: nextTaskIdentifier)
                SimpleDatastore.delete(objectOf: TaskResults.self, with: task.identifier)
            }
        }))

        alertController.addAction(.init(title: "Delete Kin Account", style: .destructive, handler: { _ in
            Kin.shared.resetKeyStore()
        }))

        alertController.addAction(.cancel())
        present(alertController, animated: true)
    }

    func wrongConfigPassword() {
        let alertController = UIAlertController(title: "Wrong config password",
                                                message: nil,
                                                preferredStyle: .alert)
        alertController.addAction(.ok())
        present(alertController, animated: true)
    }
}
