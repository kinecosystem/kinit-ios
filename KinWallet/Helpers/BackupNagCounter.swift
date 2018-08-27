//
//  BackupNagCounter.swift
//  KinWallet
//
//  Copyright © 2018 KinFoundation. All rights reserved.
//

import Foundation

private let currentBackupNagCountKey = "org.kinecosystem.kinit.backupNagCount"

class BackupNagCounter {
    static var count: Int {
        return UserDefaults.standard.integer(forKey: currentBackupNagCountKey)
    }

    static func increment() {
        UserDefaults.standard.set(count + 1, forKey: currentBackupNagCountKey)
    }
}

enum BackupPresentationSource {
    case more
    case notificationNag(BackupNagDay)
}

class BackupFlowController {
    let presenter: UIViewController
    let source: BackupPresentationSource

    init(presenter: UIViewController, source: BackupPresentationSource) {
        self.presenter = presenter
        self.source = source
    }

    func startBackup() {
        startBackup(confirmedOverwrite: false)
    }

    private func startBackup(confirmedOverwrite: Bool) {
        if Kin.performedBackup() && !confirmedOverwrite {
            alertBackupOverwrites()
            return
        }

        KinLoader.shared.fetchAvailableBackupHints { [weak presenter] hints in
            DispatchQueue.main.async {
                let backupIntro = StoryboardScene.Backup.backupIntroViewController.instantiate()
                backupIntro.delegate = self
                backupIntro.hints = hints
                let navigationController = BackupNavigationController(rootViewController: backupIntro)
                presenter?.present(navigationController, animated: true)
            }
        }
    }

    private func alertBackupOverwrites() {
        let alertController = UIAlertController(title: L10n.existingBackupOverwriteTitle,
                                                message: L10n.existingBackupOverwriteMessage,
                                                preferredStyle: .alert)
        alertController.addAction(.init(title: L10n.backAction, style: .cancel, handler: nil))
        alertController.addAction(.init(title: L10n.continueAction, style: .default, handler: { [weak self] _ in
            self?.startBackup(confirmedOverwrite: true)
        }))
        presenter.present(alertController, animated: true)
    }
}

extension BackupFlowController: BackupIntroDelegate {
    func backupIntroDidCancel(with emailConfirmAttempts: Int) {
        presenter.dismissAnimated { [weak presenter] in
            if emailConfirmAttempts > 0 {
                let alertController = UIAlertController(title: L10n.performBackupMissingConfirmationTitle,
                                                        message: L10n.performBackupMissingConfirmationMessage,
                                                        preferredStyle: .alert)
                alertController.addAction(.ok)
                presenter?.presentAnimated(alertController)
            }
        }
    }
}
