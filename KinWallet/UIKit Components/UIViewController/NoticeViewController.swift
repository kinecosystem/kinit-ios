//
//  NoticeViewController.swift
//  Kinit
//

import UIKit

struct NoticeContent {
    var title: String
    var message: String?
    var image: UIImage

    static let generalServerError = NoticeContent(title: L10n.ServerError.title,
                                                  message: L10n.ServerError.message,
                                                  image: Asset.serverErrorIllustration.image)

    static func fromError(_ error: Error) -> NoticeContent {
        let aError = error as NSError

        if aError.isInternetError {
            return NoticeContent(title: L10n.NoInternetError.title,
                                 message: L10n.NoInternetError.message,
                                 image: Asset.noInternetIllustration.image)
        }

        return generalServerError
    }
}

struct Notice {
    let content: NoticeContent
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
    func noticeViewControllerDidTapAdditionalMessage(_ viewController: NoticeViewController)
}

extension NoticeViewControllerDelegate {
    func noticeViewControllerDidTapAdditionalMessage(_ viewController: NoticeViewController) {

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

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupNotice()
    }

    func setupNotice() {
        titleLabel.text = notice.content.title
        subtitleLabel.text = notice.content.message
        imageView.image = notice.content.image
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
        delegate?.noticeViewControllerDidTapAdditionalMessage(self)
    }
}

protocol AddNoticeViewController {
    func addNoticeViewController(with content: NoticeContent,
                                 buttonConfiguration: NoticeButtonConfiguration?,
                                 displayType: Notice.DisplayType,
                                 delegate: NoticeViewControllerDelegate?) -> NoticeViewController
}

extension UIViewController: AddNoticeViewController {
    @discardableResult
    func addNoticeViewController(with content: NoticeContent,
                                 buttonConfiguration: NoticeButtonConfiguration? = nil,
                                 displayType: Notice.DisplayType = .imageFirst,
                                 delegate: NoticeViewControllerDelegate? = nil) -> NoticeViewController {
        let noticeViewController = StoryboardScene.Main.noticeViewController.instantiate()
        noticeViewController.delegate = delegate
        noticeViewController.notice = Notice(content: content,
                                             buttonConfiguration: buttonConfiguration,
                                             displayType: displayType)
        addAndFit(noticeViewController)

        return noticeViewController
    }
}
