//
//  OfferWallViewController.swift
//  Kinit
//

import UIKit
import KinUtil

class OfferWallViewController: UIViewController {
    fileprivate var layout: UICollectionViewFlowLayout!
    @IBOutlet weak var collectionView: UICollectionView!
    var selectedCell: OfferCollectionViewCell?
    let linkBag = LinkBag()
    var subscriber: FetchableCollectionViewSubscriber<Offer>!

    override func viewDidLoad() {
        super.viewDidLoad()

        layout = collectionView!.collectionViewLayout as! UICollectionViewFlowLayout //swiftlint:disable:this force_cast
        let itemWidth = view.frame.width - layout.sectionInset.left  - layout.sectionInset.right
        layout.itemSize = OfferCollectionViewCell.itemSize(for: itemWidth)

        collectionView!.register(nib: OfferCollectionViewCell.self)

        configureSubscriber()
        addBalanceLabel()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        logViewPage()
        collectionView.flashScrollIndicators()
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    func configureSubscriber() {
        subscriber = FetchableCollectionViewSubscriber<Offer>
            .init(collectionView: collectionView,
                  observable: KinLoader.shared.offers,
                  linkBag: linkBag,
                  itemsAvailabilityChanged: { [weak self] items, error in
                    self?.availabilityChanged(items: items, error: error)
            })
    }

    func availabilityChanged(items: [Offer]?, error: Error?) {
        childViewControllers.first?.remove()
        if items == nil {
            let offersUnavailableViewController = OffersUnavailableViewController()
            offersUnavailableViewController.error = error
            add(offersUnavailableViewController) { $0.fitInSuperview(with: .safeArea) }
        }

        if view.window != nil {
            logViewPage()
        }
    }
}

extension OfferWallViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) as? OfferCollectionViewCell else {
            fatalError("Couldn't get cell at OfferWallViewController collectionView:didSelecItemAtIndexPath:")
        }

        selectedCell = cell
        let offer = subscriber.items[indexPath.item]
        logTappedOffer(offer, index: indexPath.row)
        let navController = StoryboardScene.Spend.offerDetailsNavigationController.instantiate()
        guard let detailsViewController = navController.viewControllers.first as? OfferDetailsViewController else {
            fatalError("OfferDetailsNavigationController root vc should be OfferDetailsViewController")
        }
        navController.transitioningDelegate = self
        detailsViewController.offer = offer
        present(navController, animated: true)
    }
}

private extension UIView {
    func copyingProperties(from another: UIView) -> UIView {
        self.layer.cornerRadius = another.layer.cornerRadius
        self.contentMode = another.contentMode

        return self
    }
}

extension OfferWallViewController: UIViewControllerTransitioningDelegate {
    func animationController(forPresented presented: UIViewController,
                             presenting: UIViewController,
                             source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        guard let navController = presented as? UINavigationController,
            let offerViewController = navController.viewControllers.first as? OfferDetailsViewController,
            let cell = selectedCell,
            let offerImage = cell.offerImage,
            let authorImage = cell.authorImage else {
            return nil
        }

        _ = offerViewController.view
        let authorOriginFrame = cell.authorImageView.superview!.convert(cell.authorImageView.frame, to: view)
        var authorTargetFrame = offerViewController.authorImageView.frame
        if #available(iOS 11.0, *) {
            if navigationController!.view.safeAreaInsets.top > 20 {
                authorTargetFrame.origin.y += navigationController!.view.safeAreaInsets.top - 20
            }
        }

        let authorView = UIImageView(image: authorImage).copyingProperties(from: cell.authorImageView)
        let authorAnimationContext = AnimationContext(originView: cell.authorImageView,
                                                      targetView: offerViewController.authorImageView,
                                                      originFrame: authorOriginFrame,
                                                      targetFrame: authorTargetFrame,
                                                      view: authorView)

        let offerOriginFrame = cell.offerImageView.superview!.convert(cell.offerImageView.frame, to: view)
        var offerTargetFrame = offerViewController.offerImageView.frame
        if #available(iOS 11.0, *) {
            if navigationController!.view.safeAreaInsets.top > 20 {
                offerTargetFrame.origin.y += navigationController!.view.safeAreaInsets.top - 20
            }
        }

        let offerView = UIImageView(image: offerImage).copyingProperties(from: cell.offerImageView)
        let offerAnimationContext = AnimationContext(originView: cell.offerImageView,
                                                     targetView: offerViewController.offerImageView,
                                                     originFrame: offerOriginFrame,
                                                     targetFrame: offerTargetFrame,
                                                     view: offerView)

        return OfferTransitionAnimator(isPresenting: true,
                                       animationContexts: [offerAnimationContext, authorAnimationContext])
    }

    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        guard let navController = dismissed as? UINavigationController,
            let offerViewController = navController.viewControllers.first as? OfferDetailsViewController,
            let cell = selectedCell,
            let offerImage = cell.offerImage,
            let authorImage = cell.authorImage else {
                return nil
        }

        let authorOriginFrame = offerViewController.authorImageView.frame
        let authorTargetFrame = cell.authorImageView.superview!.convert(cell.authorImageView.frame, to: view)

        let authorView = UIImageView(image: authorImage).copyingProperties(from: offerViewController.authorImageView)
        let authorAnimationContext = AnimationContext(originView: offerViewController.authorImageView,
                                                      targetView: cell.authorImageView,
                                                      originFrame: authorOriginFrame,
                                                      targetFrame: authorTargetFrame,
                                                      view: authorView)

        let offerOriginFrame = offerViewController.offerImageView.frame
        let offerTargetFrame = cell.offerImageView.superview!.convert(cell.offerImageView.frame, to: view)

        let offerView = UIImageView(image: offerImage).copyingProperties(from: offerViewController.offerImageView)
        let offerAnimationContext = AnimationContext(originView: offerViewController.offerImageView,
                                                     targetView: cell.offerImageView,
                                                     originFrame: offerOriginFrame,
                                                     targetFrame: offerTargetFrame,
                                                     view: offerView)

        return OfferTransitionAnimator(isPresenting: false,
                                       animationContexts: [offerAnimationContext, authorAnimationContext])
    }
}

extension OfferWallViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return subscriber.items.count
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(forIndexPath: indexPath) as OfferCollectionViewCell
        cell.offer = subscriber.items[indexPath.item]

        return cell
    }
}

// MARK: Analytics
extension OfferWallViewController {
    func logViewPage() {
        switch KinLoader.shared.offers.value! {
        case .none(let error):
            if error != nil {
                Events.Analytics
                    .ViewErrorPage(errorType: .internetConnection)
                    .send()
            } else {
                Events.Analytics
                    .ViewEmptyStatePage(menuItemName: .earn)
                    .send()
            }
        case .some(let offers):
            Events.Analytics
                .ViewSpendPage(numberOfOffers: offers.count)
                .send()
        }
    }

    func logTappedOffer(_ offer: Offer, index: Int) {
        Events.Analytics
            .ClickOfferItemOnSpendPage(brandName: offer.author.name,
                                       kinPrice: Int(offer.price),
                                       numberOfOffers: subscriber.items.count,
                                       offerCategory: offer.domain,
                                       offerId: offer.identifier,
                                       offerName: offer.title,
                                       offerOrder: index,
                                       offerType: offer.type)
            .send()
    }
}

struct AnimationContext {
    let originView: UIView
    let targetView: UIView
    let originFrame: CGRect
    let targetFrame: CGRect
    let view: UIView
}

private class OfferTransitionAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    private let moveAnimationDuration: TimeInterval = 0.4
    private let delayBetweenMoves: TimeInterval = 0.07
    let isPresenting: Bool
    let animationContexts: [AnimationContext]

    init(isPresenting: Bool, animationContexts: [AnimationContext]) {
        assert(animationContexts.isNotEmpty)
        self.animationContexts = animationContexts
        self.isPresenting = isPresenting

        super.init()
    }

    public func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return moveAnimationDuration + (Double(animationContexts.count) * delayBetweenMoves)
    }

    public func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard
            let fromView = transitionContext.view(forKey: .from),
            let toView = transitionContext.view(forKey: .to) else {
                fatalError("Couldn't get from/to views in OfferTransitionAnimator")
        }

        animateTransition(fromView: fromView,
                          toView: toView,
                          transitionContext: transitionContext)
    }

    private func animateTransition(fromView: UIView,
                                   toView: UIView,
                                   transitionContext: UIViewControllerContextTransitioning) {
        let containerView = transitionContext.containerView
        containerView.addSubview(fromView)
        containerView.addSubview(toView)
        toView.alpha = 0

        animationContexts.forEach {
            ($0.view as? UIImageView)?.backgroundColor = .white
            $0.view.frame = $0.originFrame
            $0.view.clipsToBounds = true
            $0.originView.isHidden = true
            $0.targetView.isHidden = true
            containerView.addSubview($0.view)
        }

        UIView.animate(withDuration: transitionDuration(using: transitionContext), animations: {
            toView.alpha = 1
            fromView.alpha = 0
        }, completion: { finished in
            fromView.alpha = 1
            fromView.removeFromSuperview()
            transitionContext.completeTransition(finished)
        })

        animationContexts.enumerated().forEach { offset, animationContext in
            UIView.animate(withDuration: moveAnimationDuration,
                           delay: TimeInterval(offset) * delayBetweenMoves,
                           options: [],
                           animations: {
                animationContext.view.frame = animationContext.targetFrame
            }, completion: { _ in
                animationContext.view.removeFromSuperview()
                animationContext.originView.isHidden = false
                animationContext.targetView.isHidden = false
            })
        }
    }
}
