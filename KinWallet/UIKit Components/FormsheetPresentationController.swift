//
//  FormsheetPresentationController.swift
//  KinWallet
//
//  Copyright © 2018 KinFoundation. All rights reserved.
//

import UIKit

class FormsheetPresentationController: UIPresentationController {
    let dimmingView = UIView()
    var allowsBackrgoundTapToDismiss = false

    override init(presentedViewController: UIViewController,
                  presenting presentingViewController: UIViewController?) {
        super.init(presentedViewController: presentedViewController,
                   presenting: presentingViewController)

        setupDimmingView()
    }

    func setupDimmingView() {
        let tapRecognizer = UITapGestureRecognizer(target: self,
                                                   action: #selector(dimmingViewTapped(_:)))
        dimmingView.addGestureRecognizer(tapRecognizer)
        dimmingView.backgroundColor = UIColor(red: 56, green: 64, blue: 85).withAlphaComponent(0.8)
    }

    @objc func dimmingViewTapped(_ tapRecognizer: UITapGestureRecognizer) {
        if allowsBackrgoundTapToDismiss {
            presentingViewController.dismiss(animated: true, completion: nil)
        }
    }

    override func presentationTransitionWillBegin() {
        guard let containerView = self.containerView else {
            return
        }

        presentedView?.layer.cornerRadius = 8
        presentedView?.layer.masksToBounds = true
        dimmingView.frame = containerView.bounds
        dimmingView.alpha = 0.0

        containerView.insertSubview(dimmingView, at: 0)

        presentedViewController.transitionCoordinator?.animate(alongsideTransition: { _ in
            self.dimmingView.alpha = 1.0
        }, completion: nil)
    }

    override func dismissalTransitionWillBegin() {
        presentedViewController.transitionCoordinator?.animate(alongsideTransition: { _ in
            self.dimmingView.alpha = 0.0
        }, completion: nil)
    }

    override func containerViewWillLayoutSubviews() {
        guard let containerView = containerView else {
            return
        }

        dimmingView.frame = containerView.bounds
        presentedView?.frame = frameOfPresentedViewInContainerView
    }

    override func size(forChildContentContainer container: UIContentContainer,
                       withParentContainerSize parentSize: CGSize) -> CGSize {
        return presentedViewController.preferredContentSize
    }

    override var frameOfPresentedViewInContainerView: CGRect {
        var presentedViewFrame = CGRect.zero

        guard let containerBounds = containerView?.bounds else {
            return presentedViewFrame
        }

        let presentedViewFrameSize = size(forChildContentContainer: presentedViewController,
                                          withParentContainerSize: containerBounds.size)
        presentedViewFrame.size = presentedViewFrameSize
        presentedViewFrame.origin.x = (containerBounds.width - presentedViewFrameSize.width) / 2
        presentedViewFrame.origin.y = (containerBounds.height - presentedViewFrameSize.height) / 2

        return presentedViewFrame
    }
}
