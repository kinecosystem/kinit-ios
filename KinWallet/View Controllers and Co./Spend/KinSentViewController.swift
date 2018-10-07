//
//  KinSentViewController.swift
//  Kinit
//

import UIKit

class KinSentViewController: UIViewController {
    var amount: UInt64 = 0
    @IBOutlet weak var amountLabel: UILabel!
    @IBOutlet weak var kinDeliveredLabel: UILabel! {
        didSet {
            kinDeliveredLabel.text = L10n.kinDelivered
        }
    }

    var sendKinScreenshot: UIImage?

    override func viewDidLoad() {
        super.viewDidLoad()

        assert(amount > 0)

        let formattedAmount = KinAmountFormatter().string(from: NSNumber(value: amount))!
        let message = L10n.kinSentMessage(formattedAmount)
        let kRange = (message as NSString).range(of: " K ")
        let attributedMessage = NSMutableAttributedString(string: message)
        attributedMessage.addAttribute(.font, value: FontFamily.KinK.regular.font(size: 10), range: kRange)
        amountLabel.attributedText = attributedMessage

        navigationController?.interactivePopGestureRecognizer?.isEnabled = false

        let blue = UIColor.kin.blue

        if let screenshotImage = sendKinScreenshot {
            let screenshotImageView = UIImageView()
            let screenshotWithTintEffect = screenshotImage.applyTintEffect(with: blue)
            screenshotImageView.image = screenshotWithTintEffect

            view.insertSubview(screenshotImageView, at: 0)
            screenshotImageView.fitInSuperview()
        } else {
            let blueOverlayView = UIView()
            blueOverlayView.backgroundColor = blue.withAlphaComponent(0.8)
            view.insertSubview(blueOverlayView, at: 0)
            blueOverlayView.fitInSuperview()
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(viewTapped))
        view.addGestureRecognizer(tapGesture)

        Events.Analytics
            .ViewSuccessMessageOnSendKinPage(kinAmount: Float(amount))
            .send()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        navigationController?.setNavigationBarHidden(true, animated: animated)
    }

    @objc func viewTapped() {
        dismiss(animated: true)
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
}
