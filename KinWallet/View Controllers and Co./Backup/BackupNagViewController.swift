//
//  BackupNagViewController.swift
//  KinWallet
//
//  Copyright © 2018 KinFoundation. All rights reserved.
//

import UIKit

enum BackupNagDay: Int {
    case now = 0
    case week = 6
    case twoWeeks = 13
    case month = 29
}

extension BackupNagDay {
    var alertTitle: String {
        switch self {
        case .now: return L10n.backupNagZeroTitle
        case .week: return L10n.backupNagSevenTitle
        case .twoWeeks: return L10n.backupNagFourteenTitle
        case .month: return L10n.backupNagThirtyTitle
        }
    }

    var alertMessage: String {
        switch self {
        case .now: return L10n.backupNagZeroMessage
        case .week: return L10n.backupNagSevenMessage
        case .twoWeeks: return L10n.backupNagFourteenMessage
        case .month: return L10n.backupNagThirtyMessage
        }
    }

    var toAnalytics: Events.BackupNotificationType {
        switch self {
        case .now: return .day1
        case .week: return .day7
        case .twoWeeks: return .day14
        case .month: return .day30
        }
    }
}

protocol BackupNagDelegate: class {
    func backupNagDidSelectBackupNow(_ backupNagViewController: BackupNagViewController)
    func backupNagDidSelectBackupLater(_ backupNagViewController: BackupNagViewController)
}

class BackupNagViewController: UIViewController {
    @IBOutlet weak var titleLabel: UILabel! {
        didSet {
            titleLabel.font = FontFamily.Roboto.medium.font(size: 16)
            titleLabel.textColor = UIColor.kin.gray
            titleLabel.text = L10n.backUpAction
        }
    }

    @IBOutlet weak var messageLabel: UILabel! {
        didSet {
            messageLabel.font = FontFamily.Roboto.regular.font(size: 15)
            messageLabel.textColor = UIColor.kin.gray
        }
    }

    @IBOutlet weak var backupButton: UIButton! {
        didSet {
            backupButton.setTitle(L10n.backUpAction, for: .normal)
            backupButton.makeKinButtonFilled()
        }
    }

    @IBOutlet weak var laterButton: UIButton! {
        didSet {
            laterButton.setTitle(L10n.later, for: .normal)
            laterButton.tintColor = UIColor.kin.gray
            laterButton.titleLabel?.font = FontFamily.Roboto.regular.font(size: 14)
        }
    }

    var nagDay: BackupNagDay!
    weak var delegate: BackupNagDelegate?

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)

        commonInit()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        commonInit()
    }

    func commonInit() {
        transitioningDelegate = self
        modalPresentationStyle = .custom
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        titleLabel.text = nagDay.alertTitle
        messageLabel.text = nagDay.alertMessage
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        Events.Analytics
            .ViewBackupNotificationPopup(backupNotificationType: nagDay.toAnalytics)
            .send()
    }

    override var preferredContentSize: CGSize {
        get {
            return CGSize(width: 280, height: 366)
        }
        set {
            super.preferredContentSize = newValue
        }
    }

    @IBAction func backupNow() {
        Events.Analytics
            .ClickBackupButtonOnBackupNotificationPopup(backupNotificationType: nagDay.toAnalytics)
            .send()
        delegate?.backupNagDidSelectBackupNow(self)
    }

    @IBAction func backupLater() {
        delegate?.backupNagDidSelectBackupLater(self)
    }
}

extension BackupNagViewController: UIViewControllerTransitioningDelegate {
    func presentationController(forPresented presented: UIViewController,
                                presenting: UIViewController?,
                                source: UIViewController) -> UIPresentationController? {
        if presented is BackupNagViewController {
            return FormsheetPresentationController(presentedViewController: presented,
                                                   presenting: presenting)
        }

        return nil
    }

    func animationController(forPresented presented: UIViewController,
                             presenting: UIViewController,
                             source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return BackupNagTransitionAnimator()
    }
}

private class BackupNagTransitionAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    let duration: TimeInterval = 0.7

    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return duration
    }

    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard
            let toVC = transitionContext.viewController(forKey: .to),
            let toView = transitionContext.view(forKey: .to) else {
                return
        }

        let containerView = transitionContext.containerView

        let finalFrame = transitionContext.finalFrame(for: toVC)

        var initialFrame = finalFrame
        initialFrame.origin.y = containerView.bounds.maxY

        toView.frame = initialFrame
        toView.transform = CGAffineTransform.init(scaleX: 0.8, y: 0.8)

        containerView.addSubview(toView)

        UIView.animate(withDuration: transitionDuration(using: transitionContext),
                       delay: 0,
                       usingSpringWithDamping: 0.8,
                       initialSpringVelocity: 0.8,
                       options: [], animations: {
                        toView.transform = .identity
                        toView.frame = finalFrame
        }, completion: { _ in
            let didComplete = !transitionContext.transitionWasCancelled
            transitionContext.completeTransition(didComplete)
        })
    }
}
