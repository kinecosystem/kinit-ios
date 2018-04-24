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
    var offer: Offer!
    var redeemGood: RedeemGood?

    @IBOutlet weak var buyView: UIView!
    @IBOutlet weak var offerTypeImageView: UIImageView!
    @IBOutlet weak var buyActivityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var priceLabel: KinAmountLabel! {
        didSet {
            priceLabel.textColor = UIColor.kin.blue
        }
    }

    @IBOutlet weak var buyButton: UIButton! {
        didSet {
            buyButton.makeKinButtonFilled()
        }
    }

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

    @IBOutlet weak var exportCodeView: UIView!
    @IBOutlet weak var exportButton: UIButton! {
        didSet {
            exportButton.titleLabel?.font = FontFamily.Roboto.regular.font(size: 14)
            exportButton.setTitle(nil, for: .normal)
            exportButton.setTitleColor(UIColor.kin.darkGray, for: .normal)
        }
    }

    @IBOutlet weak var offerImageView: UIImageView!
    @IBOutlet weak var authorImageView: UIImageView! {
        didSet {
            authorImageView.layer.cornerRadius = 8
        }
    }

    @IBOutlet weak var bottomView: UIView! {
        didSet {
            bottomView.applyThinShadow()
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

        setupNavigationBar()
        drawOffer()
        bottomView.addAndFit(buyView)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        logViewedPage()
    }

    func setupNavigationBar() {
        navigationController?.navigationBar.setBackgroundImage(.from(.white), for: .default)
        let xImage = Asset.closeXButtonDarkGray.image
            .withRenderingMode(.alwaysOriginal)
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: xImage,
                                                           style: .plain,
                                                           target: self,
                                                           action: #selector(dismissTapped(_:)))
    }

    @IBAction func dismissTapped(_ sender: UIBarButtonItem) {
        dismiss(animated: true)
    }

    func drawOffer() {
        offerImageView.loadImage(url: offer.imageURL.kinImagePathAdjustedForDevice(),
                                 placeholderImage: Asset.patternPlaceholder.image)
        authorImageView.loadImage(url: offer.author.imageURL.kinImagePathAdjustedForDevice(),
                                  placeholderColor: UIColor.kin.extraLightGray)
        offerTypeImageView.loadImage(url: offer.typeImageUrl)

        titleLabel.text = offer.title
        descriptionLabel.text = offer.description
        priceLabel.amount = UInt64(offer.price)

        buyButton.isEnabled = Kin.shared.balance >= offer.price
    }

    fileprivate func showToast() {
        guard let toastView = toastView else {
            return
        }

        view.addSubview(toastView)
        toastView.translatesAutoresizingMaskIntoConstraints = false
        toastView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        let finalTopConstraint = toastView.topAnchor.constraint(equalTo: bottomView.topAnchor)
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
    @IBAction func buyTapped(_ sender: Any) {
        logTappedBuy()

        buyButton.isUserInteractionEnabled = false
        buyButton.setTitle(nil, for: .normal)
        buyActivityIndicator.startAnimating()

        WebRequests.bookOffer(offer)
            .withCompletion { [weak self] bookOfferResult, error in
                guard let aSelf = self else {
                    return
                }

                guard let bookOfferResult = bookOfferResult, error == nil else {
                    aSelf.presentErrorAlert(title: internetErrorTitle,
                                            message: internetErrorMessage,
                                            errorType: .internetConnection)
                    return
                }

                switch bookOfferResult {
                case .success(let orderId):
                    aSelf.payOffer(with: orderId)
                case .noGoods, .coolDown:
                    KinLoader.shared.loadOffers()
                    aSelf.presentErrorAlert(title: lastOfferGrabbedTitle,
                                            message: lastOfferGrabbedMessage,
                                            errorType: .offerNotAvailable)
                }
            }.load(with: KinWebService.shared)
    }

    private func payOffer(with orderId: String) {
        Kin.shared.send(offer.price, to: offer.address, memo: orderId) { [weak self] txHash, error in
            guard let aSelf = self else {
                return
            }

            guard let txHash = txHash else {
                KLogError("Error sending to address \(String(describing: error))")
                aSelf.presentErrorAlert(title: lastOfferGrabbedTitle,
                                        message: lastOfferGrabbedMessage,
                                        errorType: .offerNotAvailable)
                return
            }

            KLogVerbose("Transaction successful. TxHash: \(txHash)")
            aSelf.redeemOffer(with: txHash)
        }
    }

    private func redeemOffer(with txHash: String) {
        let receipt = PaymentReceipt(txHash: txHash)
        WebRequests.redeemOffer(with: receipt)
            .withCompletion { [weak self] goods, error in
                guard let aSelf = self else {
                    return
                }
                
                guard let redeemGood = goods?.first else {
                    KLogError("Error redeeming goods \(String(describing: error))")
                    aSelf.presentIncompleteTransactionAlert()
                    return
                }
                
                KinLoader.shared.loadTransactions()
                KinLoader.shared.loadRedeemedItems()
                
                DispatchQueue.main.async {
                    aSelf.offerRedeemed(with: redeemGood)
                }
            }.load(with: KinWebService.shared)
    }

    private func offerRedeemed(with redeemGood: RedeemGood) {
        self.redeemGood = redeemGood
        FeedbackGenerator.notifySuccessIfAvailable()
        exportButton.setTitle(redeemGood.value, for: .normal)
        buyActivityIndicator.stopAnimating()
        transitionBottomView(to: exportCodeView) { [weak self] in
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3, execute: { [weak self] in
                self?.showToast()
            })
        }
        logViewedCode()
    }

    @IBAction func exportTapped(_ sender: Any) {
        guard let redeemGood = redeemGood else {
            return
        }

        logTappedShare()

        let activityViewController = UIActivityViewController(activityItems: [redeemGood.value],
                                                              applicationActivities: nil)
        present(activityViewController, animated: true)
    }

    func transitionBottomView(to newView: UIView, completion: (() -> Void)? = nil) {
        guard let currentView = bottomView.subviews.first else {
            return
        }

        bottomView.addAndFit(newView)
        newView.transform = CGAffineTransform(translationX: newView.frame.width, y: 0)

        UIView.animate(withDuration: 0.4,
                       delay: 0,
                       usingSpringWithDamping: 0.8,
                       initialSpringVelocity: 0.7,
                       options: .curveEaseInOut,
                       animations: {
                        newView.transform = .identity
                        currentView.transform = CGAffineTransform(translationX: -currentView.frame.width, y: 0)
        }, completion: { _ in
            currentView.removeFromSuperview()
            completion?()
        })
    }
}

// MARK: Error handling
private extension OfferDetailsViewController {
    func presentIncompleteTransactionAlert() {
        let message =
        """
        Your reflected balance may not be correct.
        Please contact support to resolve this issue.
        """
        presentErrorAlert(title: "Oops! Transaction incomplete",
                          message: message,
                          errorType: .codeNotProvided)
    }

    func presentErrorAlert(title: String, message: String, errorType: Events.ErrorType) {
        Analytics.logEvent(Events.Analytics.ViewErrorPopupOnOfferPage(errorType: errorType))

        let alertController = UIAlertController(title: title,
                                                message: message,
                                                preferredStyle: .alert)
        alertController.addAction(.init(title: "Back to Spend",
                                        style: .default,
                                        handler: { _ in
                                            let event = Events.Analytics.ClickOkButtonOnErrorPopup(errorType: errorType)
                                            Analytics.logEvent(event)
                                            self.dismiss(animated: true)
        }))
        present(alertController, animated: true)
    }
}

// MARK: Analytics
extension OfferDetailsViewController {
    func logViewedPage() {
        let event = Events.Analytics
            .ViewOfferPage(brandName: offer.author.name,
                           kinPrice: Int(offer.price),
                           offerCategory: offer.domain,
                           offerId: offer.identifier,
                           offerName: offer.title,
                           offerType: offer.type)
        Analytics.logEvent(event)
    }

    func logTappedBuy() {
        let aEvent = Events.Analytics
            .ClickBuyButtonOnOfferPage(brandName: offer.author.name,
                                       kinPrice: Int(offer.price),
                                       offerCategory: offer.domain,
                                       offerId: offer.identifier,
                                       offerName: offer.title,
                                       offerType: offer.type)

        let bEvent = Events.Business
            .SpendingOfferRequested(brandName: offer.author.name,
                                    kinPrice: Int(offer.price),
                                    offerCategory: offer.domain,
                                    offerId: offer.identifier,
                                    offerName: offer.title,
                                    offerType: offer.type)

        Analytics.logEvents(aEvent, bEvent)
    }

    func logViewedCode() {
        let aEvent = Events.Analytics
            .ViewCodeTextOnOfferPage(brandName: offer.author.name,
                                     kinPrice: Int(offer.price),
                                     offerCategory: offer.domain,
                                     offerId: offer.identifier,
                                     offerName: offer.title,
                                     offerType: offer.type)

        let bEvent = Events.Business
            .SpendingOfferProvided(brandName: offer.author.name,
                                   kinPrice: Int(offer.price),
                                   offerCategory: offer.domain,
                                   offerId: offer.identifier,
                                   offerName: offer.title,
                                   offerType: offer.type)
        Analytics.logEvents(aEvent, bEvent)
    }

    func logTappedShare() {
        let event = Events.Analytics
            .ClickShareButtonOnOfferPage(brandName: offer.author.name,
                                         kinPrice: Int(offer.price),
                                         offerCategory: offer.domain,
                                         offerId: offer.identifier,
                                         offerName: offer.title,
                                         offerType: offer.type)
        Analytics.logEvent(event)
    }
}
