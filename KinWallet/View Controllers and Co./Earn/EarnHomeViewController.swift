//
//  EarnHomeViewController.swift
//  KinWallet
//
//  Copyright © 2018 KinFoundation. All rights reserved.
//

import UIKit
import KinUtil

final class EarnHomeViewController: UIViewController {
    fileprivate struct Constants {
        static let numberOfColumns: UInt = 2
        static let itemSide: CGFloat = 155
        static let compactItemSide: CGFloat = 135
    }

    @IBOutlet weak var collectionView: UICollectionView! {
        didSet {
            collectionView.register(nib: TaskCategoryCollectionViewCell.self)
            let side = UIDevice.isiPhone5() ? Constants.compactItemSide : Constants.compactItemSide
            let itemSize = CGSize(width: side, height: side)
            (collectionView.collectionViewLayout as? UICollectionViewFlowLayout)?.itemSize = itemSize
        }
    }

    var categories = [TaskCategory]()
    let linkBag = LinkBag()

    override func viewDidLoad() {
        super.viewDidLoad()

        addBalanceLabel()
        KinLoader.shared.taskCategories
            .on(queue: .main, next: renderTaskCategories)
            .add(to: linkBag)
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    func renderTaskCategories(_ result: FetchResult<[TaskCategory]>) {
        switch result {
        case .none://(let error):
            print("Meh")
        case .some(let categories):
            self.categories = categories
            self.collectionView.reloadData()
        }
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
        cell.imageView.loadImage(url: imageURL,
                                 applying: category.availableTasksCount == 0 ? UIImage.applyingBlackAndWhite : nil)

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
        viewController.category = category

        let headerURL = category.ui.headerImageURL.kinImagePathAdjustedForDevice()
        if let headerLocalURL = ResourceDownloader.shared.downloadedResource(url: headerURL) {
            viewController.headerImage = UIImage(contentsOfFile: headerLocalURL.path)
        }

        navigationController?.pushViewController(viewController, animated: true)
    }
}

extension EarnHomeViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        guard let layout = collectionViewLayout as? UICollectionViewFlowLayout else {
            return .zero
        }

        let spacing = collectionView.equalSpacing(forColumns: Constants.numberOfColumns,
                                                  cellWidth: layout.itemSize.width)
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
