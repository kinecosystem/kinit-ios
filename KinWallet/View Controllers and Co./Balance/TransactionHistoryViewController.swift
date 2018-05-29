//
//  TransactionHistoryViewController.swift
//  KinWallet
//
//  Copyright © 2018 KinFoundation. All rights reserved.
//

import UIKit
import KinUtil

class TransactionHistoryViewController: HistoryViewController<KinitTransaction, TransactionHistoryCollectionViewCell> {
    var balances = [String: UInt64]()

    override func observable() -> Observable<FetchResult<[KinitTransaction]>> {
        return KinLoader.shared.transactions
    }

    override func configureCell(_ cell: TransactionHistoryCollectionViewCell,
                                item: KinitTransaction,
                                at indexPath: IndexPath) {
        let isFirst = subscriber.items.first == item
        let isLast = subscriber.items.last == item

        let balanceAfter = balances[item.txHash] ?? 0

        TransactionHistoryCellFactory.drawCell(cell,
                                               for: item,
                                               isFirst: isFirst,
                                               isLast: isLast,
                                               balanceAfter: balanceAfter)
    }

    override func availabilityChanged(items: [KinitTransaction]?, error: Error?) {
        super.availabilityChanged(items: items, error: error)

        guard let items = items else {
            return
        }
        balances.removeAll()
        var lastBalance = 0

        items.reversed().forEach {
            lastBalance += $0.amount * ($0.clientReceived ? 1 : -1)
            balances[$0.txHash] = UInt64(max(0, lastBalance))
        }
    }

    override func createEmptyStateView() -> EmptyStateView {
        let emptyView = super.createEmptyStateView()
        emptyView.textLabel.text = "Your transactions will be recorded here!"
        emptyView.imageView.image = Asset.recordsLedger.image

        return emptyView
    }
}

extension TransactionHistoryViewController: IndicatorInfoProvider {
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return IndicatorInfo(title: "Recent Activity")
    }
}
