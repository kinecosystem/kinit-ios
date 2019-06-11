//
//  KinitInputActionBar.swift
//  KinWallet
//
//  Copyright © 2019 KinFoundation. All rights reserved.
//

import UIKit

private let actionBarContentHeight: CGFloat = 72

protocol KinInputActionBarDelegate: class {
    func kinInputActionBarDidTap()
}

final class KinInputActionBar: UIView {
    private let actionButton: UIButton
    private let progressLabel: UILabel
    private let progressView: UIView
    private var progressHeightConstraint: NSLayoutConstraint!
    private var progressEqualHeightsConstraint: NSLayoutConstraint!
    private var animationTimer: Timer?
    weak var delegate: KinInputActionBarDelegate?
    private let style: KinInputActionBarStyle

    var isEnabled: Bool {
        get {
            return actionButton.isEnabled && !actionButton.isHidden
        }
        set {
            actionButton.isEnabled = newValue
            backgroundColor = newValue ? style.backgroundColor : style.disabledBackgroundColor
        }
    }

    init(title: String,
         progressText: String,
         style: KinInputActionBarStyle) {
        self.style = style

        actionButton = UIButton(type: .system)
        actionButton.setTitle(title, for: .normal)
        actionButton.setBackgroundImage(.from(style.backgroundColor), for: .normal)
        actionButton.setBackgroundImage(.from(style.disabledBackgroundColor), for: .disabled)
        actionButton.setTitleColor(style.textColor, for: .normal)
        actionButton.setTitleColor(style.disabledTextColor, for: .disabled)
        actionButton.titleLabel?.font = style.font

        progressLabel = UILabel(frame: .zero)
        progressLabel.textAlignment = .center
        progressLabel.text = progressText
        progressLabel.font = style.font
        progressLabel.textColor = style.textColor
        progressLabel.isHidden = true

        progressView = UIView(frame: .zero)
        progressView.backgroundColor = style.progressColor

        super.init(frame: .zero)

        addSubview(progressView)
        addAndFit(progressLabel, layoutReference: .safeArea)
        addAndFit(actionButton, layoutReference: .safeArea)

        progressView.translatesAutoresizingMaskIntoConstraints = false
        leadingAnchor.constraint(equalTo: progressView.leadingAnchor).isActive = true
        bottomAnchor.constraint(equalTo: progressView.bottomAnchor).isActive = true
        trailingAnchor.constraint(equalTo: progressView.trailingAnchor).isActive = true
        progressHeightConstraint = progressView.heightAnchor.constraint(equalToConstant: 0)
        progressHeightConstraint.isActive = true

        progressEqualHeightsConstraint = heightAnchor.constraint(equalTo: progressView.heightAnchor,
                                                                 multiplier: 1,
                                                                 constant: 0)

        self.backgroundColor = style.backgroundColor
        actionButton.addTarget(self, action: #selector(actionButtonTapped), for: .primaryActionTriggered)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override var intrinsicContentSize: CGSize {
        var bottomInset: CGFloat = 0

        if #available(iOS 11.0, *) {
            bottomInset = UIApplication.shared.keyWindow?.safeAreaInsets.bottom ?? 0
        }

        return CGSize(width: UIView.noIntrinsicMetric,
                      height: actionBarContentHeight + bottomInset)
    }

    @objc func actionButtonTapped() {
        delegate?.kinInputActionBarDidTap()
    }

    func startProgress(duration: TimeInterval) {
        actionButton.isHidden = true
        progressLabel.isHidden = false
        progressHeightConstraint.constant = 0
        let finalHeight = frame.height

        let startDate = Date()
        animationTimer = Timer.scheduledTimer(withTimeInterval: 0.016, repeats: true) { [weak self] _ in
            let progress = Date().timeIntervalSince(startDate) / duration
            self?.progressHeightConstraint.constant = finalHeight * CGFloat(progress)
        }
    }

    func finishProgress(duration: TimeInterval, completion: ((Bool) -> Void)? = nil) {
        animationTimer?.invalidate()
        animationTimer = nil

        progressView.layer.removeAllAnimations()

        UIView.animate(withDuration: duration, delay: 0, options: .beginFromCurrentState, animations: {
            self.progressHeightConstraint.isActive = false
            self.progressEqualHeightsConstraint.isActive = true
            self.layoutIfNeeded()
        }, completion: completion)
    }

    func reset(isEnabled: Bool) {
        animationTimer?.invalidate()
        animationTimer = nil

        actionButton.isEnabled = isEnabled
        actionButton.isHidden = false
        progressLabel.isHidden = true
        progressEqualHeightsConstraint.isActive = false
        progressHeightConstraint.constant = 0
        progressHeightConstraint.isActive = true
    }
}
