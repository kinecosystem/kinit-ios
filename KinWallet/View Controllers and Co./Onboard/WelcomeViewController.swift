//
//  WelcomeViewController.swift
//  Kinit
//

import UIKit
import SafariServices
import KinitDesignables

final class WelcomeViewController: UIViewController {
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var disclaimerLabel: UILabel!

    let pages: [TutorialPageView] = [.create(with: L10n.welcome1stScreenTitle,
                                             message: L10n.welcome1stScreenMessage,
                                             image: Asset.welcomeTutorial1.image),
                                     .create(with: L10n.welcome2ndScreenTitle,
                                             message: L10n.welcome2ndScreenMessage,
                                             image: Asset.welcomeTutorial2.image),
                                     .create(with: L10n.welcome3rdScreenTitle,
                                             message: L10n.welcome3rdScreenMessage,
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
        navigationItem.backBarButtonItem = UIBarButtonItem.grayBarButtonItem

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
        disclaimerLabel.font = FontFamily.Roboto.regular.font(size: 12)
        disclaimerLabel.textColor = UIColor.white

        let string = L10n.welcomeScreenDisclaimer
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
    }

    @objc func openTermsOfService() {
        let tos = RemoteConfig.current?.termsOfService ?? defaultTosURL

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
        let phoneVerification = StoryboardScene.Onboard.phoneVerificationRequestViewController.instantiate()
        navigationController?.pushViewController(phoneVerification, animated: true)
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
        let pageFloat = scrollView.contentOffset.x / scrollView.frame.width
        let page = Int(round(pageFloat))

        if page != pageControl.currentPage {
            pageControl.currentPage = Int(page)
        }
    }

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        logViewedPage()
    }

    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            logViewedPage()
        }
    }
}
