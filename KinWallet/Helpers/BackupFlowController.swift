//
//  BackupFlowController.swift
//  KinWallet
//
//  Copyright © 2018 KinFoundation. All rights reserved.
//

import UIKit

enum BackupPresentationSource {
    case more
    case notificationNag(BackupNagDay)
}

protocol BackupFlowDelegate: class {
    func backupFlowDidCancel()
    func backupFlowDidFinish()
}

class BackupFlowController {
    let presenter: UIViewController
    let source: BackupPresentationSource
    weak var delegate: BackupFlowDelegate?

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    init(presenter: UIViewController, source: BackupPresentationSource) {
        self.presenter = presenter
        self.source = source

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(backupDidComplete(_:)),
                                               name: .KinitBackupCompleted,
                                               object: nil)
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
        alertController.addAction(title: L10n.backAction, style: .cancel) { [weak self] in
            self?.delegate?.backupFlowDidCancel()
        }

        alertController.addAction(title: L10n.continueAction, style: .default) { [weak self] in
            self?.startBackup(confirmedOverwrite: true)
        }

        presenter.present(alertController, animated: true)
    }

    @objc private func backupDidComplete(_ notification: Notification) {
        presenter.dismissAnimated { [weak self] in
            self?.delegate?.backupFlowDidFinish()
        }
    }
}

extension BackupFlowController: BackupIntroDelegate {
    func backupIntroDidCancel(with emailConfirmAttempts: Int) {
        presenter.dismissAnimated { [weak self] in
            if emailConfirmAttempts > 0 {
                let alertController = UIAlertController(title: L10n.performBackupMissingConfirmationTitle,
                                                        message: L10n.performBackupMissingConfirmationMessage,
                                                        preferredStyle: .alert)
                alertController.addAction(.ok)
                self?.presenter.presentAnimated(alertController)
            }

            self?.delegate?.backupFlowDidCancel()
        }
    }
}
