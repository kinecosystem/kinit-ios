//
//  EarnHomeViewController.swift
//  KinWallet
//
//  Copyright © 2018 KinFoundation. All rights reserved.
//

import UIKit
import KinUtil

final class EarnHomeViewController: UIViewController, AddNoticeViewController {
    fileprivate struct Constants {
        static let numberOfColumns: UInt = 2
        static let itemSide: CGFloat = 155
        static let compactItemSide: CGFloat = 135
    }

    private var shouldShowEarnAnimation = true
    private var animatingEarn = false
    fileprivate var navigationBarImage: UIImage?

    private let activityIndicator = UIActivityIndicatorView(style: .white)

    @IBOutlet weak var categoriesViewContainer: UIView!

    @IBOutlet weak var headerLabelsLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var headerTitleLabel: UILabel! {
        didSet {
            headerTitleLabel.text = nil
            headerTitleLabel.font = FontFamily.Roboto.medium.font(size: 16)
            headerTitleLabel.textColor = UIColor.kin.darkGray
        }
    }

    @IBOutlet weak var headerMessageLabel: UILabel! {
        didSet {
            headerMessageLabel.text = nil
            headerMessageLabel.font = FontFamily.Roboto.regular.font(size: 14)
            headerMessageLabel.textColor = UIColor.kin.gray
        }
    }

    @IBOutlet weak var collectionView: UICollectionView! {
        didSet {
            collectionView.register(nib: TaskCategoryCollectionViewCell.self)
            let side = UIDevice.isiPhone5() ? Constants.compactItemSide : Constants.itemSide
            let itemSize = CGSize(width: side, height: side)
            (collectionView.collectionViewLayout as? UICollectionViewFlowLayout)?.itemSize = itemSize
        }
    }

    var categories = [TaskCategory]()
    let linkBag = LinkBag()

    override func viewDidLoad() {
        super.viewDidLoad()

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(splashScreenWillDismiss),
                                               name: .SplashScreenWillDismiss,
                                               object: nil)

        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: activityIndicator)
        addBalanceLabel()
        bindObservables()

        navigationBarImage = navigationController?.navigationBar.backgroundImage(for: .default)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if let navBarImage = navigationBarImage {
            navigationController?.navigationBar.setBackgroundImage(navBarImage, for: .default)
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        if !AppDelegate.shared.rootViewController.isShowingSplashScreen {
            Events.Analytics
                .ViewTaskCategoriesPage()
                .send()
        }
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        headerLabelsLeadingConstraint.constant = collectionViewSpacing(for: collectionView.collectionViewLayout)
    }

    private func bindObservables() {
        DataLoaders.tasks.categories
            .on(queue: .main, next: renderTaskCategories)
            .add(to: linkBag)
        DataLoaders.tasks.isLoadingCategories
            .on(queue: .main, next: { [weak self] isLoading in
                if isLoading {
                    self?.activityIndicator.startAnimating()
                } else {
                    self?.activityIndicator.stopAnimating()
                }
            }).add(to: linkBag)

        DataLoaders.tasks.headerMessage
        .on(queue: .main, next: { [weak self] in
            self?.headerTitleLabel.text = $0.title
            self?.headerMessageLabel.text = $0.subtitle
        }).add(to: linkBag)
    }

    func renderTaskCategories(_ result: FetchResult<[TaskCategory]>) {
        switch result {
        case .none(let error):
            showCategoriesUnavailable(error: error)
        case .some(let categories):
            children
                .compactMap { $0 as? NoticeViewController }
                .forEach { $0.remove() }

            self.categories = categories
            collectionView.reloadData()
            showEarnAnimationIfNeeded()

            if categoriesViewContainer.isHidden {
                categoriesViewContainer.isHidden = false
            }
        }
    }

    func showCategoriesUnavailable(error: Error?) {
        children.forEach { $0.remove() }

        let noticeContent: NoticeContent
        let errorType: Events.ErrorType
        let failureReason: String?

        if let error = error {
            noticeContent = .fromError(error)
            errorType =  error.isInternetError ? .internetConnection : .generic
            failureReason = error.localizedDescription
        } else {
            noticeContent = NoticeContent.generalServerError
            errorType = Events.ErrorType.generic
            failureReason = nil
        }

        addNoticeViewController(with: noticeContent)
        Events.Analytics
            .ViewErrorPage(errorType: errorType, failureReason: failureReason)
            .send()
    }

    @objc func splashScreenWillDismiss() {
        Events.Analytics
            .ViewTaskCategoriesPage()
            .send()

        showEarnAnimationIfNeeded()
    }

    func showEarnAnimationIfNeeded() {
        guard
            categories.reduce(into: 0, { $0 += $1.availableTasksCount }) > 0,
            !AppDelegate.shared.isShowingSplashScreen,
            shouldShowEarnAnimation,
            !animatingEarn else {
                return
        }

        let width = view.frame.width
        shouldShowEarnAnimation = false
        animatingEarn = true

        let earnAnimationViewController = StoryboardScene.Earn.earnKinAnimationViewController.instantiate()
        addAndFit(earnAnimationViewController)

        categoriesViewContainer.transform = .init(translationX: width, y: 0)
        UIView.animate(withDuration: 0.7,
                       delay: 1.5,
                       options: [],
                       animations: {
                        earnAnimationViewController.view.transform = .init(translationX: -width, y: 0)
                        earnAnimationViewController.view.alpha = 0
                        self.categoriesViewContainer.transform = .identity
        }, completion: { _ in
            earnAnimationViewController.remove()
            self.animatingEarn = false
        })
    }

    fileprivate func collectionViewSpacing(for layout: UICollectionViewLayout) -> CGFloat {
        guard let layout = layout as? UICollectionViewFlowLayout else {
            return 0
        }

        return collectionView.equalSpacing(forColumns: Constants.numberOfColumns,
                                           cellWidth: layout.itemSize.width)
    }
}

extension EarnHomeViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return categories.count
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let category = categories[indexPath.item]
        let cell: TaskCategoryCollectionViewCell = collectionView.dequeueReusableCell(forIndexPath: indexPath)

        let imageURL = category.ui.iconImageURL.kinImagePathAdjustedForDevice()
        let shouldApplyBlackAndWhite = category.availableTasksCount == 0

        let imageIdentifier = shouldApplyBlackAndWhite
            ? imageURL.absoluteString + "-B&W"
            : imageURL.absoluteString

        if cell.currentImageIdentifier != imageIdentifier {
            cell.currentImageIdentifier = imageIdentifier
            cell.imageView.loadImage(url: imageURL,
                                     useInMemoryCache: true,
                                     applying: shouldApplyBlackAndWhite ? UIImage.applyingBlackAndWhite : nil)
        }

        DispatchQueue.global().async {
            let headerURL = category.ui.headerImageURL.kinImagePathAdjustedForDevice()
            if ResourceDownloader.shared.downloadedResource(url: headerURL) == nil {
                ResourceDownloader.shared.requestResource(url: headerURL)
            }
        }

        return cell
    }
}

extension EarnHomeViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let category = categories[indexPath.item]

        let viewController = TaskCategoryViewController()
        viewController.navBarColor = category.ui.color
        viewController.categoryId = category.identifier

        let headerURL = category.ui.headerImageURL.kinImagePathAdjustedForDevice()
        if let headerLocalURL = ResourceDownloader.shared.downloadedResource(url: headerURL) {
            viewController.headerImage = UIImage(contentsOfFile: headerLocalURL.path)
        }

        navigationController?.pushViewController(viewController, animated: true)

        Events.Analytics
            .ClickCategoryButtonOnTaskCategoriesPage(taskCategory: category.title)
            .send()
    }
}

extension EarnHomeViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        let spacing = collectionViewSpacing(for: collectionViewLayout)

        return UIEdgeInsets(top: spacing,
                            left: spacing,
                            bottom: spacing,
                            right: spacing)
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        guard let layout = collectionViewLayout as? UICollectionViewFlowLayout else {
            return 0
        }

        return collectionView.equalSpacing(forColumns: Constants.numberOfColumns,
                                           cellWidth: layout.itemSize.width)
    }
}
