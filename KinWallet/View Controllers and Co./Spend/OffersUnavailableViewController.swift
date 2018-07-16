//
//  OffersUnavailableViewController.swift
//  Kinit
//

import UIKit

class OffersUnavailableViewController: UIViewController, AddNoticeViewController {
    var error: Error?

    override func viewDidLoad() {
        super.viewDidLoad()

        let title: String
        let subtitle: String?
        let image: UIImage

        if error != nil {
            title = L10n.internetErrorTitle
            subtitle = L10n.internetErrorMessage
            image = noInternetImage
        } else {
            title = L10n.emptyOffersTitle
            subtitle = L10n.emptyOffersSubtitle
            image = Asset.noOffers.image
        }

        addNoticeViewController(with: title,
                                subtitle: subtitle,
                                image: image)
    }
}
