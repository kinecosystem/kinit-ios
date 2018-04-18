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
    var requiresUserExport = false
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
        guard !requiresUserExport else {
            FeedbackGenerator.notifyWarningIfAvailable()
            alertCodeIsEphemeral()

            return
        }

        dismiss(animated: true)
    }

    func alertCodeIsEphemeral() {
        let message =
        """
        This code will only appear once.
        Copy and paste it somewhere safe.
        """

        let alertController = UIAlertController(title: "Don’t leave without your code!",
                                                message: message,
                                                preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Ok, I'll save it",
                                     style: .default, handler: nil)
        alertController.addAction(okAction)
        present(alertController, animated: true)
        requiresUserExport = false
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
}

extension OfferDetailsViewController {
    @IBAction func buyTapped(_ sender: Any) {
        logTappedBuy()

        buyButton.isUserInteractionEnabled = false
        buyButton.setTitle(nil, for: .normal)
        buyActivityIndicator.startAnimating()

        KinWebService.shared.load(WebRequests
            .bookOffer(offer)
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
        })
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
        let redeemRequest = WebRequests
            .redeemOffer(with: receipt)
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
        }

        KinWebService.shared.load(redeemRequest)
    }

    private func offerRedeemed(with redeemGood: RedeemGood) {
        self.redeemGood = redeemGood
        FeedbackGenerator.notifySuccessIfAvailable()
        requiresUserExport = true
        exportButton.setTitle(redeemGood.value, for: .normal)
        buyActivityIndicator.stopAnimating()
        transitionBottomView(to: exportCodeView)
        logViewedCode()
    }

    @IBAction func exportTapped(_ sender: Any) {
        guard let redeemGood = redeemGood else {
            return
        }

        requiresUserExport = false
        logTappedShare()

        let activityViewController = UIActivityViewController(activityItems: [redeemGood.value],
                                                              applicationActivities: nil)
        present(activityViewController, animated: true)
    }

    func transitionBottomView(to newView: UIView) {
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
                                            Analytics.logEvent(Events.Analytics.ClickOkButtonOnErrorPopup(errorType: errorType))
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
