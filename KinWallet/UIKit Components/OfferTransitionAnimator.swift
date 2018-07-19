//
//  OfferTransitionAnimator.swift
//  KinWallet
//
//  Copyright © 2018 KinFoundation. All rights reserved.
//

import UIKit

struct AnimationContext<T: UIView> {
    let originView: UIView
    let targetView: UIView
    let originFrame: CGRect
    let targetFrame: CGRect
    let view: T
    var beforeAnimationBlock: ((T) -> Void)?
    var insideAnimationBlock: ((T) -> Void)?

    init(originView: UIView,
         targetView: UIView,
         originFrame: CGRect,
         targetFrame: CGRect,
         view: T,
         beforeAnimationBlock: ((T) -> Void)? = nil,
         insideAnimationBlock: ((T) -> Void)? = nil) {
        self.originView = originView
        self.targetView = targetView
        self.originFrame = originFrame
        self.targetFrame = targetFrame
        self.view = view
        self.beforeAnimationBlock = beforeAnimationBlock
        self.insideAnimationBlock = insideAnimationBlock
    }
}

class OfferTransitionAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    private let moveAnimationDuration: TimeInterval = 5
    private let delayBetweenMoves: TimeInterval = 0.07
    let isPresenting: Bool
    let animationContexts: [AnimationContext<UIView>]

    init(isPresenting: Bool, animationContexts: [AnimationContext<UIView>]) {
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
            $0.originView.addAndFit({
                let v = UIView()
                v.backgroundColor = .white
                return v
                }())

            $0.targetView.addAndFit({
                let v = UIView()
                v.backgroundColor = .white
                return v
                }())

            $0.beforeAnimationBlock?($0.view)
            containerView.addSubview($0.view)
        }

        UIView.animate(withDuration: transitionDuration(using: transitionContext), animations: {
            toView.alpha = 1
            fromView.alpha = 0
        }, completion: { _ in
            let completed = !transitionContext.transitionWasCancelled
            transitionContext.completeTransition(completed)

            if !transitionContext.transitionWasCancelled {
                fromView.alpha = 1
                fromView.removeFromSuperview()
            }
        })

        animationContexts.enumerated().forEach { (arg) in
            let (offset, animationContext) = arg
            UIView.animate(withDuration: moveAnimationDuration,
                           delay: TimeInterval(offset) * delayBetweenMoves,
                           options: [],
                           animations: {
                            animationContext.view.frame = animationContext.targetFrame
                            animationContext.insideAnimationBlock?(animationContext.view)
            }, completion: { _ in
                animationContext.view.removeFromSuperview()
                animationContext.originView.subviews.last?.removeFromSuperview()
                animationContext.targetView.subviews.last?.removeFromSuperview()
            })
        }
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

        let authorView = UIImageView(image: authorImage)
            .copyingProperties(from: cell.authorImageView)
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

        let offerView = UIImageView(image: offerImage)
            .copyingProperties(from: cell.offerImageView)
        let offerAnimationContext = AnimationContext(originView: cell.offerImageView,
                                                     targetView: offerViewController.offerImageView,
                                                     originFrame: offerOriginFrame,
                                                     targetFrame: offerTargetFrame,
                                                     view: offerView,
                                                     beforeAnimationBlock: { aView in
            if #available(iOS 11.0, *) {
                aView.layer.cornerRadius = 8
                aView.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
            }
        }, insideAnimationBlock: { aView in
            aView.layer.cornerRadius = 0
        })

        let contexts = [offerAnimationContext, authorAnimationContext]
        return OfferTransitionAnimator(isPresenting: true,
                                       animationContexts: contexts)
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

        let authorView = UIImageView(image: authorImage)
            .copyingProperties(from: offerViewController.authorImageView)
        let authorAnimationContext = AnimationContext(originView: offerViewController.authorImageView,
                                                      targetView: cell.authorImageView,
                                                      originFrame: authorOriginFrame,
                                                      targetFrame: authorTargetFrame,
                                                      view: authorView)

        let offerOriginFrame = offerViewController.offerImageView.frame
        let offerTargetFrame = cell.offerImageView.superview!.convert(cell.offerImageView.frame, to: view)

        let offerView = UIImageView(image: offerImage)
            .copyingProperties(from: offerViewController.offerImageView)
        let offerAnimationContext = AnimationContext(originView: offerViewController.offerImageView,
                                                     targetView: cell.offerImageView,
                                                     originFrame: offerOriginFrame,
                                                     targetFrame: offerTargetFrame,
                                                     view: offerView, insideAnimationBlock: { aView in
            if #available(iOS 11.0, *) {
                aView.layer.cornerRadius = 8
                aView.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
            }
        })

        return OfferTransitionAnimator(isPresenting: false,
                                       animationContexts: [offerAnimationContext, authorAnimationContext])
    }

    func interactionControllerForDismissal(using
        animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        guard
            let navController = presentedViewController as? UINavigationController,
            let offerDetailsViewController = navController.viewControllers.first as? OfferDetailsViewController else {
                return nil
        }

        return offerDetailsViewController.interactiveDismissal
    }
}
