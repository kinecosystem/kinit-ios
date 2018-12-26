//
//  EcosystemIntroTableViewCell.swift
//  KinWallet
//
//  Copyright © 2018 KinFoundation. All rights reserved.
//

import UIKit

class EcosystemIntroTableViewCell: UITableViewCell {
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)

        textLabel?.text = L10n.AppEcosystem.title
        textLabel?.font = FontFamily.Roboto.medium.font(size: 20)
        textLabel?.textColor = UIColor.kin.gray

        detailTextLabel?.text = L10n.AppEcosystem.subtitle
        detailTextLabel?.font = FontFamily.Roboto.regular.font(size: 16)
        detailTextLabel?.textColor = UIColor.kin.gray
        detailTextLabel?.numberOfLines = 2
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private let collectionViewInset: CGFloat = 20
private let collectionViewInsets = UIEdgeInsets(top: collectionViewInset,
                                                left: collectionViewInset,
                                                bottom: collectionViewInset,
                                                right: collectionViewInset)

class EcosystemAppCategoryTableViewCell: UITableViewCell {
    var layout: UICollectionViewFlowLayout {
        return collectionView.collectionViewLayout as! UICollectionViewFlowLayout //swiftlint:disable:this force_cast
    }

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

        titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20).isActive = true
        titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20).isActive = true
        contentView.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor, constant: 20).isActive = true
        titleLabel.heightAnchor.constraint(equalToConstant: 26).isActive = true
        titleLabel.bottomAnchor.constraint(equalTo: collectionView.topAnchor, constant: 0).isActive = true
        contentView.leadingAnchor.constraint(equalTo: collectionView.leadingAnchor).isActive = true
        contentView.trailingAnchor.constraint(equalTo: collectionView.trailingAnchor).isActive = true
        contentView.bottomAnchor.constraint(equalTo: collectionView.bottomAnchor).isActive = true
    }

    func setCollectionViewDataSourceDelegate(dataSourceDelegate: UICollectionViewDataSource & UICollectionViewDelegate,
                                             forRow row: Int) {
        collectionView.delegate = dataSourceDelegate
        collectionView.dataSource = dataSourceDelegate
        collectionView.tag = row
        collectionView.reloadData()
    }
}

class EcosystemFooterTableViewCell: UITableViewCell {

}
