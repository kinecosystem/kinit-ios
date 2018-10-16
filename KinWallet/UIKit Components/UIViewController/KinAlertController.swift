//
//  KinAlertController.swift
//  KinWallet
//
//  Copyright © 2018 KinFoundation. All rights reserved.
//

import UIKit

class KinAlertAction {
    let handler: (() -> Void)?
    let title: String

    init(title: String, handler: (() -> Void)? = nil) {
        self.title = title
        self.handler = handler
    }
}

private class KinAlertControllerPresenter: UIViewController {
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
}

class KinAlertController: UIViewController {
    func showInNewWindow() {
        let presenter = KinAlertControllerPresenter()
        presenter.view.backgroundColor = .clear

        let alertWindow = UIWindow()
        alertWindow.backgroundColor = .clear
        alertWindow.rootViewController = presenter
        alertWindow.makeKeyAndVisible()

        presenter.presentAnimated(self)
    }

    init(title: String,
         titleImage: UIImage?,
         message: String,
         primaryAction: KinAlertAction,
         secondaryAction: KinAlertAction?) {
        super.init(nibName: nil, bundle: nil)

        transitioningDelegate = self
        modalPresentationStyle = .custom

        let internalAlert = InternalKinAlertController.controllerWith(title: title,
                                                                      titleImage: titleImage,
                                                                      message: message,
                                                                      primaryAction: primaryAction,
                                                                      secondaryAction: secondaryAction)
        addAndFit(internalAlert)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override var preferredContentSize: CGSize {
        get {
            return CGSize(width: 280, height: 366)
        }
        set {
            super.preferredContentSize = newValue
        }
    }
}

class InternalKinAlertController: UIViewController {
    var primaryAction: KinAlertAction!
    var secondaryAction: KinAlertAction?

    var message: String? = nil {
        didSet {
            if isViewLoaded {
                messageLabel.text = message
            }
        }
    }

    var alertTitle: String? = nil {
        didSet {
            if isViewLoaded {
                titleLabel.text = alertTitle
            }
        }
    }

    var titleImage: UIImage? = nil {
        didSet {
            if isViewLoaded {
                titleImageView.image = titleImage
            }
        }
    }

    class func controllerWith(title: String,
                              titleImage: UIImage?,
                              message: String,
                              primaryAction: KinAlertAction,
                              secondaryAction: KinAlertAction?) -> InternalKinAlertController {
        let alertController = StoryboardScene.Main.internalKinAlertController.instantiate()
        alertController.alertTitle = title
        alertController.titleImage = titleImage
        alertController.message = message
        alertController.primaryAction = primaryAction
        alertController.secondaryAction = secondaryAction

        return alertController
    }

    @IBOutlet weak var titleImageView: UIImageView!

    @IBOutlet weak var titleLabel: UILabel! {
        didSet {
            titleLabel.font = FontFamily.Roboto.medium.font(size: 16)
            titleLabel.textColor = UIColor.kin.gray
        }
    }

    @IBOutlet weak var messageLabel: UILabel! {
        didSet {
            messageLabel.font = FontFamily.Roboto.regular.font(size: 15)
            messageLabel.textColor = UIColor.kin.gray
        }
    }

    @IBOutlet weak var primaryActionButton: UIButton! {
        didSet {
            primaryActionButton.makeKinButtonFilled()
        }
    }

    @IBOutlet weak var secondaryButton: UIButton! {
        didSet {
            secondaryButton.tintColor = UIColor.kin.gray
            secondaryButton.titleLabel?.font = FontFamily.Roboto.regular.font(size: 14)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        titleLabel.text = alertTitle
        titleImageView.image = titleImage
        messageLabel.text = message

        primaryActionButton.setTitle(primaryAction.title, for: .normal)

        if let secondaryAction = secondaryAction {
            secondaryButton.setTitle(secondaryAction.title, for: .normal)
        } else {
            secondaryButton.isHidden = true
        }
    }

    @IBAction func primaryButtonTapped() {
        primaryAction.handler?()
    }

    @IBAction func secondaryButtonTapped() {
        if let handler = secondaryAction?.handler {
            handler()
        } else {
            dismissAnimated()
        }
    }
}

extension KinAlertController: UIViewControllerTransitioningDelegate {
    func presentationController(forPresented presented: UIViewController,
                                presenting: UIViewController?,
                                source: UIViewController) -> UIPresentationController? {
        if presented is KinAlertController {
            return FormsheetPresentationController(presentedViewController: presented,
                                                   presenting: presenting)
        }

        return nil
    }

    func animationController(forPresented presented: UIViewController,
                             presenting: UIViewController,
                             source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return KinAlertTransitionAnimator()
    }
}

private class KinAlertTransitionAnimator: NSObject, UIViewControllerAnimatedTransitioning {
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
