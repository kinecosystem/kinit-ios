// swiftlint:disable all
// Generated using SwiftGen — https://github.com/SwiftGen/SwiftGen

#if os(OSX)
  import AppKit.NSFont
  internal typealias Font = NSFont
#elseif os(iOS) || os(tvOS) || os(watchOS)
  import UIKit.UIFont
  internal typealias Font = UIFont
#endif

// swiftlint:disable superfluous_disable_command
// swiftlint:disable file_length

// MARK: - Fonts

// swiftlint:disable identifier_name line_length type_body_length
internal enum FontFamily {
  internal enum KinK {
    internal static let regular = FontConvertible(name: "Kin_k", family: "Kin_k", path: "KinK.ttf")
    internal static let all: [FontConvertible] = [regular]
  }
  internal enum Roboto {
    internal static let black = FontConvertible(name: "Roboto-Black", family: "Roboto", path: "Roboto-Black.ttf")
    internal static let blackItalic = FontConvertible(name: "Roboto-BlackItalic", family: "Roboto", path: "Roboto-BlackItalic.ttf")
    internal static let bold = FontConvertible(name: "Roboto-Bold", family: "Roboto", path: "Roboto-Bold.ttf")
    internal static let boldItalic = FontConvertible(name: "Roboto-BoldItalic", family: "Roboto", path: "Roboto-BoldItalic.ttf")
    internal static let italic = FontConvertible(name: "Roboto-Italic", family: "Roboto", path: "Roboto-Italic.ttf")
    internal static let light = FontConvertible(name: "Roboto-Light", family: "Roboto", path: "Roboto-Light.ttf")
    internal static let lightItalic = FontConvertible(name: "Roboto-LightItalic", family: "Roboto", path: "Roboto-LightItalic.ttf")
    internal static let medium = FontConvertible(name: "Roboto-Medium", family: "Roboto", path: "Roboto-Medium.ttf")
    internal static let mediumItalic = FontConvertible(name: "Roboto-MediumItalic", family: "Roboto", path: "Roboto-MediumItalic.ttf")
    internal static let regular = FontConvertible(name: "Roboto-Regular", family: "Roboto", path: "Roboto-Regular.ttf")
    internal static let thin = FontConvertible(name: "Roboto-Thin", family: "Roboto", path: "Roboto-Thin.ttf")
    internal static let thinItalic = FontConvertible(name: "Roboto-ThinItalic", family: "Roboto", path: "Roboto-ThinItalic.ttf")
    internal static let all: [FontConvertible] = [black, blackItalic, bold, boldItalic, italic, light, lightItalic, medium, mediumItalic, regular, thin, thinItalic]
  }
  internal enum Sailec {
    internal static let black = FontConvertible(name: "Sailec-Black", family: "Sailec", path: "Sailec-Black.otf")
    internal static let blackItalic = FontConvertible(name: "Sailec-BlackItalic", family: "Sailec", path: "Sailec-Black-Italic.otf")
    internal static let bold = FontConvertible(name: "Sailec-Bold", family: "Sailec", path: "Sailec-Bold.otf")
    internal static let boldItalic = FontConvertible(name: "Sailec-BoldItalic", family: "Sailec", path: "Sailec-Bold-Italic.otf")
    internal static let hairline = FontConvertible(name: "Sailec-Hairline", family: "Sailec", path: "Sailec-Hairline.otf")
    internal static let hairlineItalic = FontConvertible(name: "Sailec-HairlineItalic", family: "Sailec", path: "Sailec-Hairline-Italic.otf")
    internal static let light = FontConvertible(name: "Sailec-Light", family: "Sailec", path: "Sailec-Light.otf")
    internal static let lightItalic = FontConvertible(name: "Sailec-LightItalic", family: "Sailec", path: "Sailec-Light-Italic.otf")
    internal static let medium = FontConvertible(name: "Sailec-Medium", family: "Sailec", path: "Sailec-Medium.otf")
    internal static let mediumItalic = FontConvertible(name: "Sailec-MediumItalic", family: "Sailec", path: "Sailec-Medium-Italic.otf")
    internal static let regular = FontConvertible(name: "Sailec-Regular", family: "Sailec", path: "Sailec.otf")
    internal static let regularItalic = FontConvertible(name: "Sailec-RegularItalic", family: "Sailec", path: "Sailec-Regular-Italic.otf")
    internal static let thin = FontConvertible(name: "Sailec-Thin", family: "Sailec", path: "Sailec-Thin.otf")
    internal static let thinItalic = FontConvertible(name: "Sailec-ThinItalic", family: "Sailec", path: "Sailec-Thin-Italic.otf")
    internal static let all: [FontConvertible] = [black, blackItalic, bold, boldItalic, hairline, hairlineItalic, light, lightItalic, medium, mediumItalic, regular, regularItalic, thin, thinItalic]
  }
  internal static let allCustomFonts: [FontConvertible] = [KinK.all, Roboto.all, Sailec.all].flatMap { $0 }
  internal static func registerAllCustomFonts() {
    allCustomFonts.forEach { $0.register() }
  }
}
// swiftlint:enable identifier_name line_length type_body_length

// MARK: - Implementation Details

internal struct FontConvertible {
  internal let name: String
  internal let family: String
  internal let path: String

  internal func font(size: CGFloat) -> Font! {
    return Font(font: self, size: size)
  }

  internal func register() {
    // swiftlint:disable:next conditional_returns_on_newline
    guard let url = url else { return }
    CTFontManagerRegisterFontsForURL(url as CFURL, .process, nil)
  }

  fileprivate var url: URL? {
    let bundle = Bundle(for: BundleToken.self)
    return bundle.url(forResource: path, withExtension: nil)
  }
}

internal extension Font {
  convenience init!(font: FontConvertible, size: CGFloat) {
    #if os(iOS) || os(tvOS) || os(watchOS)
    if !UIFont.fontNames(forFamilyName: font.family).contains(font.name) {
      font.register()
    }
    #elseif os(OSX)
    if let url = font.url, CTFontManagerGetScopeForURL(url as CFURL) == .none {
      font.register()
    }
    #endif

    self.init(name: font.name, size: size)
  }
}

private final class BundleToken {}
