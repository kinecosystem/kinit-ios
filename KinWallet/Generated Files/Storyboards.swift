// swiftlint:disable all
// Generated using SwiftGen — https://github.com/SwiftGen/SwiftGen

// swiftlint:disable sorted_imports
import Foundation
import UIKit

// swiftlint:disable superfluous_disable_command
// swiftlint:disable file_length

// MARK: - Storyboard Scenes

// swiftlint:disable explicit_type_interface identifier_name line_length type_body_length type_name
internal enum StoryboardScene {
  internal enum Backup: StoryboardType {
    internal static let storyboardName = "Backup"

    internal static let backupConfirmEmailViewController = SceneType<KinWallet.BackupConfirmEmailViewController>(storyboard: Backup.self, identifier: "BackupConfirmEmailViewController")

    internal static let backupDoneViewController = SceneType<KinWallet.BackupDoneViewController>(storyboard: Backup.self, identifier: "BackupDoneViewController")

    internal static let backupIntroViewController = SceneType<KinWallet.BackupIntroViewController>(storyboard: Backup.self, identifier: "BackupIntroViewController")

    internal static let backupQuestionViewController = SceneType<KinWallet.BackupQuestionViewController>(storyboard: Backup.self, identifier: "BackupQuestionViewController")

    internal static let backupSendEmailViewController = SceneType<KinWallet.BackupSendEmailViewController>(storyboard: Backup.self, identifier: "BackupSendEmailViewController")
  }
  internal enum Earn: StoryboardType {
    internal static let storyboardName = "Earn"

    internal static let earnKinAnimationViewController = SceneType<KinWallet.EarnKinAnimationViewController>(storyboard: Earn.self, identifier: "EarnKinAnimationViewController")

    internal static let quizQuestionExplanationViewController = SceneType<KinWallet.QuizQuestionExplanationViewController>(storyboard: Earn.self, identifier: "QuizQuestionExplanationViewController")

    internal static let surveyDoneViewController = SceneType<KinWallet.SurveyDoneViewController>(storyboard: Earn.self, identifier: "SurveyDoneViewController")

    internal static let surveyInfoViewController = SceneType<KinWallet.SurveyInfoViewController>(storyboard: Earn.self, identifier: "SurveyInfoViewController")

    internal static let taskCompletedViewController = SceneType<KinWallet.TaskCompletedViewController>(storyboard: Earn.self, identifier: "TaskCompletedViewController")

    internal static let transferringKinViewController = SceneType<KinWallet.TransferringKinViewController>(storyboard: Earn.self, identifier: "TransferringKinViewController")
  }
  internal enum LaunchScreen: StoryboardType {
    internal static let storyboardName = "LaunchScreen"

    internal static let initialScene = InitialSceneType<UIKit.UIViewController>(storyboard: LaunchScreen.self)

    internal static let splashScreenViewController = SceneType<UIKit.UIViewController>(storyboard: LaunchScreen.self, identifier: "SplashScreenViewController")
  }
  internal enum Main: StoryboardType {
    internal static let storyboardName = "Main"

    internal static let balancePagerTabViewController = SceneType<KinWallet.BalancePagerTabViewController>(storyboard: Main.self, identifier: "BalancePagerTabViewController")

    internal static let balanceViewController = SceneType<KinWallet.BalanceViewController>(storyboard: Main.self, identifier: "BalanceViewController")

    internal static let earnHomeViewController = SceneType<KinWallet.EarnHomeViewController>(storyboard: Main.self, identifier: "EarnHomeViewController")

    internal static let internalKinAlertController = SceneType<KinWallet.InternalKinAlertController>(storyboard: Main.self, identifier: "InternalKinAlertController")

    internal static let moreViewController = SceneType<KinWallet.MoreViewController>(storyboard: Main.self, identifier: "MoreViewController")

    internal static let noticeViewController = SceneType<KinWallet.NoticeViewController>(storyboard: Main.self, identifier: "NoticeViewController")

    internal static let offerWallNavigationController = SceneType<KinWallet.KinNavigationController>(storyboard: Main.self, identifier: "OfferWallNavigationController")

    internal static let rootTabBarController = SceneType<KinWallet.RootTabBarController>(storyboard: Main.self, identifier: "RootTabBarController")

    internal static let surveyNavigationController = SceneType<KinWallet.KinNavigationController>(storyboard: Main.self, identifier: "SurveyNavigationController")

    internal static let useKinViewController = SceneType<KinWallet.UseKinViewController>(storyboard: Main.self, identifier: "UseKinViewController")
  }
  internal enum Onboard: StoryboardType {
    internal static let storyboardName = "Onboard"

    internal static let accountReadyViewController = SceneType<KinWallet.AccountReadyViewController>(storyboard: Onboard.self, identifier: "AccountReadyViewController")

    internal static let accountSourceViewController = SceneType<KinWallet.AccountSourceViewController>(storyboard: Onboard.self, identifier: "AccountSourceViewController")

    internal static let phoneConfirmationViewController = SceneType<KinWallet.PhoneConfirmationViewController>(storyboard: Onboard.self, identifier: "PhoneConfirmationViewController")

    internal static let phoneVerificationRequestViewController = SceneType<KinWallet.PhoneVerificationRequestViewController>(storyboard: Onboard.self, identifier: "PhoneVerificationRequestViewController")

    internal static let restoreBackupQRScannerViewController = SceneType<KinWallet.RestoreBackupQRScannerViewController>(storyboard: Onboard.self, identifier: "RestoreBackupQRScannerViewController")

    internal static let restoreBackupQuestionsViewController = SceneType<KinWallet.RestoreBackupQuestionsViewController>(storyboard: Onboard.self, identifier: "RestoreBackupQuestionsViewController")

    internal static let walletLoadingViewController = SceneType<KinWallet.WalletLoadingViewController>(storyboard: Onboard.self, identifier: "WalletLoadingViewController")

    internal static let welcomeViewController = SceneType<KinWallet.WelcomeViewController>(storyboard: Onboard.self, identifier: "WelcomeViewController")
  }
  internal enum Spend: StoryboardType {
    internal static let storyboardName = "Spend"

    internal static let offerDetailsNavigationController = SceneType<UIKit.UINavigationController>(storyboard: Spend.self, identifier: "OfferDetailsNavigationController")

    internal static let offerDetailsViewController = SceneType<KinWallet.OfferDetailsViewController>(storyboard: Spend.self, identifier: "OfferDetailsViewController")

    internal static let offerWallViewController = SceneType<KinWallet.OfferWallViewController>(storyboard: Spend.self, identifier: "OfferWallViewController")

    internal static let standardOfferActionViewController = SceneType<KinWallet.StandardOfferActionViewController>(storyboard: Spend.self, identifier: "StandardOfferActionViewController")
  }
}
// swiftlint:enable explicit_type_interface identifier_name line_length type_body_length type_name

// MARK: - Implementation Details

internal protocol StoryboardType {
  static var storyboardName: String { get }
}

internal extension StoryboardType {
  static var storyboard: UIStoryboard {
    let name = self.storyboardName
    return UIStoryboard(name: name, bundle: Bundle(for: BundleToken.self))
  }
}

internal struct SceneType<T: UIViewController> {
  internal let storyboard: StoryboardType.Type
  internal let identifier: String

  internal func instantiate() -> T {
    let identifier = self.identifier
    guard let controller = storyboard.storyboard.instantiateViewController(withIdentifier: identifier) as? T else {
      fatalError("ViewController '\(identifier)' is not of the expected class \(T.self).")
    }
    return controller
  }
}

internal struct InitialSceneType<T: UIViewController> {
  internal let storyboard: StoryboardType.Type

  internal func instantiate() -> T {
    guard let controller = storyboard.storyboard.instantiateInitialViewController() as? T else {
      fatalError("ViewController is not of the expected class \(T.self).")
    }
    return controller
  }
}

private final class BundleToken {}
