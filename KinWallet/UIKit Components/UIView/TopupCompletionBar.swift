//
//  TopupCompletionBar.swift
//  KinWallet
//
//  Copyright © 2019 KinFoundation. All rights reserved.
//

import UIKit

protocol TopupCompletionBarDelegate: class {
    func topupCompletionBarDidTapClose(_ completionBar: TopupCompletionBar)
    func topupCompletionBarDidTapBackToApp(_ completionBar: TopupCompletionBar)
}

typealias TopupCompletionResult = Result<(String, UInt64), Error>

private let font = FontFamily.Sailec.medium.font(size: 14) ?? UIFont.systemFont(ofSize: 14)

class TopupCompletionBar: UIView {
    let result: TopupCompletionResult
    weak var delegate: TopupCompletionBarDelegate?

    private let messageLabel = with(UILabel()) {
        $0.font = font
        $0.textColor = .white
        $0.adjustsFontSizeToFitWidth = true
        $0.minimumScaleFactor = 0.5
    }

    init(result: TopupCompletionResult, delegate: TopupCompletionBarDelegate) {
        self.result = result
        self.delegate = delegate

        super.init(frame: .zero)

        setupSubViews()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupSubViews() {
        let actionButton = UIButton(type: .custom)
        actionButton.tintColor = .white
        let stackView = UIStackView(arrangedSubviews: [messageLabel, actionButton])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.spacing = 2

        switch result {
        case .success(let appName, let amount):
            backgroundColor = UIColor.kin.ecosystemPurple
            messageLabel.attributedText = attributedSuccessText(amount: amount)
            let buttonTitle = NSAttributedString(string: "Back to \(appName)",
                attributes: [.font: font,
                             .foregroundColor: UIColor.white,
                             .underlineStyle: NSUnderlineStyle.single.rawValue])
            actionButton.setAttributedTitle(buttonTitle, for: .normal)
            actionButton.addTarget(self, action: #selector(backToAppTapped), for: .primaryActionTriggered)
            stackView.axis = .vertical
            stackView.alignment = .leading
            stackView.distribution = .fillEqually
        case .failure://(let error):
            backgroundColor = UIColor.kin.cranberryRed
            messageLabel.numberOfLines = 2
            messageLabel.setTextApplyingLineSpacing("This top up didn't go through. Please try again later.")
            let xImage = Asset.closeButtonBlack.image.withRenderingMode(.alwaysTemplate)
            actionButton.setImage(xImage, for: .normal)
            actionButton.setContentHuggingPriority(.defaultHigh, for: .horizontal)
            actionButton.addTarget(self, action: #selector(closeTapped), for: .primaryActionTriggered)
            actionButton.widthAnchor.constraint(equalToConstant: 44).isActive = true
            actionButton.heightAnchor.constraint(equalToConstant: 44).isActive = true
            stackView.axis = .horizontal
            stackView.alignment = .center
        }

        addSubview(stackView)
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12),
            stackView.topAnchor.constraint(equalTo: topAnchor, constant: 12),
            trailingAnchor.constraint(equalTo: stackView.trailingAnchor, constant: 12),
            safeBottomAnchor.constraint(equalTo: stackView.bottomAnchor, constant: 12)
            ])
    }

    private func attributedSuccessText(amount: UInt64) -> NSAttributedString {
        let initialText = "You've successfully topped up "
        let attributedText = NSMutableAttributedString(string: initialText)

        let kFont = FontFamily.KinK.regular.font(size: 6) ?? UIFont.systemFont(ofSize: 6)
        attributedText.append(.init(string: "K ", attributes: [.font: kFont, .baselineOffset: 2]))

        let formattedAmount = KinAmountLabel.amountFormatter.string(from: .init(value: amount))
            ?? String(describing: amount)
        attributedText.append(.init(string: formattedAmount))

        return attributedText
    }

    @objc private func closeTapped() {
        delegate?.topupCompletionBarDidTapClose(self)
    }

    @objc private func backToAppTapped() {
        delegate?.topupCompletionBarDidTapBackToApp(self)
    }
}
