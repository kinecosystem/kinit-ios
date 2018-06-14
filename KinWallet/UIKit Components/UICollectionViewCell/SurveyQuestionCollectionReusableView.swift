//
//  SurveyQuestionCollectionViewCell.swift
//  Kinit
//

import UIKit

class SurveyQuestionCollectionReusableView: UICollectionReusableView, NibLoadableView {
    @IBOutlet weak var questionLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var imageViewHeightConstraint: NSLayoutConstraint!

    override func awakeFromNib() {
        super.awakeFromNib()

        isExclusiveTouch = true
    }
}
