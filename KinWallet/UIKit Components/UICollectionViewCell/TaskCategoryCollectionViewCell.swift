//
//  TaskCategoryCollectionViewCell.swift
//  KinWallet
//
//  Copyright © 2018 KinFoundation. All rights reserved.
//

import UIKit

class TaskCategoryCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var imageView: UIImageView!

    override func prepareForReuse() {
        super.prepareForReuse()

        imageView.image = nil
    }
}

extension TaskCategoryCollectionViewCell: NibLoadableView {}
