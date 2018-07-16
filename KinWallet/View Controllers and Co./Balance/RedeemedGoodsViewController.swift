//
//  RedeemedGoodsViewController.swift
//  Kinit
//

import UIKit
import KinUtil

//swiftlint:disable:next line_length
class RedeemedGoodsViewController: HistoryViewController<RedeemTransaction, RedeemTransactionCollectionViewCell>, UICollectionViewDelegateFlowLayout {
    var openTransaction: RedeemTransaction?

    //swiftlint:disable:next force_cast line_length
    fileprivate let sizingCell = Bundle.main.loadNibNamed(RedeemTransactionCollectionViewCell.reuseIdentifier, owner: nil, options: nil)?.first as! RedeemTransactionCollectionViewCell

    override func viewDidLoad() {
        super.viewDidLoad()

        collectionView.delegate = self
    }

    override func observable() -> Observable<FetchResult<[RedeemTransaction]>> {
        return KinLoader.shared.redeemedItems
    }

    override func configureCell(_ cell: RedeemTransactionCollectionViewCell,
                                item: RedeemTransaction,
                                at indexPath: IndexPath) {
        RedeemTransactionCellFactory.drawCell(cell, for: item)
        cell.delegate = self
        cell.indexPath = indexPath
        cell.isOpen = item == openTransaction
    }

    override func createEmptyStateView() -> EmptyStateView {
        let emptyView = super.createEmptyStateView()
        emptyView.textLabel.text = L10n.vouchersEmptyStateMessage
        emptyView.imageView.image = Asset.emptyHistoryCoupon.image

        return emptyView
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        //swiftlint:disable:next force_cast
        let itemSize = (collectionViewLayout as! UICollectionViewFlowLayout).itemSize

        if let openTransaction = openTransaction,
            openTransaction == subscriber.items[indexPath.item] {
            var maximumCellSize = itemSize
            maximumCellSize.height = 1000

            sizingCell.isOpen = true
            RedeemTransactionCellFactory.drawCell(sizingCell, for: openTransaction)

            return sizingCell.contentView.systemLayoutSizeFitting(maximumCellSize,
                                                                  withHorizontalFittingPriority: .required,
                                                                  verticalFittingPriority: .fittingSizeLevel)
        }

        return itemSize
    }
}

extension RedeemedGoodsViewController: RedeemTransactionCellDelegate {
    func redeemTransactionCellDidTapExport(_ cell: RedeemTransactionCollectionViewCell) {
        let code = subscriber.items[cell.indexPath.item].value
        let activityViewController = UIActivityViewController(activityItems: [code],
                                                              applicationActivities: nil)
        present(activityViewController, animated: true)
    }

    func redeemTransactionCellDidToggle(_ cell: RedeemTransactionCollectionViewCell) {
        if cell.isOpen {
            openTransaction = nil
        } else {
            openTransaction = subscriber.items[cell.indexPath.item]
        }

        collectionView.performBatchUpdates({
            collectionView.visibleCells
                .compactMap { $0 as? RedeemTransactionCollectionViewCell }
                .filter { $0 != cell && $0.isOpen }
                .first?.isOpen = false

            cell.isOpen.toggle()
            if !cell.isOpen {
                collectionView.reloadItems(at: [cell.indexPath])
            }

        }, completion: nil)
    }
}

extension RedeemedGoodsViewController: IndicatorInfoProvider {
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return IndicatorInfo(title: L10n.balanceMyVouchers)
    }
}
