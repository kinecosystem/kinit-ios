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
  internal enum Earn: StoryboardType {
    internal static let storyboardName = "Earn"

    internal static let earnKinAnimationViewController = SceneType<EarnKinAnimationViewController>(storyboard: Earn.self, identifier: "EarnKinAnimationViewController")

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

    internal static let accountReadyViewController = SceneType<AccountReadyViewController>(storyboard: Main.self, identifier: "AccountReadyViewController")

    internal static let balancePagerTabViewController = SceneType<BalancePagerTabViewController>(storyboard: Main.self, identifier: "BalancePagerTabViewController")

    internal static let balanceViewController = SceneType<BalanceViewController>(storyboard: Main.self, identifier: "BalanceViewController")

    internal static let noticeViewController = SceneType<NoticeViewController>(storyboard: Main.self, identifier: "NoticeViewController")

    internal static let offerWallNavigationController = SceneType<KinNavigationController>(storyboard: Main.self, identifier: "OfferWallNavigationController")

    internal static let offerWallViewController = SceneType<OfferWallViewController>(storyboard: Main.self, identifier: "OfferWallViewController")

    internal static let phoneConfirmationViewController = SceneType<PhoneConfirmationViewController>(storyboard: Main.self, identifier: "PhoneConfirmationViewController")

    internal static let phoneVerificationRequestViewController = SceneType<PhoneVerificationRequestViewController>(storyboard: Main.self, identifier: "PhoneVerificationRequestViewController")

    internal static let rootTabBarController = SceneType<RootTabBarController>(storyboard: Main.self, identifier: "RootTabBarController")

    internal static let surveyHomeViewController = SceneType<SurveyHomeViewController>(storyboard: Main.self, identifier: "SurveyHomeViewController")

    internal static let surveyNavigationController = SceneType<KinNavigationController>(storyboard: Main.self, identifier: "SurveyNavigationController")

    internal static let welcomeViewController = SceneType<WelcomeViewController>(storyboard: Main.self, identifier: "WelcomeViewController")
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
