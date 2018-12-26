//
//  AppPageImagesHeaderTableViewCell.swift
//  KinWallet
//
//  Copyright © 2018 KinFoundation. All rights reserved.
//

import UIKit

private class AppPageImageView: UIImageView {}

class AppPageImagesHeaderTableViewCell: UITableViewCell {
    var lastWidth: CGFloat = 0

    let scrollView: UIScrollView = {
        let s = UIScrollView()
        s.translatesAutoresizingMaskIntoConstraints = false
        s.isPagingEnabled = true
        s.showsVerticalScrollIndicator = false
        s.showsHorizontalScrollIndicator = false

        return s
    }()

    let pageControl: UIPageControl = {
        let height: CGFloat = 20
        let p = UIPageControl()
        p.translatesAutoresizingMaskIntoConstraints = false
        p.pageIndicatorTintColor = UIColor.white.withAlphaComponent(0.3)
        p.currentPageIndicatorTintColor = .white
        p.widthAnchor.constraint(equalToConstant: 60).isActive = true
        p.heightAnchor.constraint(equalToConstant: height).isActive = true
        p.backgroundColor = UIColor.black.withAlphaComponent(0.2)
        p.layer.cornerRadius = height/2

        return p
    }()

    var imageURLs = [URL]() {
        didSet {
            if oldValue != imageURLs {
                assert(imageURLs.count <= 3, "AppPageImagesHeaderTableViewCell handles up to 3 images only.")
                generateImageViews()
            }
        }
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        addAndFit(scrollView)
        scrollView.delegate = self

        pageControl.addTarget(self, action: #selector(pageControlChangedValue), for: .valueChanged)
        addSubview(pageControl)
        bottomAnchor.constraint(equalTo: pageControl.bottomAnchor, constant: 8).isActive = true
        centerXAnchor.constraint(equalTo: pageControl.centerXAnchor).isActive = true
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        if lastWidth != frame.width {
            lastWidth = frame.width
            repositionImageViews()
        }
    }

    private func generateImageViews() {
        scrollView.subviews
            .compactMap { $0 as? AppPageImageView }
            .forEach { $0.removeFromSuperview() }

        let imageViews: [AppPageImageView] = imageURLs.map {
            let imageView = AppPageImageView()
            imageView.contentMode = .scaleAspectFill
            imageView.loadImage(url: $0, placeholderColor: UIColor.kin.lightGray, size: CGSize(width: 1, height: 1))

            return imageView
        }

        imageViews.forEach { self.scrollView.addSubview($0) }
        scrollView.setContentOffset(.zero, animated: false)
        pageControl.currentPage = 0

        let count = imageViews.count
        pageControl.numberOfPages = count
        pageControl.isHidden = count <= 1
        scrollView.isScrollEnabled = count > 1

        repositionImageViews(imageViews)
    }

    private func repositionImageViews() {
        let imageViews = scrollView.subviews
            .compactMap { $0 as? AppPageImageView }
        repositionImageViews(imageViews)
    }

    private func repositionImageViews(_ imageViews: [AppPageImageView]) {
        let width = frame.width
        let pageSize = CGSize(width: width, height: frame.height)

        imageViews.enumerated().forEach {
            $0.element.frame = CGRect(origin: CGPoint(x: width * CGFloat($0.offset), y: 0),
                                      size: pageSize)
        }

        scrollView.contentSize = CGSize(width: width * CGFloat(imageViews.count), height: frame.height)
    }

    @objc private func pageControlChangedValue() {
        scrollView.setContentOffset(CGPoint(x: frame.width * CGFloat(pageControl.currentPage), y: 0), animated: true)
    }
}

extension AppPageImagesHeaderTableViewCell: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let pageFloat = scrollView.contentOffset.x / scrollView.frame.width
        let page = Int(round(pageFloat))

        if page != pageControl.currentPage {
            pageControl.currentPage = Int(page)
        }
    }
}
