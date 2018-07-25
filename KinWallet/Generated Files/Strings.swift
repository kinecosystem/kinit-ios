// Generated using SwiftGen, by O.Halligon — https://github.com/SwiftGen/SwiftGen

import Foundation

// swiftlint:disable superfluous_disable_command
// swiftlint:disable file_length

// swiftlint:disable explicit_type_interface identifier_name line_length nesting type_body_length type_name
internal enum L10n {
  /// Your account is ready!
  internal static let accountReadyMessage = L10n.tr("Localizable", "AccountReadyMessage")
  /// Woohooooo
  internal static let accountReadyTitle = L10n.tr("Localizable", "AccountReadyTitle")
  /// Continue
  internal static let activityActionContinue = L10n.tr("Localizable", "ActivityActionContinue")
  /// Start Earning Kin
  internal static let activityActionStart = L10n.tr("Localizable", "ActivityActionStart")
  /// by %@
  internal static func activityAuthor(_ p1: String) -> String {
    return L10n.tr("Localizable", "ActivityAuthor", p1)
  }
  /// You have completed today's activity.
  internal static let activityDoneMessage = L10n.tr("Localizable", "ActivityDoneMessage")
  /// Awesome!
  internal static let activityDoneTitle = L10n.tr("Localizable", "ActivityDoneTitle")
  /// Back to Spend
  internal static let backToSpendAction = L10n.tr("Localizable", "BackToSpendAction")
  /// My Vouchers
  internal static let balanceMyVouchers = L10n.tr("Localizable", "BalanceMyVouchers")
  /// Recent Actions
  internal static let balanceRecentActions = L10n.tr("Localizable", "BalanceRecentActions")
  /// Buy
  internal static let buy = L10n.tr("Localizable", "Buy")
  /// Cancel
  internal static let cancel = L10n.tr("Localizable", "Cancel")
  /// Close
  internal static let closeAction = L10n.tr("Localizable", "CloseAction")
  /// Contact Support
  internal static let contactSupport = L10n.tr("Localizable", "ContactSupport")
  /// Code saved to My Vouchers
  internal static let couponCodeSaved = L10n.tr("Localizable", "CouponCodeSaved")
  /// Email us
  internal static let emailUs = L10n.tr("Localizable", "EmailUs")
  /// We are hand-picking the best for you!
  internal static let emptyOffersSubtitle = L10n.tr("Localizable", "EmptyOffersSubtitle")
  /// No offers at the moment
  internal static let emptyOffersTitle = L10n.tr("Localizable", "EmptyOffersTitle")
  /// Please check your internet connection and try again.
  internal static let internetErrorMessage = L10n.tr("Localizable", "InternetErrorMessage")
  /// Oh no! Your internet is MIA
  internal static let internetErrorTitle = L10n.tr("Localizable", "InternetErrorTitle")
  /// Kin delivered!
  internal static let kinDelivered = L10n.tr("Localizable", "KinDelivered")
  /// You’ve succesfully sent K %@.\nYou can see the details under Balance
  internal static func kinSentMessage(_ p1: String) -> String {
    return L10n.tr("Localizable", "KinSentMessage", p1)
  }
  /// Please check back later
  internal static let lastOfferGrabbedMessage = L10n.tr("Localizable", "LastOfferGrabbedMessage")
  /// Oops! Someone grabbed the last one... for now
  internal static let lastOfferGrabbedTitle = L10n.tr("Localizable", "LastOfferGrabbedTitle")
  /// Add an email account to your device in order to send email.
  internal static let mailNotConfiguredErrorMessage = L10n.tr("Localizable", "MailNotConfiguredErrorMessage")
  /// Mail Not Configured
  internal static let mailNotConfiguredErrorTitle = L10n.tr("Localizable", "MailNotConfiguredErrorTitle")
  /// Next
  internal static let nextAction = L10n.tr("Localizable", "NextAction")
  /// We have planted the seed and your next task is currently growing
  internal static let nextActivityOnSubtitle = L10n.tr("Localizable", "NextActivityOnSubtitle")
  /// Your next activity will be available %@
  internal static func nextActivityOnTitle(_ p1: String) -> String {
    return L10n.tr("Localizable", "NextActivityOnTitle", p1)
  }
  /// We are laying the groundwork for your next task.\nStay tuned :)
  internal static let noActivitiesMessage = L10n.tr("Localizable", "NoActivitiesMessage")
  /// No activities at the moment
  internal static let noActivitiesTitle = L10n.tr("Localizable", "NoActivitiesTitle")
  /// It seems that something is missing...\nPlease check your internet connection.
  internal static let noInternetErrorSubtitle = L10n.tr("Localizable", "NoInternetErrorSubtitle")
  /// Your internet is MIA
  internal static let noInternetErrorTitle = L10n.tr("Localizable", "NoInternetErrorTitle")
  /// Open Settings
  internal static let notificationsDeniedAction = L10n.tr("Localizable", "NotificationsDeniedAction")
  /// Push notification permissions were previously denied and are currently turned off.\nPlease go to settings to turn on notifications.
  internal static let notificationsDeniedMessage = L10n.tr("Localizable", "NotificationsDeniedMessage")
  /// Please Allow Notifications
  internal static let notificationsDeniedTitle = L10n.tr("Localizable", "NotificationsDeniedTitle")
  /// Notify Me
  internal static let notifyMe = L10n.tr("Localizable", "NotifyMe")
  /// OK
  internal static let ok = L10n.tr("Localizable", "OK")
  /// Or
  internal static let or = L10n.tr("Localizable", "Or")
  /// or contact support
  internal static let orContactSupport = L10n.tr("Localizable", "OrContactSupport")
  /// Send me a new code
  internal static let phoneConfirmationAskNewCode = L10n.tr("Localizable", "PhoneConfirmationAskNewCode")
  /// The code should arrive in %ds.
  internal static func phoneConfirmationCountdown(_ p1: Int) -> String {
    return L10n.tr("Localizable", "PhoneConfirmationCountdown", p1)
  }
  /// We have sent you a verification code to your phone. Please type it below:
  internal static let phoneConfirmationMessage = L10n.tr("Localizable", "PhoneConfirmationMessage")
  /// Verification SMS
  internal static let phoneConfirmationTitle = L10n.tr("Localizable", "PhoneConfirmationTitle")
  /// We have sent a verification code to %@. Please type it below:
  internal static func phoneVerificationCodeSent(_ p1: String) -> String {
    return L10n.tr("Localizable", "PhoneVerificationCodeSent", p1)
  }
  /// Something wrong happened. Please check your internet connection
  internal static let phoneVerificationRequestGeneralError = L10n.tr("Localizable", "PhoneVerificationRequestGeneralError")
  /// Invalid phone number
  internal static let phoneVerificationRequestInvalidNumber = L10n.tr("Localizable", "PhoneVerificationRequestInvalidNumber")
  /// Your phone number is used to identify your wallet.
  internal static let phoneVerificationRequestMessage = L10n.tr("Localizable", "PhoneVerificationRequestMessage")
  /// Phone Number
  internal static let phoneVerificationRequestTitle = L10n.tr("Localizable", "PhoneVerificationRequestTitle")
  /// Hi! 👋\nReady to earn some Kin?
  internal static let readyToEarnKinQuestion = L10n.tr("Localizable", "ReadyToEarnKinQuestion")
  /// Sending Kin
  internal static let sendingKin = L10n.tr("Localizable", "SendingKin")
  /// Send Kin
  internal static let sendKinAction = L10n.tr("Localizable", "SendKinAction")
  /// Maybe send your friends to the app store?
  internal static let sendKinContactNotFoundErrorMessage = L10n.tr("Localizable", "SendKinContactNotFoundErrorMessage")
  /// Sorry, you can only send Kin to Kinit users.
  internal static let sendKinContactNotFoundErrorTitle = L10n.tr("Localizable", "SendKinContactNotFoundErrorTitle")
  /// You can only send %u KIN at a time.
  internal static func sendKinHighAmountErrorMessage(_ p1: Int) -> String {
    return L10n.tr("Localizable", "SendKinHighAmountErrorMessage", p1)
  }
  /// That's Very Kind
  internal static let sendKinHighAmountErrorTitle = L10n.tr("Localizable", "SendKinHighAmountErrorTitle")
  /// Please send at least %u KIN.
  internal static func sendKinLowAmountErrorMessage(_ p1: Int) -> String {
    return L10n.tr("Localizable", "SendKinLowAmountErrorMessage", p1)
  }
  /// How About a Bit More Love?
  internal static let sendKinLowAmountErrorTitle = L10n.tr("Localizable", "SendKinLowAmountErrorTitle")
  /// Make sure you have at least %u KIN.
  internal static func sendKinLowBalanceErrorMessage(_ p1: Int) -> String {
    return L10n.tr("Localizable", "SendKinLowBalanceErrorMessage", p1)
  }
  /// Looks Like Your Balance Is a Bit Low
  internal static let sendKinLowBalanceErrorTitle = L10n.tr("Localizable", "SendKinLowBalanceErrorTitle")
  /// Please try again later. If you continue to see this message, please reach out to support.
  internal static let sendKinTransactionFailedErrorMessage = L10n.tr("Localizable", "SendKinTransactionFailedErrorMessage")
  /// Houston We Have a Server Problem
  internal static let sendKinTransactionFailedErrorTitle = L10n.tr("Localizable", "SendKinTransactionFailedErrorTitle")
  /// To
  internal static let sendTo = L10n.tr("Localizable", "SendTo")
  /// Spend your Kin
  internal static let spendYourKin = L10n.tr("Localizable", "SpendYourKin")
  /// Support
  internal static let support = L10n.tr("Localizable", "Support")
  /// Tap to continue
  internal static let tapToContinue = L10n.tr("Localizable", "TapToContinue")
  /// Tap to finish
  internal static let tapToFinish = L10n.tr("Localizable", "TapToFinish")
  /// To make sure you get your Kin, hit close below and continue on the next screen.
  internal static let taskSubmissionFailedErrorMessage = L10n.tr("Localizable", "TaskSubmissionFailedErrorMessage")
  /// There was a problem submitting your answers
  internal static let taskSubmissionFailedErrorTitle = L10n.tr("Localizable", "TaskSubmissionFailedErrorTitle")
  ///  Sorry! We were unable to retrieve your code.\nPlease contact support to resolve this issue.
  internal static let transactionIncompleteMessage = L10n.tr("Localizable", "TransactionIncompleteMessage")
  /// Oops! Transaction incomplete
  internal static let transactionIncompleteTitle = L10n.tr("Localizable", "TransactionIncompleteTitle")
  /// Your transactions will appear here!
  internal static let transactionsEmptyStateMessage = L10n.tr("Localizable", "TransactionsEmptyStateMessage")
  /// Your new balance
  internal static let transferringKinNewBalance = L10n.tr("Localizable", "TransferringKinNewBalance")
  /// Your Kin is on it's way
  internal static let transferringKinOnItsWay = L10n.tr("Localizable", "TransferringKinOnItsWay")
  /// Try Again
  internal static let tryAgain = L10n.tr("Localizable", "TryAgain")
  /// Your vouchers will be saved here!
  internal static let vouchersEmptyStateMessage = L10n.tr("Localizable", "VouchersEmptyStateMessage")
  /// Please check your internet connection & try again.
  internal static let walletCreationErrorSubtitle = L10n.tr("Localizable", "WalletCreationErrorSubtitle")
  /// We were unable to create a wallet for you
  internal static let walletCreationErrorTitle = L10n.tr("Localizable", "WalletCreationErrorTitle")
  /// Earn Kin by completing fun daily activities, and enjoy it toward brown paper packages tied up with string (aka travel, movies, music, and more).
  internal static let welcome1stScreenMessage = L10n.tr("Localizable", "Welcome1stScreenMessage")
  ///  Welcome to Kinit
  internal static let welcome1stScreenTitle = L10n.tr("Localizable", "Welcome1stScreenTitle")
  /// Earning Kin is just like playing a game, only better, because you get rewarded for your time.
  internal static let welcome2ndScreenMessage = L10n.tr("Localizable", "Welcome2ndScreenMessage")
  /// Earn Kin
  internal static let welcome2ndScreenTitle = L10n.tr("Localizable", "Welcome2ndScreenTitle")
  /// In no time, you’ll have enough Kin to use towards great experiences or to share with your friends.
  internal static let welcome3rdScreenMessage = L10n.tr("Localizable", "Welcome3rdScreenMessage")
  /// Enjoy
  internal static let welcome3rdScreenTitle = L10n.tr("Localizable", "Welcome3rdScreenTitle")
  /// By clicking "Start earning Kin" you are agreeing\nto our Terms of Service and Privacy Policy
  internal static let welcomeScreenDisclaimer = L10n.tr("Localizable", "WelcomeScreenDisclaimer")
  /// Your Kin Balance
  internal static let yourKinBalance = L10n.tr("Localizable", "YourKinBalance")
}
// swiftlint:enable explicit_type_interface identifier_name line_length nesting type_body_length type_name

extension L10n {
  private static func tr(_ table: String, _ key: String, _ args: CVarArg...) -> String {
    let format = NSLocalizedString(key, tableName: table, bundle: Bundle(for: BundleToken.self), comment: "")
    return String(format: format, locale: Locale.current, arguments: args)
  }
}

private final class BundleToken {}
