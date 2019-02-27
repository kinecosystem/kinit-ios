//
//  AppDiscoveryViewController.swift
//  KinWallet
//
//  Copyright © 2018 KinFoundation. All rights reserved.
//

import UIKit
import KinUtil
import MoveKin

private let shownAppDiscoveryIntroKey = "org.kinfoundation.kinwallet.shownAppDiscoveryIntro"
private let shownEcosystemMoveKinIntroKey = "org.kinfoundation.kinwallet.shownEcosystemMoveKinIntro"

private enum AppDiscoveryTableSections: Int {
    case intro = 0
    case categories
    case footer
}

extension AppDiscoveryTableSections {
    var rowHeight: CGFloat {
        switch self {
        case .intro: return 120
        case .categories: return 340
        case .footer:
            let scale: CGFloat = 0.6
            let width = UIScreen.main.bounds.width * scale
            return min(width, 230)
        }
    }
}

extension AppDiscoveryTableSections: CaseIterable {}

class AppDiscoveryViewController: UIViewController {
    let linkBag = LinkBag()
    let appDiscoveryAction = AppDiscoveryAction(moveKinFlow: AppDelegate.shared.moveKinFlow)

    var categories: [EcosystemAppCategory]?

    let tableView: UITableView = {
        let t = UITableView()
        t.tableFooterView = UIView()
        t.separatorStyle = .none
        t.register(class: EcosystemIntroTableViewCell.self)
        t.register(class: EcosystemAppCategoryTableViewCell.self)
        t.register(nib: EcosystemFooterTableViewCell.self)
        t.translatesAutoresizingMaskIntoConstraints = false

        return t
    }()

    var isTransferAvailable: Bool {
        let transferAvailableApp = DataLoaders.kinit.ecosystemAppCategories
            .value?
            .value?
            .flatMap { $0.apps }
            .first(where: { $0.isTransferAvailable })

        return transferAvailableApp != nil
    }

    override func loadView() {
        let v = UIView()
        tableView.dataSource = self
        tableView.delegate = self
        v.addAndFit(tableView)

        self.view = v
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        DataLoaders.kinit.ecosystemAppCategories
            .on(queue: .main, next: render)
            .add(to: linkBag)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        showIntroPopupIfNeeded()

        Events.Analytics.ViewExplorePage().send()
    }

    private func render(result: FetchResult<[EcosystemAppCategory]>) {
        switch result {
        case .none(let error):
            if categories.isNilOrEmpty {
                renderEmpty(error)
            }
        case .some(let categories): renderCategories(categories)
        }
    }

    private func renderCategories(_ categories: [EcosystemAppCategory]) {
        children
            .compactMap { $0 as? NoticeViewController }
            .forEach { $0.remove() }
        self.categories = categories
        tableView.reloadData()
    }

    private func showIntroPopupIfNeeded() {
        guard
            UserDefaults.standard.bool(forKey: shownAppDiscoveryIntroKey) == false
                || UserDefaults.standard.bool(forKey: shownEcosystemMoveKinIntroKey) == false else {
                    return
        }

        if isTransferAvailable {
            showMoveKinIntroIfNeeded()
        } else {
            showAppDiscoveryIntroIfNeeded()
        }
    }

    private func showAppDiscoveryIntroIfNeeded() {
        guard UserDefaults.standard.bool(forKey: shownAppDiscoveryIntroKey) == false else {
            return
        }

        UserDefaults.standard.set(true, forKey: shownAppDiscoveryIntroKey)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) { [weak self] in
            let alertController = KinAlertController(title: nil,
                                                     titleImage: Asset.appDiscoveryIntroPopup.image,
                                                     message: L10n.AppDiscoveryIntroPopup.title,
                                                     primaryAction: .init(title: L10n.AppDiscoveryIntroPopup.action),
                                                     secondaryAction: nil)
            self?.presentAnimated(alertController)
        }
    }

    private func showMoveKinIntroIfNeeded() {
        guard UserDefaults.standard.bool(forKey: shownEcosystemMoveKinIntroKey) == false else {
            return
        }

        UserDefaults.standard.set(true, forKey: shownEcosystemMoveKinIntroKey)
        let actionTitle = L10n.AppEcosystemMoveKinIntroPopup.action
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) { [weak self] in
            let alertController = KinAlertController(title: L10n.AppEcosystemMoveKinIntroPopup.title,
                                                     titleImage: Asset.appDiscoverySendIntroPopup.image,
                                                     message: L10n.AppEcosystemMoveKinIntroPopup.message,
                                                     primaryAction: .init(title: actionTitle),
                                                     secondaryAction: nil)
            self?.presentAnimated(alertController)
        }
    }

    private func renderEmpty(_ error: Error?) {
        let noticeContent: NoticeContent

        if let error = error {
            noticeContent = .fromError(error)
        } else {
            noticeContent = NoticeContent.generalServerError
        }

        addNoticeViewController(with: noticeContent)
    }
}

extension AppDiscoveryViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        guard categories.isNotEmpty else {
            return 0
        }

        return AppDiscoveryTableSections.allCases.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard
            let categories = categories,
            categories.isNotEmpty,
            let tSection = AppDiscoveryTableSections(rawValue: section) else {
            return 0
        }

        switch tSection {
        case .intro, .footer: return 1
        case .categories: return categories.count
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard
            let categories = categories,
            let section = AppDiscoveryTableSections(rawValue: indexPath.section) else {
            let m = "AppDiscoveryViewController received tableView:cellForItemAtIndexPath: but categories is nil"
            fatalError(m)
        }

        switch section {
        case .intro:
            return tableView.dequeueReusableCell(forIndexPath: indexPath) as EcosystemIntroTableViewCell
        case .categories:
            let cell = tableView.dequeueReusableCell(forIndexPath: indexPath) as EcosystemAppCategoryTableViewCell
            cell.titleLabel.text = categories[indexPath.row].name
            cell.setCollectionViewDataSourceDelegate(dataSourceDelegate: self, forRow: indexPath.row)
            return cell
        case .footer:
            let cell = tableView.dequeueReusableCell(forIndexPath: indexPath) as EcosystemFooterTableViewCell
            cell.explanationLabel.text = isTransferAvailable
                ? L10n.AppDiscovery.Footer.Title.sendAvailable
                : L10n.AppDiscovery.Footer.Title.discovery

            return cell
        }
    }
}

extension AppDiscoveryViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard let section = AppDiscoveryTableSections(rawValue: indexPath.section) else {
            return 0
        }

        return section.rowHeight
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard indexPath.section == AppDiscoveryTableSections.footer.rawValue else {
            return
        }

        let comingSoonViewController = AppDiscoveryComingSoonViewController()
        presentAnimated(comingSoonViewController)
    }
}

extension AppDiscoveryViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let categories = categories else {
            return 0
        }

        return categories[collectionView.tag].apps.count
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let categories = categories else {
            let m = "AppDiscoveryViewController received collectionView:cellForItemAtIndexPath: but categories is nil"
            fatalError(m)
        }

        let cell = collectionView.dequeueReusableCell(forIndexPath: indexPath) as AppCardCollectionViewCell
        cell.row = collectionView.tag
        cell.column = indexPath.item
        cell.delegate = self
        cell.drawAppInformation(categories[collectionView.tag].apps[indexPath.item], category: nil, short: false)

        return cell
    }
}

extension AppDiscoveryViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let categories = categories else {
            let m = "AppDiscoveryViewController received collectionView:didSelectItemAtIndexPath: but categories is nil"
            fatalError(m)
        }

        let category = categories[collectionView.tag]
        let appViewController = AppPageViewController()
        appViewController.appCategoryName = category.name
        appViewController.app = category.apps[indexPath.item]
        let navController = KinNavigationController.init(navigationBarClass: WhiteNavigationBar.self, toolbarClass: nil)
        navController.viewControllers = [appViewController]
        presentAnimated(navController)
    }
}

extension AppDiscoveryViewController: IndicatorInfoProvider {
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return IndicatorInfo(title: L10n.ecosystemApps)
    }
}

extension AppDiscoveryViewController: AppCardCellDelegate {
    func appCardCellDidTapActionButton(_ cell: AppCardCollectionViewCell) {
        guard let categories = categories else {
            let m = "AppDiscoveryViewController received ecosystemAppCellDidTapOpenApp: but categories is nil"
            fatalError(m)
        }

        let category = categories[cell.row]
        let app = category.apps[cell.column]

        let event: BIEvent
        if app.isTransferAvailable {
            event = Events.Analytics
                .ClickSendButtonOnAppItem(appCategory: category.name,
                                          appId: app.bundleId,
                                          appName: app.name)
        } else {
            event = Events.Analytics
                .ClickGetButtonOnAppItem(appCategory: category.name,
                                         appId: app.bundleId,
                                         appName: app.name)
        }

        event.send()

        appDiscoveryAction.performAppAction(for: app)
    }
}
