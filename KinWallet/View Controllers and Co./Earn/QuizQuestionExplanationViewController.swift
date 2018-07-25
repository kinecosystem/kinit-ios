//
//  QuizQuestionExplanationViewController.swift
//  KinWallet
//
//  Copyright © 2018 KinFoundation. All rights reserved.
//

import UIKit

protocol QuizQuestionExplanationDelegate: class {
    func quizQuestionExplanationDidTapNext()
}

class QuizQuestionExplanationViewController: UIViewController {
    weak var delegate: QuizQuestionExplanationDelegate?
    var explanation: String!

    @IBOutlet weak var tapToContinueLabel: UILabel! {
        didSet {
            tapToContinueLabel.text = L10n.tapToContinue
            tapToContinueLabel.font = FontFamily.Roboto.bold.font(size: 16)
            tapToContinueLabel.textColor = UIColor.kin.gray
            tapToContinueLabel.alpha = 0
        }
    }

    @IBOutlet weak var explanationLabel: UILabel! {
        didSet {
            explanationLabel.font = FontFamily.Roboto.regular.font(size: 26)
            explanationLabel.textColor = UIColor.kin.appTint
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        explanationLabel.text = explanation
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        UIView.animate(withDuration: 0.5, delay: 0.7, options: [], animations: {
            self.tapToContinueLabel.alpha = 0.7
        }, completion: { [weak self] _ in
            self?.tapToContinueLabelShown()
        })
    }

    private func tapToContinueLabelShown() {
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(viewTapped(_:)))
        view.addGestureRecognizer(tapGestureRecognizer)

        UIView.animate(withDuration: 1,
                       delay: 0,
                       options: [.curveEaseInOut, .autoreverse, .repeat],
                       animations: { [weak self] in
                        self?.tapToContinueLabel.alpha = 0
            }, completion: nil)
    }

    @objc func viewTapped(_ sender: Any) {
        delegate?.quizQuestionExplanationDidTapNext()
    }
}
