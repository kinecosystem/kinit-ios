//
//  OfferDetailsViewController.swift
//  KinWallet
//
//  Copyright © 2018 KinFoundation. All rights reserved.
//

import UIKit

let lastOfferGrabbedTitle = "Oops! Someone grabbed the last one"
let lastOfferGrabbedMessage = "Please try again later"
let internetErrorTitle = "Oh no! Your internet is MIA"
let internetErrorMessage = "Please check your internet connection and try again."

class OfferDetailsViewController: UIViewController {
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
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        logViewedPage()
    }

    @IBAction func dismissTapped(_ sender: UIBarButtonItem) {
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
