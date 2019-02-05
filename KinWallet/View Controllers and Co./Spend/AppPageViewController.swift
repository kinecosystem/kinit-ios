//
//  EcosystemAppViewController.swift
//  KinWallet
//
//  Copyright © 2018 KinFoundation. All rights reserved.
//

import UIKit
import MoveKin

private enum AppPageRow: Int {
    case headerImages = 0
    case iconNameAndGetButton
    case sendKinNotAvailable
    case about
    case kinUsage
}

extension AppPageRow: CaseIterable {}

extension AppPageRow {
    static func from(_ indexPath: IndexPath) -> AppPageRow {
        guard let row = AppPageRow(rawValue: indexPath.row) else {
            fatalError("Could not init AppPageRow enum from indexPath with row \(indexPath.row)")
        }

        return row
    }

    var height: CGFloat {
        switch self {
        case .about, .kinUsage, .iconNameAndGetButton: return UITableView.automaticDimension
        case .headerImages: return UIScreen.main.bounds.width * 7/6
        case .sendKinNotAvailable: return 66
        }
    }
}

class AppPageViewController: UIViewController {
    let appDiscoveryAction = AppDiscoveryAction(moveKinFlow: AppDelegate.shared.moveKinFlow)
    var app: EcosystemApp!
    var appCategoryName: String!

    let titleImageView: UIImageView = {
        let iv = UIImageView()
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.heightAnchor.constraint(equalToConstant: 34).isActive = true
        iv.widthAnchor.constraint(equalToConstant: 34).isActive = true

        return iv
    }()

    let actionButton: UIButton = {
        let b = UIButton(type: .system)
        b.widthAnchor.constraint(equalToConstant: 72).isActive = true

        return b
    }()

    let tableView: UITableView = {
        let tv = UITableView()
        tv.allowsSelection = false
        tv.separatorStyle = .none

        for row in AppPageRow.allCases {
            switch row {
            case .headerImages: tv.register(class: AppPageImagesHeaderTableViewCell.self)
            case .iconNameAndGetButton: tv.register(nib: AppBasicInfoTableViewCell.self)
            case .sendKinNotAvailable: tv.register(class: SendKinToAppUnavailableTableViewCell.self)
            case .about, .kinUsage: tv.register(class: EcosystemAppTextCell.self)
            }
        }

        tv.register(class: UITableViewCell.self)
        tv.tableFooterView = UIView()
        tv.translatesAutoresizingMaskIntoConstraints = false

        return tv
    }()

    override func loadView() {
        let v = UIView()
        v.addAndFit(tableView)
        tableView.dataSource = self
        tableView.delegate = self

        titleImageView.alpha = 0
        actionButton.alpha = 0
        actionButton.addTarget(self, action: #selector(performAppAction), for: .touchUpInside)

        self.view = v
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.titleView = titleImageView
        titleImageView.loadImage(url: app.metadata.iconURL.kinImagePathAdjustedForDevice())
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: actionButton)
        navigationItem.rightBarButtonItem?.tintColor = UIColor.kin.appTint

        let xImage = Asset.closeXButtonDarkGray.image
            .withRenderingMode(.alwaysOriginal)
        let closeBarButtonItem = UIBarButtonItem(image: xImage,
                                                 style: .plain,
                                                 target: self,
                                                 action: #selector(dismissTapped))
        navigationItem.leftBarButtonItem = closeBarButtonItem

        let actionButtonHeight = AppBasicInfoTableViewCell.actionButtonHeight

        if app.isTransferAvailable {
            actionButton.makeKinButtonFilled(height: actionButtonHeight)
            actionButton.tintColor = .white
            actionButton.setTitle(L10n.sendKinActionShort, for: .normal)
        } else {
            actionButton.setTitle(L10n.getAppShort, for: .normal)
            actionButton.makeKinButtonOutlined(height: actionButtonHeight,
                                               borderWidth: 2,
                                               borderColor: UIColor.kin.appTint)
            actionButton.tintColor = UIColor.kin.appTint
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        Events.Analytics
            .ViewAppPage(appCategory: appCategoryName,
                         appId: app.bundleId,
                         appName: app.name,
                         transferReady: false)
            .send()
    }

    @objc func dismissTapped() {
        dismissAnimated()
    }

    @objc fileprivate func performAppAction() {
        appDiscoveryAction.performAppAction(for: app)

        let event: BIEvent
        if app.isTransferAvailable {
            event = Events.Analytics
                .ClickSendButtonOnAppPage(appCategory: appCategoryName,
                                         appId: app.bundleId,
                                         appName: app.name,
                                         transferReady: false)
        } else {
            event = Events.Analytics
                .ClickGetButtonOnAppPage(appCategory: appCategoryName,
                                         appId: app.bundleId,
                                         appName: app.name,
                                         transferReady: false)
        }

        event.send()
    }
}

extension AppPageViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return AppPageRow.allCases.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell

        switch AppPageRow.from(indexPath) {
        case .headerImages:
            let c: AppPageImagesHeaderTableViewCell = tableView.dequeueReusableCell(forIndexPath: indexPath)
            c.imageURLs = [app.metadata.imageURL, app.metadata.imageURL1, app.metadata.imageURL2]
                .compactMap { return $0?.kinImagePathAdjustedForDevice() }
            cell = c
        case .iconNameAndGetButton:
            let c: AppBasicInfoTableViewCell = tableView.dequeueReusableCell(forIndexPath: indexPath)
            c.delegate = self
            c.drawAppInformation(app, category: appCategoryName, short: true)
            cell = c
        case .sendKinNotAvailable:
            let c: SendKinToAppUnavailableTableViewCell = tableView.dequeueReusableCell(forIndexPath: indexPath)
            return c
        case .about:
            let c: EcosystemAppTextCell = tableView.dequeueReusableCell(forIndexPath: indexPath)
            c.textLabel?.text = L10n.AppPage.aboutApp(app.name)
            c.detailTextLabel?.text = app.metadata.description
            cell = c
        case .kinUsage:
            let c: EcosystemAppTextCell = tableView.dequeueReusableCell(forIndexPath: indexPath)
            c.textLabel?.text = L10n.AppPage.kinUsage
            c.detailTextLabel?.text = app.metadata.kinUsage
            cell = c
        }

        return cell
    }
}

extension AppPageViewController: UITableViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard let cell = tableView.cellForRow(at: IndexPath(row: AppPageRow.iconNameAndGetButton.rawValue, section: 0))
            as? AppBasicInfoTableViewCell,
            let cellActionButton = cell.actionButton else {
                return
        }

        let frame = cellActionButton.superview!.convert(cellActionButton.frame, to: view)

        let originY: CGFloat
        if #available(iOS 11.0, *) {
            originY = frame.minY - scrollView.adjustedContentInset.top
        } else {
            originY = frame.minY - scrollView.contentInset.top
        }
        let percent = 1 - (frame.height + originY)/frame.height
        let desiredAlpha = min(max(percent, 0), 1)

        actionButton.alpha = desiredAlpha
        titleImageView.alpha = desiredAlpha
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return AppPageRow.from(indexPath).height
    }
}

extension AppPageViewController: AppBasicInfoDelegate {
    func appBasicInfoCellDidTapAction(_ cell: AppBasicInfoTableViewCell) {
        performAppAction()
    }
}
