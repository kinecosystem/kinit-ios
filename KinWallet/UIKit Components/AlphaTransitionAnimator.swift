//
//  AlphaTransitionAnimator.swift
//  Kinit
//

import UIKit

class AlphaTransitionAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    let duration: TimeInterval

    init(duration: TimeInterval = 0.5) {
        self.duration = duration
    }

    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return duration
    }

    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard
            let fromView = transitionContext.view(forKey: .from),
            let toView = transitionContext.view(forKey: .to) else {
                return
        }

        let containerView = transitionContext.containerView
        containerView.insertSubview(toView, at: 0)

        UIView.animate(withDuration: transitionDuration(using: transitionContext), animations: {
            fromView.alpha = 0
        }, completion: { _ in
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        })
    }
}
