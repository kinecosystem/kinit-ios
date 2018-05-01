//
//  OfferWallViewController.swift
//  KinWallet
//
//  Copyright © 2018 KinFoundation. All rights reserved.
//

import UIKit
import KinUtil

class OfferWallViewController: UIViewController {
    fileprivate var layout: UICollectionViewFlowLayout!
    @IBOutlet weak var collectionView: UICollectionView!
    let linkBag = LinkBag()
    var subscriber: FetchableCollectionViewSubscriber<Offer>!

    override func viewDidLoad() {
        super.viewDidLoad()

        layout = collectionView!.collectionViewLayout as! UICollectionViewFlowLayout //swiftlint:disable:this force_cast
        let itemWidth = view.frame.width - layout.sectionInset.left  - layout.sectionInset.right
        layout.itemSize = OfferCollectionViewCell.itemSize(for: itemWidth)

        collectionView!.register(nib: SimpleCollectionReusableView.self)
        collectionView!.register(nib: OfferCollectionViewCell.self)

        configureSubscriber()
        addBalanceLabel()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        logViewPage()
        collectionView.flashScrollIndicators()
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
        let offer = subscriber.items[indexPath.item]
        logTappedOffer(offer, index: indexPath.row)
        let navigationController = StoryboardScene.Spend.offerDetailsNavigationController.instantiate()
        guard let viewController = navigationController.viewControllers.first as? OfferDetailsViewController else {
            fatalError("OfferDetailsNavigationController root vc should be OfferDetailsViewController")
        }
        viewController.offer = offer
        present(navigationController, animated: true)
    }
}

extension OfferWallViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return subscriber.items.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(forIndexPath: indexPath) as OfferCollectionViewCell
        cell.offer = subscriber.items[indexPath.item]

        return cell
    }

    //swiftlint:disable:next line_length
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header = collectionView
            .dequeueReusableView(ofKind: kind, forIndexPath: indexPath) as SimpleCollectionReusableView
        header.textLabel.text = "Spend your Kin"

        return header
    }
}

extension OfferWallViewController: UICollectionViewDelegateFlowLayout {
    //swiftlint:disable:next line_length
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        if subscriber.items.isEmpty {
            return .zero
        }

        return CGSize(width: collectionView.frame.width, height: 50)
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
