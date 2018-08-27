// Generated using SwiftGen, by O.Halligon — https://github.com/SwiftGen/SwiftGen

// swiftlint:disable sorted_imports
import Foundation
import UIKit

// swiftlint:disable superfluous_disable_command
// swiftlint:disable file_length

internal protocol StoryboardType {
  static var storyboardName: String { get }
}

internal extension StoryboardType {
  static var storyboard: UIStoryboard {
    let name = self.storyboardName
    return UIStoryboard(name: name, bundle: Bundle(for: BundleToken.self))
  }
}

internal struct SceneType<T: Any> {
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

internal struct InitialSceneType<T: Any> {
  internal let storyboard: StoryboardType.Type

  internal func instantiate() -> T {
    guard let controller = storyboard.storyboard.instantiateInitialViewController() as? T else {
      fatalError("ViewController is not of the expected class \(T.self).")
    }
    return controller
  }
}

internal protocol SegueType: RawRepresentable { }

internal extension UIViewController {
  func perform<S: SegueType>(segue: S, sender: Any? = nil) where S.RawValue == String {
    let identifier = segue.rawValue
    performSegue(withIdentifier: identifier, sender: sender)
  }
}

// swiftlint:disable explicit_type_interface identifier_name line_length type_body_length type_name
internal enum StoryboardScene {
  internal enum Backup: StoryboardType {
    internal static let storyboardName = "Backup"

    internal static let backupConfirmEmailViewController = SceneType<BackupConfirmEmailViewController>(storyboard: Backup.self, identifier: "BackupConfirmEmailViewController")

    internal static let backupDoneViewController = SceneType<BackupDoneViewController>(storyboard: Backup.self, identifier: "BackupDoneViewController")

    internal static let backupIntroViewController = SceneType<BackupIntroViewController>(storyboard: Backup.self, identifier: "BackupIntroViewController")

    internal static let backupNagViewController = SceneType<BackupNagViewController>(storyboard: Backup.self, identifier: "BackupNagViewController")

    internal static let backupQuestionViewController = SceneType<BackupQuestionViewController>(storyboard: Backup.self, identifier: "BackupQuestionViewController")

    internal static let backupSendEmailViewController = SceneType<BackupSendEmailViewController>(storyboard: Backup.self, identifier: "BackupSendEmailViewController")
  }
  internal enum Earn: StoryboardType {
    internal static let storyboardName = "Earn"

    internal static let earnKinAnimationViewController = SceneType<EarnKinAnimationViewController>(storyboard: Earn.self, identifier: "EarnKinAnimationViewController")

    internal static let quizQuestionExplanationViewController = SceneType<QuizQuestionExplanationViewController>(storyboard: Earn.self, identifier: "QuizQuestionExplanationViewController")

    internal static let surveyDoneViewController = SceneType<SurveyDoneViewController>(storyboard: Earn.self, identifier: "SurveyDoneViewController")

    internal static let surveyInfoViewController = SceneType<SurveyInfoViewController>(storyboard: Earn.self, identifier: "SurveyInfoViewController")

    internal static let taskCompletedViewController = SceneType<TaskCompletedViewController>(storyboard: Earn.self, identifier: "TaskCompletedViewController")

    internal static let transferringKinViewController = SceneType<TransferringKinViewController>(storyboard: Earn.self, identifier: "TransferringKinViewController")
  }
  internal enum LaunchScreen: StoryboardType {
    internal static let storyboardName = "LaunchScreen"

    internal static let initialScene = InitialSceneType<UIViewController>(storyboard: LaunchScreen.self)

    internal static let splashScreenViewController = SceneType<UIViewController>(storyboard: LaunchScreen.self, identifier: "SplashScreenViewController")
  }
  internal enum Main: StoryboardType {
    internal static let storyboardName = "Main"

    internal static let balancePagerTabViewController = SceneType<BalancePagerTabViewController>(storyboard: Main.self, identifier: "BalancePagerTabViewController")

    internal static let balanceViewController = SceneType<BalanceViewController>(storyboard: Main.self, identifier: "BalanceViewController")

    internal static let moreViewController = SceneType<MoreViewController>(storyboard: Main.self, identifier: "MoreViewController")

    internal static let noticeViewController = SceneType<NoticeViewController>(storyboard: Main.self, identifier: "NoticeViewController")

    internal static let offerWallNavigationController = SceneType<KinNavigationController>(storyboard: Main.self, identifier: "OfferWallNavigationController")

    internal static let offerWallViewController = SceneType<OfferWallViewController>(storyboard: Main.self, identifier: "OfferWallViewController")

    internal static let rootTabBarController = SceneType<RootTabBarController>(storyboard: Main.self, identifier: "RootTabBarController")

    internal static let surveyHomeViewController = SceneType<SurveyHomeViewController>(storyboard: Main.self, identifier: "SurveyHomeViewController")

    internal static let surveyNavigationController = SceneType<KinNavigationController>(storyboard: Main.self, identifier: "SurveyNavigationController")
  }
  internal enum Onboard: StoryboardType {
    internal static let storyboardName = "Onboard"

    internal static let accountReadyViewController = SceneType<AccountReadyViewController>(storyboard: Onboard.self, identifier: "AccountReadyViewController")

    internal static let accountSourceViewController = SceneType<AccountSourceViewController>(storyboard: Onboard.self, identifier: "AccountSourceViewController")

    internal static let creatingWalletViewController = SceneType<CreatingWalletViewController>(storyboard: Onboard.self, identifier: "CreatingWalletViewController")

    internal static let phoneConfirmationViewController = SceneType<PhoneConfirmationViewController>(storyboard: Onboard.self, identifier: "PhoneConfirmationViewController")

    internal static let phoneVerificationRequestViewController = SceneType<PhoneVerificationRequestViewController>(storyboard: Onboard.self, identifier: "PhoneVerificationRequestViewController")

    internal static let restoreBackupQRScannerViewController = SceneType<RestoreBackupQRScannerViewController>(storyboard: Onboard.self, identifier: "RestoreBackupQRScannerViewController")

    internal static let restoreBackupQuestionsViewController = SceneType<RestoreBackupQuestionsViewController>(storyboard: Onboard.self, identifier: "RestoreBackupQuestionsViewController")

    internal static let welcomeViewController = SceneType<WelcomeViewController>(storyboard: Onboard.self, identifier: "WelcomeViewController")
  }
  internal enum Spend: StoryboardType {
    internal static let storyboardName = "Spend"

    internal static let kinSentViewController = SceneType<KinSentViewController>(storyboard: Spend.self, identifier: "KinSentViewController")

    internal static let offerDetailsNavigationController = SceneType<UINavigationController>(storyboard: Spend.self, identifier: "OfferDetailsNavigationController")

    internal static let offerDetailsViewController = SceneType<OfferDetailsViewController>(storyboard: Spend.self, identifier: "OfferDetailsViewController")

    internal static let sendKinOfferActionViewController = SceneType<SendKinOfferActionViewController>(storyboard: Spend.self, identifier: "SendKinOfferActionViewController")

    internal static let sendKinViewController = SceneType<SendKinViewController>(storyboard: Spend.self, identifier: "SendKinViewController")

    internal static let standardOfferActionViewController = SceneType<StandardOfferActionViewController>(storyboard: Spend.self, identifier: "StandardOfferActionViewController")
  }
}

internal enum StoryboardSegue {
}
// swiftlint:enable explicit_type_interface identifier_name line_length type_body_length type_name

private final class BundleToken {}
