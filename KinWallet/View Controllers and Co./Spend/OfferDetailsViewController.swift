//
//  OfferDetailsViewController.swift
//  Kinit
//

import UIKit

class OfferDetailsViewController: UIViewController {
    var interactiveDismissal: SwipeDownInteractiveDismissal?
    var offer: Offer! {
        didSet {
            self.actionViewController = offer.actionViewController()
        }
    }

    var actionViewController: SpendOfferActionViewController? {
        didSet {
            actionViewController?.offerViewController = self
        }
    }

    var redeemGood: RedeemGood?

    @IBOutlet weak var offerTypeImageView: UIImageView!

    @IBOutlet var toastView: UIView? {
        didSet {
            toastView?.widthAnchor.constraint(equalToConstant: 300).isActive = true
            toastView?.heightAnchor.constraint(equalToConstant: 54).isActive = true
            toastView?.layer.cornerRadius = 27
            toastView?.layer.masksToBounds = true
            toastView?.backgroundColor = UIColor.kin.gray
        }
    }

    @IBOutlet weak var toastLabel: UILabel! {
        didSet {
            toastLabel.font = FontFamily.Roboto.medium.font(size: 16)
            toastLabel.textColor = .white
        }
    }

    @IBOutlet weak var offerImageView: UIImageView!
    @IBOutlet weak var authorImageView: UIImageView! {
        didSet {
            authorImageView.layer.cornerRadius = 8
        }
    }

    @IBOutlet weak var actionView: UIView! {
        didSet {
            actionView.applyThinShadow()
        }
    }

    @IBOutlet weak var titleLabel: UILabel! {
        didSet {
            titleLabel.font = FontFamily.Roboto.medium.font(size: 22)
            titleLabel.textColor = UIColor.kin.darkGray
        }
    }

    @IBOutlet weak var descriptionLabel: UILabel! {
        didSet {
            descriptionLabel.numberOfLines = 0
            descriptionLabel.font = FontFamily.Roboto.regular.font(size: 16)
            descriptionLabel.textColor = UIColor.kin.gray
            descriptionLabel.adjustsFontSizeToFitWidth = true
            descriptionLabel.minimumScaleFactor = 0.5
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        let xImage = Asset.closeXButtonDarkGray.image
            .withRenderingMode(.alwaysOriginal)
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: xImage,
                                                           style: .plain,
                                                           target: self,
                                                           action: #selector(dismissTapped(_:)))
        drawOffer()

        addAndFit(actionViewController!, to: actionView)

        interactiveDismissal = SwipeDownInteractiveDismissal(viewController: self)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        logViewedPage()
    }

    @IBAction func dismissTapped(_ sender: UIBarButtonItem) {
        interactiveDismissal = nil
        dismiss(animated: true)
    }

    func drawOffer() {
        offerImageView.loadImage(url: offer.imageURL.kinImagePathAdjustedForDevice(),
                                 placeholderImage: Asset.patternPlaceholder.image)
        authorImageView.loadImage(url: offer.author.imageURL.kinImagePathAdjustedForDevice(),
                                  placeholderColor: UIColor.kin.extraLightGray)
        offerTypeImageView.loadImage(url: offer.typeImageUrl.kinImagePathAdjustedForDevice())

        titleLabel.text = offer.title
        descriptionLabel.text = offer.description
    }

    func showToast(with message: String) {
        guard let toastView = toastView else {
            return
        }

        view.addSubview(toastView)
        toastView.translatesAutoresizingMaskIntoConstraints = false
        toastView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        let finalTopConstraint = toastView.topAnchor.constraint(equalTo: actionView.topAnchor)
        finalTopConstraint.priority = .defaultHigh
        let initialBottomConstraint = view.bottomAnchor.constraint(equalTo: toastView.topAnchor)
        initialBottomConstraint.isActive = true
        view.layoutIfNeeded()

        UIView.animate(withDuration: 0.3,
                       delay: 0,
                       usingSpringWithDamping: 0.7,
                       initialSpringVelocity: 0.8,
                       options: [],
                       animations: { [weak self] in
                        initialBottomConstraint.isActive = false
                        finalTopConstraint.isActive = true
                        self?.view.layoutIfNeeded()
        }, completion: nil)

        DispatchQueue.main.asyncAfter(deadline: .now() + 3) { [weak self] in
            self?.dismissToast()
        }

        let swipeGestureRecognizer = UISwipeGestureRecognizer(target: self,
                                                  action: #selector(dismissToast))
        swipeGestureRecognizer.direction = .down
        let tapGestureRecognizer = UITapGestureRecognizer(target: self,
                                                          action: #selector(dismissToast))
        toastView.addGestureRecognizer(swipeGestureRecognizer)
        toastView.addGestureRecognizer(tapGestureRecognizer)
    }

    @objc fileprivate func dismissToast() {
        guard let toastView = toastView else {
            return
        }

        self.toastView = nil

        let dismissBottomConstraint = view.bottomAnchor.constraint(equalTo: toastView.topAnchor)
        dismissBottomConstraint.priority = .required
        UIView.animate(withDuration: 0.2,
                       animations: { [weak self] in
                        dismissBottomConstraint.isActive = true
                        self?.view.layoutIfNeeded()
            }, completion: { _ in
                toastView.removeFromSuperview()
        })
    }
}

extension OfferDetailsViewController {
    fileprivate func logViewedPage() {
        Events.Analytics
            .ViewOfferPage(brandName: offer.author.name,
                           kinPrice: Int(offer.price),
                           offerCategory: offer.domain,
                           offerId: offer.identifier,
                           offerName: offer.title,
                           offerType: offer.type)
            .send()
    }
}

class SwipeDownInteractiveDismissal: UIPercentDrivenInteractiveTransition {
    private weak var viewController: OfferDetailsViewController!

    fileprivate let gestureRecognizer = UIPanGestureRecognizer()
    private var interactionInProgress = false
    var currentProgress: CGFloat = 0
    private struct FinishTransitionThreshold {
        static let progress: CGFloat = 0.5
        static let yVelocity: CGFloat = 800
    }

    init(viewController: OfferDetailsViewController) {
        self.viewController = viewController

        super.init()
        wireViewController()
    }

    private func wireViewController() {
        gestureRecognizer.addTarget(self, action: #selector(handlePan))
        gestureRecognizer.delegate = self
        viewController.view.addGestureRecognizer(gestureRecognizer)
    }

    @objc func handlePan() {
        let yTranslation = gestureRecognizer.translation(in: gestureRecognizer.view).y

        switch gestureRecognizer.state {
        case .began, .changed:
            if !interactionInProgress {
                viewController.dismiss(animated: true)
                interactionInProgress = true
            }

            currentProgress = max(0, yTranslation / viewController.view.frame.height)
            update(currentProgress)
        case .cancelled, .failed:
            cancel()
        case .ended:
            let yVelocity = gestureRecognizer.velocity(in: gestureRecognizer.view).y

            if currentProgress > FinishTransitionThreshold.progress
                || yVelocity > FinishTransitionThreshold.yVelocity {
                finish()
            } else {
                cancel()
            }
        default:
            break
        }
    }

    override func cancel() {
        super.cancel()

        interactionInProgress = false
    }
}

extension SwipeDownInteractiveDismissal: UIGestureRecognizerDelegate {
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        let velocity = self.gestureRecognizer.velocity(in: gestureRecognizer.view)
        return velocity.y > 0 && velocity.y > abs(velocity.x)
    }
}
