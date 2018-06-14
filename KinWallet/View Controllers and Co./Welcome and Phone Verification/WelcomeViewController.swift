//
//  WelcomeViewController.swift
//  Kinit
//

import UIKit
import SafariServices

private let firstScreenMessage =
"""
Earn Kin just for sharing your opinions. Spend Kin on your favorite brands. It takes less than a minute a day.
"""

private let secondScreenMessage =
"""
Earning Kin is as simple as answering a few questions a day on topics like, music, movies, fashion, apps and more.
"""

private let thirdScreenMessage =
"""
In no time, you’ll have enough Kin to spend towards your favorite brands (Amazon, Grubhub and more!).
"""

final class WelcomeViewController: UIViewController {
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var disclaimerLabel: UILabel!

    let pages: [TutorialPageView] = [.create(with: "Welcome to Kinit",
                                             message: firstScreenMessage,
                                             image: Asset.welcomeTutorial1.image),
                                     .create(with: "Earn Kin",
                                             message: secondScreenMessage,
                                             image: Asset.welcomeTutorial2.image),
                                     .create(with: "Enjoy",
                                             message: thirdScreenMessage,
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

        configureDisclaimerLabel()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        navigationController?.setNavigationBarHidden(true, animated: animated)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        logViewedPage()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        configurePages()
    }

    private func configurePages() {
        let scrollViewSize = scrollView.frame.size

        pages.first?.imageView.contentMode = UIDevice.isiPhone5()
            ? .scaleAspectFill
            : .scaleAspectFit

        pages.enumerated().forEach {
            let page = $0.element
            let origin = CGPoint(x: scrollViewSize.width * CGFloat($0.offset), y: 0)
            page.frame = CGRect(origin: origin, size: scrollViewSize)
        }

        var contentSize = scrollViewSize
        contentSize.width = scrollViewSize.width * CGFloat(pages.count)
        scrollView.contentSize = contentSize
    }

    private func configureDisclaimerLabel() {
        if RemoteConfig.current?.termsOfService != nil {
            disclaimerLabel.font = FontFamily.Roboto.regular.font(size: 12)
            disclaimerLabel.textColor = UIColor.white

            let string =
            """
By clicking "Start earning Kin" you are agreeing
to our Terms of Service and Privacy Policy
"""
            let attributedString = NSMutableAttributedString(string: string)
            attributedString.addAttributes([.font: FontFamily.Roboto.medium.font(size: 12),
                                            .foregroundColor: UIColor.kin.brightBlue],
                                           range: NSRange(location: 56, length: 16))
            attributedString.addAttributes([.font: FontFamily.Roboto.medium.font(size: 12),
                                            .foregroundColor: UIColor.kin.brightBlue],
                                           range: NSRange(location: 77, length: 14))
            disclaimerLabel.attributedText = attributedString
            disclaimerLabel.isUserInteractionEnabled = true

            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(openTermsOfService))
            disclaimerLabel.addGestureRecognizer(tapGesture)
        } else {
            disclaimerLabel.text = nil
            disclaimerLabel.isHidden = true
        }
    }

    @objc func openTermsOfService() {
        guard let tos = RemoteConfig.current?.termsOfService else {
            return
        }

        let safariViewController = SFSafariViewController(url: tos)
        present(safariViewController, animated: true, completion: nil)
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    @IBAction func startEarning(_ sender: Any) {
        logClickedStart()

        #if targetEnvironment(simulator)

        AppDelegate.shared.dismissSplashIfNeeded()

        #else

        if RemoteConfig.current?.phoneVerificationEnabled == true {
            let phoneVerification = StoryboardScene.Main.phoneVerificationRequestViewController.instantiate()
            navigationController?.pushViewController(phoneVerification, animated: true)
        } else {
            AppDelegate.shared.dismissSplashIfNeeded()
        }

        #endif
    }

    @IBAction func pageControlChangedValue(_ sender: Any) {
        let offsetX = scrollView.frame.width * CGFloat(pageControl.currentPage)
        scrollView.setContentOffset(CGPoint(x: offsetX, y: 0), animated: true)
        logViewedPage()
    }
}

extension WelcomeViewController {
    fileprivate func logClickedStart() {
        Events.Analytics
            .ClickStartButtonOnOnboardingPage(onboardingTutorialPage: currentPageForAnalytics())
            .send()
    }

    fileprivate func logViewedPage() {
        Events.Analytics
            .ViewOnboardingPage(onboardingTutorialPage: currentPageForAnalytics())
            .send()
    }

    private func currentPageForAnalytics() -> Int {
        return pageControl.currentPage + 1
    }
}

extension WelcomeViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let page = scrollView.contentOffset.x / scrollView.frame.width
        pageControl.currentPage = Int(page)
        logViewedPage()
    }
}
