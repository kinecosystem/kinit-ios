//
//  WelcomeViewController.swift
//  KinWallet
//
//  Copyright © 2018 KinFoundation. All rights reserved.
//

import UIKit

final class WelcomeViewController: UIViewController {
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var pageControl: UIPageControl!
    let pages: [TutorialPageView] = [.create(with: "Welcome to Kinit",
                                             message: "Earn Kin just for sharing your opinions. Spend Kin on your favorite brands. It takes less than a minute a day.",
                                             image: Asset.welcomeTutorial1.image),
                                     .create(with: "Earn Kin",
                                             message: "Earning Kin is as simple as answering a few questions a day on topics like, music, movies, fashion, apps and more.",
                                             image: Asset.welcomeTutorial2.image),
                                     .create(with: "Enjoy",
                                             message: "In no time, you’ll have enough Kin to spend towards your favorite brands (Amazon, Grubhub and more!).",
                                             image: Asset.welcomeTutorial3.image)]

    @IBOutlet weak var startEarningKin: UIButton! {
        didSet {
            startEarningKin.makeKinButtonFilled(with: .white)
            startEarningKin.tintColor = UIColor.kin.appTint
        }
    }

    @IBOutlet weak var gradientBackgroundView: GradientView! {
        didSet {
            gradientBackgroundView.colors = UIColor.blueGradientColors1.reversed()
            gradientBackgroundView.direction = .vertical
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        pages.forEach(scrollView.addSubview)
        let backButtonItem = UIBarButtonItem(title: nil, style: .plain, target: nil, action: nil)
        backButtonItem.tintColor = UIColor.kin.darkGray
        navigationItem.backBarButtonItem = backButtonItem
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        navigationController?.setNavigationBarHidden(true, animated: animated)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        configurePages()
    }

    func configurePages() {
        let scrollViewSize = scrollView.frame.size

        pages.first?.imageView.contentMode = .scaleAspectFit
        pages.enumerated().forEach {
            let page = $0.element
            let origin = CGPoint(x: scrollViewSize.width * CGFloat($0.offset), y: 0)
            page.frame = CGRect(origin: origin, size: scrollViewSize)
        }

        var contentSize = scrollViewSize
        contentSize.width = scrollViewSize.width * CGFloat(pages.count)
        scrollView.contentSize = contentSize
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    @IBAction func startEarning(_ sender: Any) {
        let phoneVerification = StoryboardScene.Main.phoneVerificationRequestViewController.instantiate()
        navigationController?.pushViewController(phoneVerification, animated: true)
    }

    @IBAction func pageControlChangedValue(_ sender: Any) {
        let offsetX = scrollView.frame.width * CGFloat(pageControl.currentPage)
        scrollView.setContentOffset(CGPoint(x: offsetX, y: 0), animated: true)
    }
}

extension WelcomeViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let page = scrollView.contentOffset.x / scrollView.frame.width
        pageControl.currentPage = Int(page)
    }
}
