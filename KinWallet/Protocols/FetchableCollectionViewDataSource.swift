//
//  FetchableCollectionViewOwner.swift
//  KinWallet
//
//  Copyright © 2018 KinFoundation. All rights reserved.
//

import UIKit
import KinUtil

class FetchableCollectionViewSubscriber<T>: NSObject {
    typealias ItemsAvailabilityBlock = ([T]?, Error?) -> Void

    weak var collectionView: UICollectionView?
    private(set) var items = [T]()
    let itemsAvailabilityChanged: ItemsAvailabilityBlock

    init(collectionView: UICollectionView,
         observable: Observable<FetchResult<[T]>>,
         linkBag: LinkBag,
         itemsAvailabilityChanged: @escaping ItemsAvailabilityBlock) {
        self.collectionView = collectionView
        self.itemsAvailabilityChanged = itemsAvailabilityChanged

        super.init()

        observable
            .on(queue: .main, next: react)
            .add(to: linkBag)
    }

    func react(to fetchResult: FetchResult<[T]>) {
        switch fetchResult {
        case .some(let items):
            self.items = items
            itemsAvailabilityChanged(items, nil)
        case .none(let error):
            items = []
            itemsAvailabilityChanged(nil, error)
        }

        collectionView?.reloadData()
    }
}
