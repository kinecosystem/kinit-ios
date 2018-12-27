//
//  EcosystemAppCategoryTableViewCell.swift
//  KinWallet
//
//  Copyright © 2018 KinFoundation. All rights reserved.
//

import UIKit

private let collectionViewInset: CGFloat = 20
private let collectionViewInsets = UIEdgeInsets(top: collectionViewInset,
                                                left: collectionViewInset,
                                                bottom: collectionViewInset,
                                                right: collectionViewInset)

class EcosystemAppCategoryTableViewCell: UITableViewCell {
    var layout: UICollectionViewFlowLayout {
        return collectionView.collectionViewLayout as! UICollectionViewFlowLayout //swiftlint:disable:this force_cast
    }

    //ideally, one should use UITableView's and Cell's properties for separator
    //because the design makes them different according to the position in the table,
    //and would require logic implementation, it makes more sense to draw a custom view
    //at the top of each EcosystemAppCategoryTableViewCell
    let customSeparator: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.heightAnchor.constraint(equalToConstant: 1).isActive = true
        v.backgroundColor = UIColor.kin.lightGray

        return v
    }()

    let collectionView: UICollectionView = {
        let layout = HorizontalGalleryCollectionViewLayout()
        layout.scrollDirection = .horizontal
        layout.sectionInset = collectionViewInsets
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.register(nib: AppCardCollectionViewCell.self)
        cv.translatesAutoresizingMaskIntoConstraints = false
        cv.backgroundColor = .white
        cv.decelerationRate = .fast
        cv.showsHorizontalScrollIndicator = false
        cv.showsVerticalScrollIndicator = false

        return cv
    }()

    let titleLabel: UILabel = {
        let l = UILabel()
        l.translatesAutoresizingMaskIntoConstraints = false
        l.textColor = UIColor.kin.gray
        l.font = FontFamily.Roboto.regular.font(size: 20)

        return l
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        commonInit()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        commonInit()
    }

    private func commonInit() {
        contentView.addSubview(titleLabel)
        contentView.addSubview(collectionView)
        contentView.addSubview(customSeparator)

        let inset = collectionViewInset
        let constraints = [
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: inset),
            contentView.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor, constant: inset),
            titleLabel.heightAnchor.constraint(equalToConstant: 26),
            titleLabel.bottomAnchor.constraint(equalTo: collectionView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: collectionView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: collectionView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: collectionView.bottomAnchor),
            contentView.topAnchor.constraint(equalTo: customSeparator.topAnchor),
            customSeparator.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: inset),
            contentView.trailingAnchor.constraint(equalTo: customSeparator.trailingAnchor, constant: inset)
        ]

        NSLayoutConstraint.activate(constraints)
    }

    func setCollectionViewDataSourceDelegate(dataSourceDelegate: UICollectionViewDataSource & UICollectionViewDelegate,
                                             forRow row: Int) {
        collectionView.delegate = dataSourceDelegate
        collectionView.dataSource = dataSourceDelegate
        collectionView.tag = row
        collectionView.reloadData()
    }
}
