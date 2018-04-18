//
//  NoticeViewController.swift
//  KinWallet
//
//  Copyright © 2018 KinFoundation. All rights reserved.
//

import UIKit

let noInternetTitle = "Your internet is MIA"
let noInternetSubtitle = "It seems that something is missing...\nPlease check your internet connection."
let noInternetImage = Asset.noInternetIllustration.image

struct Notice {
    let image: UIImage
    let title: String
    let subtitle: String?
    let buttonConfiguration: NoticeButtonConfiguration?
    let displayType: DisplayType

    enum DisplayType {
        case titleFirst
        case imageFirst
    }
}

enum ButtonMode {
    case fill
    case stroke
}

struct NoticeButtonConfiguration {
    let title: String
    let mode: ButtonMode
    let additionalMessage: NSAttributedString?

    init(title: String, mode: ButtonMode, additionalMessage: NSAttributedString? = nil) {
        self.title = title
        self.mode = mode
        self.additionalMessage = additionalMessage
    }
}

protocol NoticeViewControllerDelegate: class {
    func noticeViewControllerDidTapButton(_ viewController: NoticeViewController)
    func noticeViewControllerDidAdditionalMessage(_ viewController: NoticeViewController)
}

extension NoticeViewControllerDelegate {
    func noticeViewControllerDidAdditionalMessage(_ viewController: NoticeViewController) {

    }
}

class NoticeViewController: UIViewController {
    weak var delegate: NoticeViewControllerDelegate?
    var notice: Notice!

    @IBOutlet weak var mainStackView: UIStackView!
    @IBOutlet weak var button: UIButton!
    @IBOutlet weak var imageView: UIImageView!

    @IBOutlet weak var buttonStackView: UIStackView!

    @IBOutlet weak var titleLabel: UILabel! {
        didSet {
            titleLabel.textColor = UIColor.kin.gray
            titleLabel.font = FontFamily.Roboto.regular.font(size: 16)
        }
    }

    @IBOutlet weak var additionalMessageLabel: UILabel!

    @IBOutlet weak var subtitleLabel: UILabel! {
        didSet {
            subtitleLabel.font = FontFamily.Roboto.regular.font(size: 14)
            subtitleLabel.textColor = UIColor.kin.cadetBlue
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupNotice()
    }

    func setupNotice() {
        titleLabel.text = notice.title
        subtitleLabel.text = notice.subtitle
        imageView.image = notice.image
        setupButton()

        if notice.displayType == .titleFirst {
            titleLabel.font = FontFamily.Roboto.regular.font(size: 22)
            titleLabel.textColor = UIColor.kin.blue
            mainStackView.insertArrangedSubview(titleLabel, at: 0)
        }
    }

    func hideButton() {
        guard !button.isHidden else {
            return
        }

        UIView.animate(withDuration: 0.25, animations: {
            self.button.alpha = 0
        }, completion: { _ in
            self.button.alpha = 1
            self.button.isHidden = true
        })
    }

    func setupButton() {
        if let buttonConfiguration = notice.buttonConfiguration {
            button.addTarget(self,
                             action: #selector(buttonTapped),
                             for: .touchUpInside)
            button.setTitle(buttonConfiguration.title, for: .normal)

            buttonConfiguration.mode == .fill
                ? button.makeKinButtonFilled()
                : button.makeKinButtonOutlined()

            additionalMessageLabel.attributedText = buttonConfiguration.additionalMessage
            additionalMessageLabel.isUserInteractionEnabled = true

            let tapGesture = UITapGestureRecognizer(target: self,
                                                    action: #selector(additionalLabelTapped))
            additionalMessageLabel.addGestureRecognizer(tapGesture)
        } else {
            buttonStackView.isHidden = true
        }
    }

    @objc func buttonTapped() {
        delegate?.noticeViewControllerDidTapButton(self)
    }

    @objc func additionalLabelTapped() {
        delegate?.noticeViewControllerDidAdditionalMessage(self)
    }
}

protocol AddNoticeViewController {
    func addNoticeViewController(with title: String,
                                 subtitle: String?,
                                 image: UIImage,
                                 buttonConfiguration: NoticeButtonConfiguration?,
                                 displayType: Notice.DisplayType,
                                 delegate: NoticeViewControllerDelegate?) -> NoticeViewController
}

extension AddNoticeViewController where Self: UIViewController {
    @discardableResult
    func addNoticeViewController(with title: String,
                                 subtitle: String?,
                                 image: UIImage,
                                 buttonConfiguration: NoticeButtonConfiguration? = nil,
                                 displayType: Notice.DisplayType = .imageFirst,
                                 delegate: NoticeViewControllerDelegate? = nil) -> NoticeViewController {
        let noticeViewController = StoryboardScene.Main.noticeViewController.instantiate()
        noticeViewController.delegate = delegate
        noticeViewController.notice = Notice(image: image,
                                             title: title,
                                             subtitle: subtitle,
                                             buttonConfiguration: buttonConfiguration,
                                             displayType: displayType)
        addAndFit(noticeViewController)

        return noticeViewController
    }
}
