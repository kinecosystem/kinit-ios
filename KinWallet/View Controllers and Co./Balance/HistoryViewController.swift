//
//  HistoryViewController.swift
//  Kinit
//

import UIKit
import KinUtil

typealias CellType = NibLoadableView & UICollectionViewCell

class HistoryViewController<T, C: CellType>: UIViewController, UICollectionViewDataSource {
    let linkBag = LinkBag()
    var subscriber: FetchableCollectionViewSubscriber<T>!
    var emptyStateView: EmptyStateView?

    let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = .zero
        layout.minimumLineSpacing = 0

        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = .white

        return cv
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        calculateItemSize()
        collectionView.register(nib: C.self)
        view.addAndFit(collectionView)
        collectionView.dataSource = self

        subscriber = FetchableCollectionViewSubscriber<T>
            .init(collectionView: collectionView,
                  observable: observable(),
                  linkBag: linkBag,
                  itemsAvailabilityChanged: { [weak self] items, error in
                    self?.availabilityChanged(items: items, error: error)
            })
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        calculateItemSize()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        emptyStateView?.startAnimating()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)

        emptyStateView?.stopAnimating()
    }

    func calculateItemSize() {
        if let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.itemSize = CGSize(width: view.frame.width, height: 70)
        }
    }

    func observable() -> Observable<FetchResult<[T]>> {
        fatalError("Override observable() in HistoryViewController subclasses")
    }

    func configureCell(_ cell: C, item: T, at indexPath: IndexPath) {
        fatalError("Override configureCell() in HistoryViewController subclasses")
    }

    func availabilityChanged(items: [T]?, error: Error?) {
        if items != nil {
            emptyStateView?.removeFromSuperview()
            emptyStateView = nil
        } else {
            if emptyStateView == nil {
                let emptyView = createEmptyStateView()
                view.addAndFit(emptyView)
            }

            emptyStateView?.startAnimating()
        }
    }

    func createEmptyStateView() -> EmptyStateView {
        let fromXib = Bundle.main.loadNibNamed("EmptyStateView", owner: nil, options: nil)?.first
        guard let emptyStateView = fromXib as? EmptyStateView else {
            fatalError("EmptyStateView could not be loaded from xib")
        }

        self.emptyStateView = emptyStateView

        return emptyStateView
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return subscriber.items.count
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(forIndexPath: indexPath) as C
        configureCell(cell, item: subscriber.items[indexPath.item], at: indexPath)

        return cell
    }
}
