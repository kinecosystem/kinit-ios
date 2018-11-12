//
//  StandardOfferActionViewController.swift
//  Kinit
//

import UIKit

class SpendOfferActionViewController: UIViewController {
    weak var offerViewController: OfferDetailsViewController?
    var offer: Offer!
}

class StandardOfferActionViewController: SpendOfferActionViewController {
    var redeemGood: RedeemGood?

    @IBOutlet weak var buyActivityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var exportCodeView: UIView!
    @IBOutlet weak var exportButton: UIButton! {
        didSet {
            exportButton.titleLabel?.font = FontFamily.Roboto.regular.font(size: 14)
            exportButton.setTitle(nil, for: .normal)
            exportButton.setTitleColor(UIColor.kin.darkGray, for: .normal)
        }
    }

    @IBOutlet weak var priceLabel: KinAmountLabel! {
        didSet {
            priceLabel.textColor = UIColor.kin.blue
        }
    }

    @IBOutlet weak var buyButton: UIButton! {
        didSet {
            buyButton.makeKinButtonFilled()
            buyButton.setTitle(L10n.buy, for: .normal)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        if offer.shouldDisplayPrice() {
            priceLabel.amount = UInt64(offer.price)
            buyButton.isEnabled = Kin.shared.balance >= offer.price
        }
    }
}

extension StandardOfferActionViewController {
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
                    aSelf.presentErrorAlert(title: L10n.NoInternetError.title,
                                            message: L10n.NoInternetError.message,
                                            errorType: .internetConnection)
                    return
                }

                switch bookOfferResult {
                case .success(let orderId):
                    aSelf.payOffer(with: orderId)
                case .noGoods, .coolDown:
                    DataLoaders.kinit.loadOffers()
                    aSelf.presentErrorAlert(title: L10n.lastOfferGrabbedTitle,
                                            message: L10n.lastOfferGrabbedMessage,
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
                aSelf.presentErrorAlert(title: L10n.lastOfferGrabbedTitle,
                                        message: L10n.lastOfferGrabbedMessage,
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

                DataLoaders.kinit.loadTransactions()
                DataLoaders.kinit.loadRedeemedItems()

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
        transition(to: exportCodeView) { [weak self] in
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3, execute: { [weak self] in
                self?.offerViewController?.showToast(with: L10n.couponCodeSaved)
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

    func transition(to newView: UIView, completion: (() -> Void)? = nil) {
        guard let currentView = view.subviews.first else {
            return
        }

        view.addAndFit(newView)
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
private extension StandardOfferActionViewController {
    func presentIncompleteTransactionAlert() {
        presentErrorAlert(title: L10n.transactionIncompleteTitle,
                          message: L10n.transactionIncompleteMessage,
                          errorType: .codeNotProvided)
    }

    func presentErrorAlert(title: String, message: String, errorType: Events.ErrorType) {
        DispatchQueue.main.async {
            let alertController = UIAlertController(title: title,
                                                    message: message,
                                                    preferredStyle: .alert)
            alertController.addAction(title: L10n.backToSpendAction, style: .default) {
                Events.Analytics
                    .ClickOkButtonOnErrorPopup(errorType: errorType)
                    .send()
                self.offerViewController?.dismiss()
            }

            self.present(alertController, animated: true)
        }

        Events.Analytics
            .ViewErrorPopupOnOfferPage(errorType: errorType)
            .send()
    }
}

// MARK: Analytics
extension SpendOfferActionViewController {
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
}

fileprivate extension StandardOfferActionViewController {
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
        Events.Analytics
            .ClickShareButtonOnOfferPage(brandName: offer.author.name,
                                         kinPrice: Int(offer.price),
                                         offerCategory: offer.domain,
                                         offerId: offer.identifier,
                                         offerName: offer.title,
                                         offerType: offer.type)
            .send()
    }
}
