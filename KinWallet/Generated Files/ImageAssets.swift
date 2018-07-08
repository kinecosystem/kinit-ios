// Generated using SwiftGen, by O.Halligon — https://github.com/SwiftGen/SwiftGen

#if os(OSX)
  import AppKit.NSImage
  typealias AssetColorTypeAlias = NSColor
  typealias Image = NSImage
#elseif os(iOS) || os(tvOS) || os(watchOS)
  import UIKit.UIImage
  typealias AssetColorTypeAlias = UIColor
  typealias Image = UIImage
#endif

// swiftlint:disable superfluous_disable_command
// swiftlint:disable file_length

@available(*, deprecated, renamed: "ImageAsset")
typealias AssetType = ImageAsset

struct ImageAsset {
  fileprivate var name: String

  var image: Image {
    let bundle = Bundle(for: BundleToken.self)
    #if os(iOS) || os(tvOS)
    let image = Image(named: name, in: bundle, compatibleWith: nil)
    #elseif os(OSX)
    let image = bundle.image(forResource: NSImage.Name(name))
    #elseif os(watchOS)
    let image = Image(named: name)
    #endif
    guard let result = image else { fatalError("Unable to load image named \(name).") }
    return result
  }
}

struct ColorAsset {
  fileprivate var name: String

  @available(iOS 11.0, tvOS 11.0, watchOS 4.0, OSX 10.13, *)
  var color: AssetColorTypeAlias {
    return AssetColorTypeAlias(asset: self)
  }
}

// swiftlint:disable identifier_name line_length nesting type_body_length type_name
enum Asset {
  static let buttonStroke = ImageAsset(name: "ButtonStroke")
  static let closeXButton = ImageAsset(name: "CloseXButton")
  static let closeXButtonDarkGray = ImageAsset(name: "CloseXButtonDarkGray")
  static let confettiDiamond = ImageAsset(name: "ConfettiDiamond")
  static let confettiNormal = ImageAsset(name: "ConfettiNormal")
  static let confettiStar = ImageAsset(name: "ConfettiStar")
  static let confettiTriangle = ImageAsset(name: "ConfettiTriangle")
  static let doneFireworks = ImageAsset(name: "DoneFireworks")
  static let doneSign = ImageAsset(name: "DoneSign")
  static let dualImageSeparator = ImageAsset(name: "DualImageSeparator")
  static let emptyHistoryCoupon = ImageAsset(name: "EmptyHistoryCoupon")
  static let errorSign = ImageAsset(name: "ErrorSign")
  static let floorShadow = ImageAsset(name: "FloorShadow")
  static let historyCouponIcon = ImageAsset(name: "HistoryCouponIcon")
  static let historyCouponLine = ImageAsset(name: "HistoryCouponLine")
  static let historyKinIcon = ImageAsset(name: "HistoryKinIcon")
  static let historyShareButton = ImageAsset(name: "HistoryShareButton")
  static let imageAnswerBorder = ImageAsset(name: "ImageAnswerBorder")
  static let imageAnswerBorderSelected = ImageAsset(name: "ImageAnswerBorderSelected")
  static let kinCoin = ImageAsset(name: "KinCoin")
  static let kinLogoSplash = ImageAsset(name: "KinLogoSplash")
  static let kinReward = ImageAsset(name: "KinReward")
  static let kinTaskReward = ImageAsset(name: "KinTaskReward")
  static let kinTaskTime = ImageAsset(name: "KinTaskTime")
  static let kinTransactionCoins = ImageAsset(name: "KinTransactionCoins")
  static let moreTabIcon = ImageAsset(name: "MoreTabIcon")
  static let multipleAnswerBackground = ImageAsset(name: "MultipleAnswerBackground")
  static let multipleAnswerBackgroundSelected = ImageAsset(name: "MultipleAnswerBackgroundSelected")
  static let multipleAnswerCheckmark = ImageAsset(name: "MultipleAnswerCheckmark")
  static let multipleAnswerPlus = ImageAsset(name: "MultipleAnswerPlus")
  static let nextTask = ImageAsset(name: "NextTask")
  static let noInternetIllustration = ImageAsset(name: "NoInternetIllustration")
  static let noOffers = ImageAsset(name: "NoOffers")
  static let offerCardShadow = ImageAsset(name: "OfferCardShadow")
  static let offerCardTopLeftCorner = ImageAsset(name: "OfferCardTopLeftCorner")
  static let patternPlaceholder = ImageAsset(name: "PatternPlaceholder")
  static let paymentDelay = ImageAsset(name: "PaymentDelay")
  static let progressViewGradient = ImageAsset(name: "ProgressViewGradient")
  static let progressViewTrack = ImageAsset(name: "ProgressViewTrack")
  static let recordsLedger = ImageAsset(name: "RecordsLedger")
  static let redeemBubble = ImageAsset(name: "RedeemBubble")
  static let smallHeart = ImageAsset(name: "SmallHeart")
  static let sowingIllustration = ImageAsset(name: "SowingIllustration")
  static let splashScreenBackground = ImageAsset(name: "SplashScreenBackground")
  static let tabBarBalance = ImageAsset(name: "TabBarBalance")
  static let tabBarEarn = ImageAsset(name: "TabBarEarn")
  static let tabBarMore = ImageAsset(name: "TabBarMore")
  static let tabBarSpend = ImageAsset(name: "TabBarSpend")
  static let textAnswerShape = ImageAsset(name: "TextAnswerShape")
  static let textAnswerShapeSelected = ImageAsset(name: "TextAnswerShapeSelected")
  static let timer = ImageAsset(name: "Timer")
  static let transferFireworks = ImageAsset(name: "TransferFireworks")
  static let walletCreationFailed = ImageAsset(name: "WalletCreationFailed")
  static let welcomeTutorial1 = ImageAsset(name: "WelcomeTutorial1")
  static let welcomeTutorial2 = ImageAsset(name: "WelcomeTutorial2")
  static let welcomeTutorial3 = ImageAsset(name: "WelcomeTutorial3")
  static let whiteCheckmark = ImageAsset(name: "WhiteCheckmark")

  // swiftlint:disable trailing_comma
  static let allColors: [ColorAsset] = [
  ]
  static let allImages: [ImageAsset] = [
    buttonStroke,
    closeXButton,
    closeXButtonDarkGray,
    confettiDiamond,
    confettiNormal,
    confettiStar,
    confettiTriangle,
    doneFireworks,
    doneSign,
    dualImageSeparator,
    emptyHistoryCoupon,
    errorSign,
    floorShadow,
    historyCouponIcon,
    historyCouponLine,
    historyKinIcon,
    historyShareButton,
    imageAnswerBorder,
    imageAnswerBorderSelected,
    kinCoin,
    kinLogoSplash,
    kinReward,
    kinTaskReward,
    kinTaskTime,
    kinTransactionCoins,
    moreTabIcon,
    multipleAnswerBackground,
    multipleAnswerBackgroundSelected,
    multipleAnswerCheckmark,
    multipleAnswerPlus,
    nextTask,
    noInternetIllustration,
    noOffers,
    offerCardShadow,
    offerCardTopLeftCorner,
    patternPlaceholder,
    paymentDelay,
    progressViewGradient,
    progressViewTrack,
    recordsLedger,
    redeemBubble,
    smallHeart,
    sowingIllustration,
    splashScreenBackground,
    tabBarBalance,
    tabBarEarn,
    tabBarMore,
    tabBarSpend,
    textAnswerShape,
    textAnswerShapeSelected,
    timer,
    transferFireworks,
    walletCreationFailed,
    welcomeTutorial1,
    welcomeTutorial2,
    welcomeTutorial3,
    whiteCheckmark,
  ]
  // swiftlint:enable trailing_comma
  @available(*, deprecated, renamed: "allImages")
  static let allValues: [AssetType] = allImages
}
// swiftlint:enable identifier_name line_length nesting type_body_length type_name

extension Image {
  @available(iOS 1.0, tvOS 1.0, watchOS 1.0, *)
  @available(OSX, deprecated,
    message: "This initializer is unsafe on macOS, please use the ImageAsset.image property")
  convenience init!(asset: ImageAsset) {
    #if os(iOS) || os(tvOS)
    let bundle = Bundle(for: BundleToken.self)
    self.init(named: asset.name, in: bundle, compatibleWith: nil)
    #elseif os(OSX)
    self.init(named: NSImage.Name(asset.name))
    #elseif os(watchOS)
    self.init(named: asset.name)
    #endif
  }
}

extension AssetColorTypeAlias {
  @available(iOS 11.0, tvOS 11.0, watchOS 4.0, OSX 10.13, *)
  convenience init!(asset: ColorAsset) {
    let bundle = Bundle(for: BundleToken.self)
    #if os(iOS) || os(tvOS)
    self.init(named: asset.name, in: bundle, compatibleWith: nil)
    #elseif os(OSX)
    self.init(named: NSColor.Name(asset.name), bundle: bundle)
    #elseif os(watchOS)
    self.init(named: asset.name)
    #endif
  }
}

private final class BundleToken {}
