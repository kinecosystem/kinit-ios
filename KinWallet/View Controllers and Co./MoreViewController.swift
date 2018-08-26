//
//  MoreViewController.swift
//  Kinit
//

import UIKit

private enum MoreSection {
    case security
    case support

    var items: [MoreSectionItem] {
        switch self {
        case .security: return [.backup]
        case .support: return [.supportEmail]
        }
    }

    var title: String {
        switch self {
        case .security: return L10n.security
        case .support: return L10n.support
        }
    }

    static var allCases: [MoreSection] {
        return [MoreSection.security, .support]
    }
}

private enum MoreSectionItem: String {
    case backup
    case supportEmail

    var title: String {
        switch self {
        case .backup: return L10n.walletBackup
        case .supportEmail: return L10n.emailUs
        }
    }

    var image: UIImage? {
        switch self {
        case .backup: return Asset.moreWalletBackupIcon.image
        case .supportEmail: return Asset.moreSupportIcon.image
        }
    }

    var action: Selector {
        switch self {
        case .backup: return #selector(MoreViewController.startBackup)
        case .supportEmail: return #selector(MoreViewController.presentSupportEmail)
        }
    }
}

class MoreViewController: UITableViewController {
    var performedBackup = false

    let versionLabel: UILabel = {
        let l = UILabel()
        l.font = FontFamily.Roboto.regular.font(size: 14)
        l.textColor = UIColor.kin.gray
        l.text = "V. \(Bundle.appVersion) (Build \(Bundle.buildNumber))"
        return l
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        performedBackup = Kin.performedBackup()

        let fourTapGesture = UITapGestureRecognizer(target: self, action: #selector(tapGestureRecognized))
        fourTapGesture.numberOfTapsRequired = 4

        #if DEBUG
        fourTapGesture.numberOfTouchesRequired = 2
        #else
        fourTapGesture.numberOfTouchesRequired = 4
        #endif

        view.addGestureRecognizer(fourTapGesture)
        tableView.tableFooterView = versionLabel
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        Events.Analytics.ViewProfilePage().send()
        KinLoader.shared.fetchAvailableBackupHints()

        if performedBackup != Kin.performedBackup() {
            performedBackup.toggle()
            let indexPath = IndexPath(row: MoreSection.security.items.index(of: MoreSectionItem.backup)!,
                                      section: MoreSection.allCases.index(of: .security)!)
            tableView.reloadRows(at: [indexPath], with: .fade)
        }
    }

    @objc fileprivate func presentSupportEmail() {
        KinSupportViewController.present(from: self)
    }

    @objc fileprivate func startBackup() {
        KinLoader.shared.fetchAvailableBackupHints { [weak self] hints in
            DispatchQueue.main.async {
                let backupIntro = StoryboardScene.Backup.backupIntroViewController.instantiate()
                backupIntro.hints = hints
                let navigationController = KinNavigationController(rootViewController: backupIntro)
                self?.present(navigationController, animated: true)
            }
        }
    }
}

extension MoreViewController {
    override func numberOfSections(in tableView: UITableView) -> Int {
        return MoreSection.allCases.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return MoreSection.allCases[section].items.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(forIndexPath: indexPath) as MoreTableViewCell
        let item = MoreSection.allCases[indexPath.section].items[indexPath.row]
        cell.textLabel?.text = item.title
        cell.imageView?.image = item.image

        if item == .backup {
            let image = performedBackup ? Asset.backupDoneIcon.image : Asset.backupToDoIcon.image
            cell.accessoryView = UIImageView(image: image)
        }

        return cell
    }
}

extension MoreViewController {
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = MoreSection.allCases[indexPath.section].items[indexPath.row]
        perform(item.action)
        tableView.deselectRow(at: indexPath, animated: true)
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return MoreSection.allCases[section].title
    }

    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        guard let headerView = view as? UITableViewHeaderFooterView else {
            return
        }

        headerView.textLabel?.textColor = UIColor.kin.gray
        headerView.textLabel?.font = FontFamily.Roboto.bold.font(size: 14)
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
        Phone Number: \(User.current!.phoneNumber ?? "No number registered")
        Public Address: \(Kin.shared.publicAddress)
        Device Token: \(User.current!.deviceToken ?? "No token")
        Current server is \(currentServerIdentifier) (\(KinWebService.shared.serverHost)).

        Changing servers will delete all user data, including the Stellar account!
        """

        let alertController = UIAlertController(title: nil,
                                                message: message,
                                                preferredStyle: .actionSheet)

        let possibleServices: [IdentifiableWebService.Type] = [KinStagingService.self, KinProductionService.self]
        if let toUse = possibleServices.filter({ $0.identifier != currentServerIdentifier }).first {
            alertController.addAction(.init(title: "Change server to \(toUse.identifier)", style: .default) { _ in
                KinWebService.setAlternateService(type: toUse)
            })
        }

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
