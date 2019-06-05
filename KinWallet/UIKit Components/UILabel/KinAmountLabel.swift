//
//  KinAmountLabel.swift
//  Kinit
//

import UIKit

enum AmountLabelSize: Int {
    case small = 24
    case large = 56
}

enum AmountLabelType {
    case prefixed
    case suffixed
}

class KinAmountFormatter: NumberFormatter {
    override init() {
        super.init()

        locale = Locale.current
        usesGroupingSeparator = true
        numberStyle = .decimal
        maximumFractionDigits = 0
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class KinAmountLabel: UILabel {
    static let amountFormatter = KinAmountFormatter()

    var size = AmountLabelSize.small {
        didSet {
            if oldValue != size {
                renderAmount()
            }
        }
    }

    var type = AmountLabelType.suffixed {
        didSet {
            if oldValue != type {
                renderAmount()
            }
        }
    }

    var amount: UInt64 = 0 {
        didSet {
            renderAmount()
        }
    }

    private func attributedPrefix() -> NSAttributedString? {
        guard type == .prefixed else {
            return nil
        }

        let kFontSize = floor(CGFloat(size.rawValue) * 0.42)
        let kFont = FontFamily.KinK.regular.font(size: kFontSize) ?? UIFont.systemFont(ofSize: kFontSize)

        return NSAttributedString(string: "K ", attributes: [.font: kFont, .baselineOffset: 6])
    }

    private func attributedSuffix() -> NSAttributedString? {
        guard type == .suffixed else {
            return nil
        }

        let text = " KIN ( K )"
        let fontSize = floor(CGFloat(size.rawValue) * 0.6)
        let font = FontFamily.Sailec.regular.font(size: fontSize) ?? UIFont.systemFont(ofSize: fontSize)
        let kFontSize = floor(CGFloat(size.rawValue) * 0.42)
        let kFont = FontFamily.KinK.regular.font(size: kFontSize) ?? UIFont.systemFont(ofSize: kFontSize)
        let attributedString = NSMutableAttributedString(string: text, attributes: [.font: font])

        attributedString.addAttribute(.baselineOffset, value: 3, range: NSRange(location: 0, length: text.count))
        attributedString.addAttribute(.font, value: kFont, range: NSRange(location: 7, length: 1))

        return attributedString
    }

    private func renderAmount() {
        let attributedBalance = self.attributedNumber(self.amount)
        let attributedText = NSMutableAttributedString()

        if let prefix = attributedPrefix() {
            attributedText.append(prefix)
        }

        attributedText.append(attributedBalance)

        if let suffix = attributedSuffix() {
            attributedText.append(suffix)
        }

        self.attributedText = attributedText
    }

    private func attributedNumber(_ amount: UInt64) -> NSAttributedString {
        let fontSize = CGFloat(size.rawValue)
        let fontConvertible =  FontFamily.Sailec.bold

        let formattedAmount = KinAmountLabel.amountFormatter.string(from: NSNumber(value: amount))
        let font = fontConvertible.font(size: fontSize) ?? UIFont.systemFont(ofSize: fontSize)
        let amountString = formattedAmount ?? String(amount)
        return NSAttributedString(string: amountString, attributes: [.font: font])
    }
}
