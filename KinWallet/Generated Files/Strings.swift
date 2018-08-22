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
  /// Looks like you’ve been here before. What would you like to do?
  internal static let backupAvailableTitle = L10n.tr("Localizable", "BackupAvailableTitle")
  /// Your wallet is backed up!
  internal static let backupCompleteMessage = L10n.tr("Localizable", "BackupCompleteMessage")
  /// Make sure to keep the code someplace safe because you’ll need it if you need to recover your account.
  internal static let backupConfirmMessage = L10n.tr("Localizable", "BackupConfirmMessage")
  /// resend
  internal static let backupConfirmResend = L10n.tr("Localizable", "BackupConfirmResend")
  /// If not, %@ or check your spam folder
  internal static func backupConfirmResendMessage(_ p1: String) -> String {
    return L10n.tr("Localizable", "BackupConfirmResendMessage", p1)
  }
  /// Please check your email to make sure you received your QR code.\nIf you did, click confirm below.
  internal static let backupConfirmSubtitle = L10n.tr("Localizable", "BackupConfirmSubtitle")
  /// Confirm Email
  internal static let backupConfirmTitle = L10n.tr("Localizable", "BackupConfirmTitle")
  /// Backing up your wallet will allow you to recover your Kin if you get locked out of the app or if your phone is ever lost or stolen.
  internal static let backupIntroExplanation = L10n.tr("Localizable", "BackupIntroExplanation")
  /// * minimum 4 characters
  internal static let backupMinimum4Characters = L10n.tr("Localizable", "BackupMinimum4Characters")
  /// Your Email Address
  internal static let backupQRCodeEmailAddress = L10n.tr("Localizable", "BackupQRCodeEmailAddress")
  /// * Make sure your email is written correctly.\nYou don’t want your wallet QR code to get to the hands of someone else.
  internal static let backupQRCodeEmailObservation = L10n.tr("Localizable", "BackupQRCodeEmailObservation")
  /// Type your email here
  internal static let backupQRCodeEmailPlaceholder = L10n.tr("Localizable", "BackupQRCodeEmailPlaceholder")
  /// To keep your account secure, we’ll generate a unique QR code and send it to you by email.
  internal static let backupQRCodeSubtitle = L10n.tr("Localizable", "BackupQRCodeSubtitle")
  /// Your wallet was restored!
  internal static let backupRestoredMessage = L10n.tr("Localizable", "BackupRestoredMessage")
  /// Type your answer here
  internal static let backupYourAnswerPlaceholder = L10n.tr("Localizable", "BackupYourAnswerPlaceholder")
  /// Your Answer
  internal static let backupYourAnswerTitle = L10n.tr("Localizable", "BackupYourAnswerTitle")
  /// My Vouchers
  internal static let balanceMyVouchers = L10n.tr("Localizable", "BalanceMyVouchers")
  /// Recent Actions
  internal static let balanceRecentActions = L10n.tr("Localizable", "BalanceRecentActions")
  /// Buy
  internal static let buy = L10n.tr("Localizable", "Buy")
  /// Cancel
  internal static let cancel = L10n.tr("Localizable", "Cancel")
  /// Choose one...
  internal static let chooseSecurityQuestion = L10n.tr("Localizable", "ChooseSecurityQuestion")
  /// Close
  internal static let closeAction = L10n.tr("Localizable", "CloseAction")
  /// Confirm
  internal static let confirm = L10n.tr("Localizable", "Confirm")
  /// Contact Support
  internal static let contactSupport = L10n.tr("Localizable", "ContactSupport")
  /// Code saved to My Vouchers
  internal static let couponCodeSaved = L10n.tr("Localizable", "CouponCodeSaved")
  /// Create New Wallet
  internal static let createNewWallet = L10n.tr("Localizable", "CreateNewWallet")
  /// Creating your wallet
  internal static let creatingYourWallet = L10n.tr("Localizable", "CreatingYourWallet")
  /// It might take up to 20 sec.
  internal static let creatingYourWalletBePatient = L10n.tr("Localizable", "CreatingYourWalletBePatient")
  /// Email us
  internal static let emailUs = L10n.tr("Localizable", "EmailUs")
  /// We are hand-picking the best for you!
  internal static let emptyOffersSubtitle = L10n.tr("Localizable", "EmptyOffersSubtitle")
  /// No offers at the moment
  internal static let emptyOffersTitle = L10n.tr("Localizable", "EmptyOffersTitle")
  /// First Question
  internal static let firstSecurityQuestion = L10n.tr("Localizable", "FirstSecurityQuestion")
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
  /// Kinit is currently not available in your country. We are continuing to grow, so check back again soon.
  internal static let phoneVerificationUnsupportedCountryCodeMessage = L10n.tr("Localizable", "PhoneVerificationUnsupportedCountryCodeMessage")
  /// Oh no!
  internal static let phoneVerificationUnsupportedCountryCodeTitle = L10n.tr("Localizable", "PhoneVerificationUnsupportedCountryCodeTitle")
  /// QR Code
  internal static let qrCode = L10n.tr("Localizable", "QRCode")
  /// Hi! 👋\nReady to earn some Kin?
  internal static let readyToEarnKinQuestion = L10n.tr("Localizable", "ReadyToEarnKinQuestion")
  /// Answer your security questions to unlock your account
  internal static let restoreBackupQuestionsSubtitle = L10n.tr("Localizable", "RestoreBackupQuestionsSubtitle")
  /// Security Questions
  internal static let restoreBackupQuestionsTitle = L10n.tr("Localizable", "RestoreBackupQuestionsTitle")
  /// You just need to scan the QR code we sent to your email and answer your 2 security questions
  internal static let restoreBackupScanSubtitle = L10n.tr("Localizable", "RestoreBackupScanSubtitle")
  /// You're 2 steps away
  internal static let restoreBackupScanTitle = L10n.tr("Localizable", "RestoreBackupScanTitle")
  /// Type your answer here
  internal static let restoreBackupYourAnswerPlaceholder = L10n.tr("Localizable", "RestoreBackupYourAnswerPlaceholder")
  /// Your Answer
  internal static let restoreBackupYourAnswerTitle = L10n.tr("Localizable", "RestoreBackupYourAnswerTitle")
  /// Restore From Backup
  internal static let restoreFromBackup = L10n.tr("Localizable", "RestoreFromBackup")
  /// Second Question
  internal static let secondSecurityQuestion = L10n.tr("Localizable", "SecondSecurityQuestion")
  /// Security
  internal static let security = L10n.tr("Localizable", "Security")
  /// Choose 2 security questions.
  internal static let securityQuestionsSubtitle = L10n.tr("Localizable", "SecurityQuestionsSubtitle")
  /// Security Questions
  internal static let securityQuestionsTitle = L10n.tr("Localizable", "SecurityQuestionsTitle")
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
  /// You cannot send Kin to yourself, right? 😉
  internal static let sendKinToSelfErrorMessage = L10n.tr("Localizable", "SendKinToSelfErrorMessage")
  /// You chose yourself!
  internal static let sendKinToSelfErrorTitle = L10n.tr("Localizable", "SendKinToSelfErrorTitle")
  /// Please try again later. If you continue to see this message, please reach out to support.
  internal static let sendKinTransactionFailedErrorMessage = L10n.tr("Localizable", "SendKinTransactionFailedErrorMessage")
  /// Houston We Have a Server Problem
  internal static let sendKinTransactionFailedErrorTitle = L10n.tr("Localizable", "SendKinTransactionFailedErrorTitle")
  /// To
  internal static let sendTo = L10n.tr("Localizable", "SendTo")
  /// Spend your Kin
  internal static let spendYourKin = L10n.tr("Localizable", "SpendYourKin")
  /// Start
  internal static let startAction = L10n.tr("Localizable", "StartAction")
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
  /// Your Kin is on its way
  internal static let transferringKinOnItsWay = L10n.tr("Localizable", "TransferringKinOnItsWay")
  /// Try Again
  internal static let tryAgain = L10n.tr("Localizable", "TryAgain")
  /// We were unable to create a profile for you
  internal static let userRegistrationErrorTitle = L10n.tr("Localizable", "UserRegistrationErrorTitle")
  /// Your vouchers will be saved here!
  internal static let vouchersEmptyStateMessage = L10n.tr("Localizable", "VouchersEmptyStateMessage")
  /// Wallet Backup
  internal static let walletBackup = L10n.tr("Localizable", "WalletBackup")
  /// We were unable to create a wallet for you
  internal static let walletCreationErrorTitle = L10n.tr("Localizable", "WalletCreationErrorTitle")
  /// Please check your internet connection & try again.
  internal static let walletOrUserCreationErrorSubtitle = L10n.tr("Localizable", "WalletOrUserCreationErrorSubtitle")
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
