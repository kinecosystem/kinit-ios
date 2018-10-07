//
//  BackupNagViewController.swift
//  KinWallet
//
//  Copyright © 2018 KinFoundation. All rights reserved.
//

import UIKit

enum BackupNagDay: Int {
    case now = 0
    case week = 6
    case twoWeeks = 13
    case month = 29
}

extension BackupNagDay {
    var alertTitle: String {
        switch self {
        case .now: return L10n.backupNagZeroTitle
        case .week: return L10n.backupNagSevenTitle
        case .twoWeeks: return L10n.backupNagFourteenTitle
        case .month: return L10n.backupNagThirtyTitle
        }
    }

    var alertMessage: String {
        switch self {
        case .now: return L10n.backupNagZeroMessage
        case .week: return L10n.backupNagSevenMessage
        case .twoWeeks: return L10n.backupNagFourteenMessage
        case .month: return L10n.backupNagThirtyMessage
        }
    }

    var toAnalytics: Events.BackupNotificationType {
        switch self {
        case .now: return .day1
        case .week: return .day7
        case .twoWeeks: return .day14
        case .month: return .day30
        }
    }
}

class BackupNagViewController: KinAlertController {
    var nagDay: BackupNagDay!

    convenience init(nagDay: BackupNagDay, backupNowHandler: @escaping () -> Void) {
        self.init(title: nagDay.alertTitle,
                  titleImage: Asset.backupNagHeader.image,
                  message: nagDay.alertMessage,
                  primaryAction: KinAlertAction(title: L10n.backUpAction, handler: {
                    Events.Analytics
                        .ClickBackupButtonOnBackupNotificationPopup(backupNotificationType: nagDay.toAnalytics)
                        .send()
                    backupNowHandler()
                  }),
                  secondaryAction: KinAlertAction(title: L10n.later))
        self.nagDay = nagDay
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        Events.Analytics
            .ViewBackupNotificationPopup(backupNotificationType: nagDay.toAnalytics)
            .send()
    }
}
