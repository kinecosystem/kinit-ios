//
//  UICollectionView+KinWallet.swift
//  Kinit
//

import UIKit

// MARK: Registering cells and reusable views

extension UICollectionView {
    func register<T: UICollectionViewCell>(class: T.Type) {
        register(T.self, forCellWithReuseIdentifier: T.reuseIdentifier)
    }

    func register<T: UICollectionViewCell>(nib: T.Type) where T: NibLoadableView {

        let nib = UINib(nibName: T.nibName, bundle: nil)
        register(nib, forCellWithReuseIdentifier: T.reuseIdentifier)
    }

    func register<T: UICollectionReusableView>(class: T.Type) {
        register(T.self,
                 forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                 withReuseIdentifier: T.reuseIdentifier)
        register(T.self,
                 forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter,
                 withReuseIdentifier: T.reuseIdentifier)
    }

    func register<T: UICollectionReusableView>(nib: T.Type) where T: NibLoadableView {
        let nib = UINib(nibName: T.nibName, bundle: nil)
        register(nib,
                 forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                 withReuseIdentifier: T.reuseIdentifier)
        register(nib,
                 forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter,
                 withReuseIdentifier: T.reuseIdentifier)
    }

    func dequeueReusableCell<T: UICollectionViewCell>(forIndexPath indexPath: IndexPath) -> T {
        guard let cell = dequeueReusableCell(withReuseIdentifier: T.reuseIdentifier, for: indexPath) as? T else {
            fatalError("Could not dequeue cell with identifier: \(T.reuseIdentifier)")
        }

        return cell
    }

    func dequeueReusableView<T: UICollectionReusableView>(ofKind kind: String, forIndexPath indexPath: IndexPath) -> T {
        guard let reusableView = dequeueReusableSupplementaryView(ofKind: kind,
                                                                  withReuseIdentifier: T.reuseIdentifier,
                                                                  for: indexPath) as? T else {
            fatalError("Could not dequeue reusable view with identifier: \(T.reuseIdentifier)")
        }

        return reusableView
    }
}

// MARK: Layout calculations

extension UICollectionView {
    func equalSpacing(forColumns columns: UInt, cellWidth: CGFloat) -> CGFloat {
        let emptySpace = frame.width - CGFloat(columns) * cellWidth
        return floor(emptySpace/CGFloat(columns + 1))
    }
}
