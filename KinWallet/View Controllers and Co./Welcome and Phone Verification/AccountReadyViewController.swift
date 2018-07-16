//
//  AccountReadyViewController.swift
//  Kinit
//

import UIKit

class AccountReadyViewController: UIViewController {
    @IBOutlet weak var confettiView: ConfettiView!

    @IBOutlet weak var titleLabel: UILabel! {
        didSet {
            titleLabel.textColor = UIColor.kin.appTint
            titleLabel.font = FontFamily.Roboto.black.font(size: 42)
            titleLabel.text = L10n.accountReadyTitle
        }
    }

    @IBOutlet weak var descriptionLabel: UILabel! {
        didSet {
            descriptionLabel.textColor = UIColor.kin.gray
            descriptionLabel.font = FontFamily.Roboto.regular.font(size: 16)
            descriptionLabel.text = L10n.accountReadyMessage
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(viewTapped))
        view.addGestureRecognizer(tapGesture)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        confettiView.start()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        logViewedPage()
        logFinishedVerification()

        FeedbackGenerator.notifySuccessIfAvailable()
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) { [weak self] in
            self?.startUsingApp()
        }
    }

    @objc func viewTapped() {
        startUsingApp()
    }

    func startUsingApp() {
        UserDefaults.standard.removeObject(forKey: startedPhoneVerificationKey)
        let dismissedSplash = AppDelegate.shared.dismissSplashIfNeeded()

        if !dismissedSplash {
            dismiss(animated: true, completion: nil)
        }
    }
}

extension AccountReadyViewController {
    fileprivate func logViewedPage() {
        Events.Analytics.ViewOnboardingCompletedPage().send()
    }

    fileprivate func logFinishedVerification() {
        Events.Business.UserVerified().send()
    }
}
