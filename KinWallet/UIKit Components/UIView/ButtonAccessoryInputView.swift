//
//  ButtonAccessoryInputView.swift
//  KinWallet
//
//  Copyright © 2018 KinFoundation. All rights reserved.
//

import UIKit
import KinUtil

class ButtonAccessoryInputView: UIView {
    class func nextActionButton() -> ButtonAccessoryInputView {
        let b = ButtonAccessoryInputView()
        b.title = L10n.nextAction
        b.translatesAutoresizingMaskIntoConstraints = false

        return b
    }

    private let button: UIButton = {
        let b = UIButton(type: .system)
        b.titleLabel?.font = FontFamily.Roboto.regular.font(size: 18)

        return b
    }()

    lazy var activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .gray)

    let tapped = Observable<Void>()

    var title: String? {
        get {
            return button.title(for: .normal)
        }
        set {
            button.setTitle(newValue, for: .normal)
        }
    }

    var isEnabled: Bool {
        get {
            return button.isEnabled
        }
        set {
            button.isEnabled = newValue
        }
    }

    var isLoading: Bool = false {
        didSet {
            isLoading ? activityIndicator.startAnimating() : activityIndicator.stopAnimating()
            button.isHidden = isLoading
        }
    }

    override var intrinsicContentSize: CGSize {
        return CGSize(width: UIScreen.main.bounds.width,
                      height: ButtonAccessoryInputView.intrinsicHeight)
    }

    static var intrinsicHeight: CGFloat {
        return UIDevice.isiPhone5() ? 48 : 68
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        commonInit()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        commonInit()
    }

    func commonInit() {
        backgroundColor = .white
        applyThinShadow()

        button.translatesAutoresizingMaskIntoConstraints = false
        addAndFit(button)
        button.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)

        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.hidesWhenStopped = true
        addSubview(activityIndicator)
        activityIndicator.centerInSuperview()
    }

    @objc func buttonTapped() {
        tapped.next(())
    }
}
