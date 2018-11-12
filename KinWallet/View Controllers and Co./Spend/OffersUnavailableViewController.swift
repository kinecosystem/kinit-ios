//
//  OffersUnavailableViewController.swift
//  Kinit
//

import UIKit

class OffersUnavailableViewController: UIViewController, AddNoticeViewController {
    var error: Error?

    override func viewDidLoad() {
        super.viewDidLoad()

        let noticeContent: NoticeContent

        if let error = error {
            noticeContent = .fromError(error)
        } else {
            noticeContent = .init(title: L10n.emptyOffersTitle,
                                  message: L10n.emptyOffersSubtitle,
                                  image: Asset.noOffers.image)
        }

        addNoticeViewController(with: noticeContent)
    }
}
