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
    var backupFlowController: BackupFlowController?

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

    @objc func tapGestureRecognized() {
        ConfigPanel.show(from: self)
    }

    @objc fileprivate func presentSupportEmail() {
        KinSupportViewController.present(from: self)
    }

    @objc fileprivate func startBackup() {
        let alreadyBackedUp: Events.AlreadyBackedUp = Kin.performedBackup() ? .yes : .no
        Events.Analytics.ClickBackupButtonOnMorePage(alreadyBackedUp: alreadyBackedUp).send()
        
        backupFlowController = BackupFlowController(presenter: self, source: .more)
        backupFlowController!.startBackup()
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
