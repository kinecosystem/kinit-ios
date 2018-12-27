// swiftlint:disable all
// Generated using SwiftGen, by O.Halligon — https://github.com/SwiftGen/SwiftGen

import Foundation

// swiftlint:disable superfluous_disable_command
// swiftlint:disable file_length

// MARK: - Strings

// swiftlint:disable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:disable nesting type_body_length type_name
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
  /// %d activities
  internal static func availableActivitesCount(_ p1: Int) -> String {
    return L10n.tr("Localizable", "AvailableActivitesCount", p1)
  }
  /// Back
  internal static let backAction = L10n.tr("Localizable", "BackAction")
  /// Open Settings
  internal static let backgroundAppRefreshRequiredAction = L10n.tr("Localizable", "BackgroundAppRefreshRequiredAction")
  /// In order to reward you with Kin for completing activities, we require you to turn on the "Background App Refresh" setting. Please go to "Settings -> General -> Background App Refresh" and make sure that it is turned on for Kinit.
  internal static let backgroundAppRefreshRequiredMessage = L10n.tr("Localizable", "BackgroundAppRefreshRequiredMessage")
  /// Please Enable Background App Refresh for Kinit
  internal static let backgroundAppRefreshRequiredTitle = L10n.tr("Localizable", "BackgroundAppRefreshRequiredTitle")
  /// Back to Spend
  internal static let backToSpendAction = L10n.tr("Localizable", "BackToSpendAction")
  /// Back Up
  internal static let backUpAction = L10n.tr("Localizable", "BackUpAction")
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
  /// I understand, continue
  internal static let backupExactAnswerContinueAction = L10n.tr("Localizable", "BackupExactAnswerContinueAction")
  /// It is important to remember your answers. You will be required to provide exactly the same answers when restoring your account and will not be able to restore your account without them. The only way to reset your answers is by creating a new backup.
  internal static let backupExactAnswersAlertMessage = L10n.tr("Localizable", "BackupExactAnswersAlertMessage")
  /// Notice!
  internal static let backupExactAnswersAlertTitle = L10n.tr("Localizable", "BackupExactAnswersAlertTitle")
  /// Creating a new wallet will erase your balance, are you sure you don’t want to restore?
  internal static let backupIgnoreAndCreateNewWalletMessage = L10n.tr("Localizable", "BackupIgnoreAndCreateNewWalletMessage")
  /// We already know each other!
  internal static let backupIgnoreAndCreateNewWalletTitle = L10n.tr("Localizable", "BackupIgnoreAndCreateNewWalletTitle")
  /// Backing up your wallet will allow you to recover your Kin if you get locked out of the app or if your phone is ever lost or stolen.
  internal static let backupIntroExplanation = L10n.tr("Localizable", "BackupIntroExplanation")
  /// * minimum 4 characters
  internal static let backupMinimum4Characters = L10n.tr("Localizable", "BackupMinimum4Characters")
  /// That’s why it’s easy to backup your wallet. Back it up today
  internal static let backupNagFourteenMessage = L10n.tr("Localizable", "BackupNagFourteenMessage")
  /// We care about your Kin
  internal static let backupNagFourteenTitle = L10n.tr("Localizable", "BackupNagFourteenTitle")
  /// Back it up today to make sure it’s always safe
  internal static let backupNagSevenMessage = L10n.tr("Localizable", "BackupNagSevenMessage")
  /// Your Kin is really rolling in
  internal static let backupNagSevenTitle = L10n.tr("Localizable", "BackupNagSevenTitle")
  /// It’s your Kin. It wants to be kept safe. Back it up today.
  internal static let backupNagThirtyMessage = L10n.tr("Localizable", "BackupNagThirtyMessage")
  /// Knock knock
  internal static let backupNagThirtyTitle = L10n.tr("Localizable", "BackupNagThirtyTitle")
  /// Now it’s possible to backup your Kin in case your phone is lost
  internal static let backupNagZeroMessage = L10n.tr("Localizable", "BackupNagZeroMessage")
  /// Back up your Kin
  internal static let backupNagZeroTitle = L10n.tr("Localizable", "BackupNagZeroTitle")
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
  /// It looks like your answers don’t match. Please contact support for assistance.
  internal static let backupWrongAnswersMessage = L10n.tr("Localizable", "BackupWrongAnswersMessage")
  /// Feeling forgetful?
  internal static let backupWrongAnswersTitle = L10n.tr("Localizable", "BackupWrongAnswersTitle")
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
  /// Open Settings
  internal static let cameraDeniedAction = L10n.tr("Localizable", "CameraDeniedAction")
  /// Please Allow Camera Access
  internal static let cameraDeniedTitle = L10n.tr("Localizable", "CameraDeniedTitle")
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
  /// Continue
  internal static let continueAction = L10n.tr("Localizable", "ContinueAction")
  /// Code saved to My Vouchers
  internal static let couponCodeSaved = L10n.tr("Localizable", "CouponCodeSaved")
  /// Create New Wallet
  internal static let createNewWallet = L10n.tr("Localizable", "CreateNewWallet")
  /// Creating your wallet
  internal static let creatingYourWallet = L10n.tr("Localizable", "CreatingYourWallet")
  /// It might take up to 20 sec.
  internal static let creatingYourWalletBePatient = L10n.tr("Localizable", "CreatingYourWalletBePatient")
  /// Ecosystem Apps
  internal static let ecosystemApps = L10n.tr("Localizable", "EcosystemApps")
  /// We are hand-picking the best for you!
  internal static let emptyOffersSubtitle = L10n.tr("Localizable", "EmptyOffersSubtitle")
  /// No offers at the moment
  internal static let emptyOffersTitle = L10n.tr("Localizable", "EmptyOffersTitle")
  /// Keep in mind that by creating a new backup, the old one will be deleted.
  internal static let existingBackupOverwriteMessage = L10n.tr("Localizable", "ExistingBackupOverwriteMessage")
  /// Are you sure you want to create a new backup?
  internal static let existingBackupOverwriteTitle = L10n.tr("Localizable", "ExistingBackupOverwriteTitle")
  /// We really appreciate your input. Please enter your feedback for Kinit %@ here:
  internal static func feedbackEmailBody(_ p1: String) -> String {
    return L10n.tr("Localizable", "FeedbackEmailBody", p1)
  }
  /// Kinit Feedback
  internal static let feedbackEmailSubject = L10n.tr("Localizable", "FeedbackEmailSubject")
  /// We can’t respond to feedbacks individually. If you have a question or need help resolving a problem, you’ll find answers in our help center.
  internal static let feedbackNotSupportAlertMessage = L10n.tr("Localizable", "FeedbackNotSupportAlertMessage")
  /// 
  internal static let feedbackNotSupportAlertTitle = L10n.tr("Localizable", "FeedbackNotSupportAlertTitle")
  /// First Question
  internal static let firstSecurityQuestion = L10n.tr("Localizable", "FirstSecurityQuestion")
  /// We are having technical issues. Please try again or contact support.
  internal static let generalErrorMessage = L10n.tr("Localizable", "GeneralErrorMessage")
  /// Something went wrong
  internal static let generalErrorTitle = L10n.tr("Localizable", "GeneralErrorTitle")
  /// Please try again later. If you continue to see this message, please reach out to support.
  internal static let generalServerErrorMessage = L10n.tr("Localizable", "GeneralServerErrorMessage")
  /// Houston We Have a Server Problem
  internal static let generalServerErrorTitle = L10n.tr("Localizable", "GeneralServerErrorTitle")
  /// Get App
  internal static let getApp = L10n.tr("Localizable", "GetApp")
  /// GET
  internal static let getAppShort = L10n.tr("Localizable", "GetAppShort")
  /// Gift Cards
  internal static let giftCards = L10n.tr("Localizable", "GiftCards")
  /// Give Us Feedback
  internal static let giveUsFeedback = L10n.tr("Localizable", "GiveUsFeedback")
  /// Help Center
  internal static let helpCenter = L10n.tr("Localizable", "HelpCenter")
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
  /// Later
  internal static let later = L10n.tr("Localizable", "Later")
  /// Copy Message
  internal static let mailNotConfiguredCopyInformation = L10n.tr("Localizable", "MailNotConfiguredCopyInformation")
  /// The Mail app is not configured with an email account, and we could not find a popular email app installed.\nPlease copy the message and paste it in an email to %@
  internal static func mailNotConfiguredMessage(_ p1: String) -> String {
    return L10n.tr("Localizable", "MailNotConfiguredMessage", p1)
  }
  /// Mail Not Configured
  internal static let mailNotConfiguredTitle = L10n.tr("Localizable", "MailNotConfiguredTitle")
  /// Next
  internal static let nextAction = L10n.tr("Localizable", "NextAction")
  /// We are laying the groundwork for your next activity.\nStay tuned :)
  internal static let noActivitiesMessage = L10n.tr("Localizable", "NoActivitiesMessage")
  /// No activities at the moment
  internal static let noActivitiesTitle = L10n.tr("Localizable", "NoActivitiesTitle")
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
  /// Cancel Backup
  internal static let performBackupMissingConfirmationCancelBackup = L10n.tr("Localizable", "PerformBackupMissingConfirmationCancelBackup")
  /// Continue Backup
  internal static let performBackupMissingConfirmationContinueBackup = L10n.tr("Localizable", "PerformBackupMissingConfirmationContinueBackup")
  /// Skipping this process will result in your kin not being backed up.
  internal static let performBackupMissingConfirmationMessage = L10n.tr("Localizable", "PerformBackupMissingConfirmationMessage")
  /// Hang On, You're Almost There 🙂
  internal static let performBackupMissingConfirmationTitle = L10n.tr("Localizable", "PerformBackupMissingConfirmationTitle")
  /// Sorry, it looks like there’s a problem with the email confirmation. Please try starting the backup process again in a little while. 
  internal static let performBackupTooManyEmailAttemptsMessage = L10n.tr("Localizable", "PerformBackupTooManyEmailAttemptsMessage")
  /// Huh, that doesn’t seem right
  internal static let performBackupTooManyEmailAttemptsTitle = L10n.tr("Localizable", "PerformBackupTooManyEmailAttemptsTitle")
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
  /// In order to scan the QR code, Kinit needs camera access on this device.
  internal static let qrScannerCameraDeniedMessage = L10n.tr("Localizable", "QRScannerCameraDeniedMessage")
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
  /// We are having technical issues. Please try again or contact support.
  internal static let restoreBackupUserMatchFailedMessage = L10n.tr("Localizable", "RestoreBackupUserMatchFailedMessage")
  /// Something went wrong
  internal static let restoreBackupUserMatchFailedTitle = L10n.tr("Localizable", "RestoreBackupUserMatchFailedTitle")
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
  /// Send Feedback
  internal static let sendFeedback = L10n.tr("Localizable", "SendFeedback")
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
  /// To
  internal static let sendTo = L10n.tr("Localizable", "SendTo")
  /// Spend your Kin
  internal static let spendYourKin = L10n.tr("Localizable", "SpendYourKin")
  /// Start
  internal static let startAction = L10n.tr("Localizable", "StartAction")
  /// Support
  internal static let support = L10n.tr("Localizable", "Support")
  /// Kinit Support Request
  internal static let supportEmailSubject = L10n.tr("Localizable", "SupportEmailSubject")
  /// Tap to continue
  internal static let tapToContinue = L10n.tr("Localizable", "TapToContinue")
  /// Tap to finish
  internal static let tapToFinish = L10n.tr("Localizable", "TapToFinish")
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
  /// Version
  internal static let version = L10n.tr("Localizable", "Version")
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

  internal enum ActivityDone {
    /// You have completed today's activity.
    internal static let message = L10n.tr("Localizable", "ActivityDone.Message")
    /// Awesome!
    internal static let title = L10n.tr("Localizable", "ActivityDone.Title")
  }

  internal enum AppDiscovery {
    internal enum Footer {
      /// More apps are coming soon
      internal static let subtitle = L10n.tr("Localizable", "AppDiscovery.Footer.Subtitle")
      /// Coming soon: a new way to use Kin across the ecosystem
      internal static let title = L10n.tr("Localizable", "AppDiscovery.Footer.Title")
    }
    internal enum Header {
      /// Discover all the amazing apps where you can use Kin.
      internal static let subtitle = L10n.tr("Localizable", "AppDiscovery.Header.Subtitle")
      /// Introducing Kin Ecosystem apps
      internal static let title = L10n.tr("Localizable", "AppDiscovery.Header.Title")
    }
  }

  internal enum AppPage {
    /// About %@
    internal static func aboutApp(_ p1: String) -> String {
      return L10n.tr("Localizable", "AppPage.AboutApp", p1)
    }
    /// Kin Usage
    internal static let kinUsage = L10n.tr("Localizable", "AppPage.KinUsage")
    /// Soon you’ll be able to send Kin to this account
    internal static let sendComingSoon = L10n.tr("Localizable", "AppPage.SendComingSoon")
  }

  internal enum MoreUpdate {
    /// Update now
    internal static let updateNow = L10n.tr("Localizable", "MoreUpdate.UpdateNow")
    /// Up to date
    internal static let upToDate = L10n.tr("Localizable", "MoreUpdate.UpToDate")
  }

  internal enum NewOffersPolicy {
    /// I Understand
    internal static let action = L10n.tr("Localizable", "NewOffersPolicy.Action")
    /// In order to always bring you the best new offers, you will be able to buy a maximum of 1 gift card from every company each month
    internal static let message = L10n.tr("Localizable", "NewOffersPolicy.Message")
  }

  internal enum NextActivityOn {
    /// We have planted the seed and your next activity is currently growing
    internal static let message = L10n.tr("Localizable", "NextActivityOn.Message")
    /// Your next activity will be available %@
    internal static func title(_ p1: String) -> String {
      return L10n.tr("Localizable", "NextActivityOn.Title", p1)
    }
  }

  internal enum NoInternetError {
    /// It seems that something is missing...\nPlease check your internet connection.
    internal static let message = L10n.tr("Localizable", "NoInternetError.Message")
    /// Your internet is MIA
    internal static let title = L10n.tr("Localizable", "NoInternetError.Title")
  }

  internal enum ServerError {
    /// An unkown error occured. Please close the app and try again later.
    internal static let message = L10n.tr("Localizable", "ServerError.Message")
    /// Oh… Something isn’t working
    internal static let title = L10n.tr("Localizable", "ServerError.Title")
  }

  internal enum TaskSubmissionFailedError {
    /// To make sure you get your Kin, hit close below and continue on the next screen.
    internal static let message = L10n.tr("Localizable", "TaskSubmissionFailedError.Message")
    /// There was a problem submitting your answers
    internal static let title = L10n.tr("Localizable", "TaskSubmissionFailedError.Title")
  }

  internal enum TaskSubmissionPaymentTimeout {
    /// We have received your results but something got stuck along the way.\n\nPlease tap close and check your balance in a few hours. If no change has ocurred, contact support.
    internal static let message = L10n.tr("Localizable", "TaskSubmissionPaymentTimeout.Message")
    /// Your Kin is on its way with a brief delay
    internal static let title = L10n.tr("Localizable", "TaskSubmissionPaymentTimeout.Title")
  }

  internal enum UpdateAlert {
    /// Update Now
    internal static let action = L10n.tr("Localizable", "UpdateAlert.Action")
    /// Update to the newest version to keep the kin rolling in
    internal static let message = L10n.tr("Localizable", "UpdateAlert.Message")
    /// New version available
    internal static let title = L10n.tr("Localizable", "UpdateAlert.Title")
  }
}
// swiftlint:enable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:enable nesting type_body_length type_name

// MARK: - Implementation Details

extension L10n {
  private static func tr(_ table: String, _ key: String, _ args: CVarArg...) -> String {
    let format = NSLocalizedString(key, tableName: table, bundle: Bundle(for: BundleToken.self), comment: "")
    return String(format: format, locale: Locale.current, arguments: args)
  }
}

private final class BundleToken {}
