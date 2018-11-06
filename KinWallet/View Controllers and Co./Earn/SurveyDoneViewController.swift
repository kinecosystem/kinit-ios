//
//  SurveyDoneViewController.swift
//  Kinit
//

import UIKit

final class SurveyDoneViewController: UIViewController {
    private struct Constants {
        static let doneSignInitialScale: CGFloat = 0.8
        static let fireworksInitialScale: CGFloat = 0.2
        static let fireworksInitialAlpha: CGFloat = 0.2
        static let doneAnimationDuration: TimeInterval = 1
        static let doneAnimationVelocity: CGFloat = 0.6
        static let doneAnimationDamping: CGFloat = 0.7
    }

    @IBOutlet weak var fireworksImageView: UIImageView!
    @IBOutlet weak var doneSignImageView: UIImageView!

    @IBOutlet weak var titleLabel: UILabel! {
        didSet {
            titleLabel.font = FontFamily.Roboto.bold.font(size: 24)
            titleLabel.text = L10n.ActivityDone.title
        }
    }

    @IBOutlet weak var subtitleLabel: UILabel! {
        didSet {
            subtitleLabel.font = FontFamily.Roboto.regular.font(size: 16)
            subtitleLabel.text = L10n.ActivityDone.message
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .clear
        prepareViewForAnimations()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        FeedbackGenerator.notifySuccessIfAvailable()
        animateDone()
    }

    func prepareViewForAnimations() {
        let sScale = Constants.doneSignInitialScale
        doneSignImageView.transform = CGAffineTransform(translationX: 0, y: doneSignImageView.frame.height + 20)
            .concatenating(CGAffineTransform(scaleX: sScale, y: sScale))
        let fScale = Constants.fireworksInitialScale
        fireworksImageView.transform = CGAffineTransform(scaleX: fScale, y: fScale)
        fireworksImageView.alpha = Constants.fireworksInitialAlpha
    }

    func animateDone() {
        UIView.animate(withDuration: Constants.doneAnimationDuration,
                       delay: 0,
                       usingSpringWithDamping: Constants.doneAnimationDamping,
                       initialSpringVelocity: Constants.doneAnimationVelocity,
                       options: [],
                       animations: {
                        self.doneSignImageView.transform = .identity
                        self.fireworksImageView.transform = .identity
                        self.fireworksImageView.alpha = 1
        },
                       completion: nil)
    }
}
