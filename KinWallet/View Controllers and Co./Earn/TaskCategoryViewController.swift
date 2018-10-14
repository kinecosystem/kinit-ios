//
//  TaskCategoryViewController.swift
//  KinWallet
//
//  Copyright © 2018 KinFoundation. All rights reserved.
//

import UIKit

class TaskCategoryTitleView: UIView {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var tasksCountStackView: UIStackView!
    @IBOutlet weak var tasksCountLabel: UILabel!
    @IBOutlet weak var iconImageView: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()

        let textColor = UIColor.white
        let font = FontFamily.Roboto.regular

        titleLabel.textColor = textColor
        titleLabel.font = font.font(size: 20)

        tasksCountLabel.textColor = textColor
        tasksCountLabel.font = font.font(size: 12)
    }
}

extension TaskCategoryTitleView: NibLoadableView {}

class TaskCategoryViewController: UIViewController {
    var category: TaskCategory!
    var headerImage: UIImage?

    private let titleView = TaskCategoryTitleView.loadNib()
    fileprivate var previousNavigationBarImage: UIImage!

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .white
        navigationItem.titleView = titleView
        reloadTitleView()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        previousNavigationBarImage = navigationController?.navigationBar.backgroundImage(for: .default)!

        if let color = category.ui.color,
            let navBar = navigationController?.navigationBar,
            let backgroundColorImage = UIImage.from(color) {

            navBar.setBackgroundImage(backgroundColorImage, for: .default)

            if let headerImage = headerImage {
                let categoryNavBarImage = backgroundColorImage.addingAnotherToBottomLeftCorner(headerImage)
                navBar.setBackgroundImage(categoryNavBarImage, for: .default)
            }
        }
    }

    func reloadTitleView() {
        let count = category.availableTasksCount
        titleView.titleLabel.text = category.title.capitalized
        titleView.tasksCountLabel.text = L10n.availableActivitesCount(count)
        titleView.tasksCountStackView.isHidden = count <= 1
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
}

extension TaskCategoryViewController: KinNavigationControllerDelegate {
    func shouldPopViewController() -> Bool {
        navigationController?.navigationBar.setBackgroundImage(previousNavigationBarImage, for: .default)
        return true
    }
}

private extension UIImage {
    func addingAnotherToBottomLeftCorner(_ another: UIImage, padding: CGFloat = 5) -> UIImage {
        let scale = UIScreen.main.scale
        let anotherImageSize = CGSize(width: another.size.width/scale,
                                      height: another.size.height/scale)
        let contextSize = CGSize(width: anotherImageSize.width + padding,
                                 height: anotherImageSize.height + padding)

        UIGraphicsBeginImageContextWithOptions(contextSize, true, scale)
        defer {
            UIGraphicsEndImageContext()
        }

        draw(in: CGRect(origin: .zero, size: contextSize))
        another.draw(in: CGRect(origin: CGPoint(x: padding, y: padding), size: anotherImageSize))
        let resizeInsets = UIEdgeInsets(top: 0, left: 0, bottom: another.size.height, right: another.size.width)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()!
            .resizableImage(withCapInsets: resizeInsets,
                            resizingMode: .stretch)
        return newImage
    }
}
