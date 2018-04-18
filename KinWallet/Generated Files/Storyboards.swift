// Generated using SwiftGen, by O.Halligon — https://github.com/SwiftGen/SwiftGen

// swiftlint:disable sorted_imports
import Foundation
import UIKit

// swiftlint:disable superfluous_disable_command
// swiftlint:disable file_length

protocol StoryboardType {
  static var storyboardName: String { get }
}

extension StoryboardType {
  static var storyboard: UIStoryboard {
    let name = self.storyboardName
    return UIStoryboard(name: name, bundle: Bundle(for: BundleToken.self))
  }
}

struct SceneType<T: Any> {
  let storyboard: StoryboardType.Type
  let identifier: String

  func instantiate() -> T {
    let identifier = self.identifier
    guard let controller = storyboard.storyboard.instantiateViewController(withIdentifier: identifier) as? T else {
      fatalError("ViewController '\(identifier)' is not of the expected class \(T.self).")
    }
    return controller
  }
}

struct InitialSceneType<T: Any> {
  let storyboard: StoryboardType.Type

  func instantiate() -> T {
    guard let controller = storyboard.storyboard.instantiateInitialViewController() as? T else {
      fatalError("ViewController is not of the expected class \(T.self).")
    }
    return controller
  }
}

protocol SegueType: RawRepresentable { }

extension UIViewController {
  func perform<S: SegueType>(segue: S, sender: Any? = nil) where S.RawValue == String {
    let identifier = segue.rawValue
    performSegue(withIdentifier: identifier, sender: sender)
  }
}

// swiftlint:disable explicit_type_interface identifier_name line_length type_body_length type_name
enum StoryboardScene {
  enum Earn: StoryboardType {
    static let storyboardName = "Earn"

    static let earnKinAnimationViewController = SceneType<EarnKinAnimationViewController>(storyboard: Earn.self, identifier: "EarnKinAnimationViewController")

    static let surveyCompletedViewController = SceneType<SurveyCompletedViewController>(storyboard: Earn.self, identifier: "SurveyCompletedViewController")

    static let surveyDoneViewController = SceneType<SurveyDoneViewController>(storyboard: Earn.self, identifier: "SurveyDoneViewController")

    static let surveyInfoViewController = SceneType<SurveyInfoViewController>(storyboard: Earn.self, identifier: "SurveyInfoViewController")

    static let transferringKinViewController = SceneType<TransferringKinViewController>(storyboard: Earn.self, identifier: "TransferringKinViewController")
  }
  enum LaunchScreen: StoryboardType {
    static let storyboardName = "LaunchScreen"

    static let initialScene = InitialSceneType<UIViewController>(storyboard: LaunchScreen.self)

    static let splashScreenViewController = SceneType<UIViewController>(storyboard: LaunchScreen.self, identifier: "SplashScreenViewController")
  }
  enum Main: StoryboardType {
    static let storyboardName = "Main"

    static let balancePagerTabViewController = SceneType<BalancePagerTabViewController>(storyboard: Main.self, identifier: "BalancePagerTabViewController")

    static let balanceViewController = SceneType<BalanceViewController>(storyboard: Main.self, identifier: "BalanceViewController")

    static let noticeViewController = SceneType<NoticeViewController>(storyboard: Main.self, identifier: "NoticeViewController")

    static let offerWallNavigationController = SceneType<KinNavigationController>(storyboard: Main.self, identifier: "OfferWallNavigationController")

    static let offerWallViewController = SceneType<OfferWallViewController>(storyboard: Main.self, identifier: "OfferWallViewController")

    static let rootTabBarController = SceneType<RootTabBarController>(storyboard: Main.self, identifier: "RootTabBarController")

    static let surveyHomeViewController = SceneType<SurveyHomeViewController>(storyboard: Main.self, identifier: "SurveyHomeViewController")

    static let surveyNavigationController = SceneType<KinNavigationController>(storyboard: Main.self, identifier: "SurveyNavigationController")
  }
  enum Spend: StoryboardType {
    static let storyboardName = "Spend"

    static let offerDetailsNavigationController = SceneType<UINavigationController>(storyboard: Spend.self, identifier: "OfferDetailsNavigationController")

    static let offerDetailsViewController = SceneType<OfferDetailsViewController>(storyboard: Spend.self, identifier: "OfferDetailsViewController")
  }
}

enum StoryboardSegue {
}
// swiftlint:enable explicit_type_interface identifier_name line_length type_body_length type_name

private final class BundleToken {}
