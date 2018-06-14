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
            title = noInternetTitle
            subtitle = noInternetSubtitle
            image = noInternetImage
        } else {
            title = "No offers at the moment"
            subtitle = "We are hand-picking the best for you!"
            image = Asset.noOffers.image
        }

        addNoticeViewController(with: title,
                                subtitle: subtitle,
                                image: image)
    }
}
