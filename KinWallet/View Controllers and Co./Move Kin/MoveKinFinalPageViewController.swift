//
//  MoveKinFinalPageViewController.swift
//  KinWallet
//
//  Copyright © 2019 KinFoundation. All rights reserved.
//

import UIKit
import KinitDesignables

class MoveKinFinalPageViewController: UIViewController {
    var finishHandler: (() -> Void)?

    let gradientView: GradientView = {
        let v = GradientView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.direction = .vertical

        return v
    }()

    let titleLabel: UILabel = {
        let l = UILabel()
        l.translatesAutoresizingMaskIntoConstraints = false
        l.font = FontFamily.Roboto.regular.font(size: 20)
        l.numberOfLines = 1
        l.textColor = .white
        l.textAlignment = .center

        return l
    }()

    let subtitleLabel: UILabel = {
        let l = UILabel()
        l.translatesAutoresizingMaskIntoConstraints = false
        l.font = FontFamily.Roboto.regular.font(size: 14)
        l.numberOfLines = 2
        l.textColor = .white
        l.textAlignment = .center

        return l
    }()

    let tapToFinishLabel: UILabel = {
        let l = UILabel()
        l.translatesAutoresizingMaskIntoConstraints = false
        l.font = FontFamily.Roboto.regular.font(size: 16)
        l.textColor = .white
        l.text = L10n.tapToFinish
        l.alpha = 0

        return l
    }()

    override func loadView() {
        let v = UIView()
        v.backgroundColor = .white
        v.addAndFit(gradientView)

        let stackView = UIStackView(arrangedSubviews: [titleLabel, subtitleLabel])
        stackView.widthAnchor.constraint(equalToConstant: 240).isActive = true
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.spacing = 20
        v.addAndCenter(stackView)

        v.addSubview(tapToFinishLabel)
        v.centerXAnchor.constraint(equalTo: tapToFinishLabel.centerXAnchor).isActive = true
        if #available(iOS 11.0, *) {
            v.safeAreaLayoutGuide.bottomAnchor.constraint(equalTo: tapToFinishLabel.bottomAnchor,
                                                          constant: 105).isActive = true
        } else {
            v.bottomAnchor.constraint(equalTo: tapToFinishLabel.bottomAnchor, constant: 105).isActive = true
        }

        view = v
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(backgroundTapped))
        view.addGestureRecognizer(tapGestureRecognizer)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        UIView.animate(withDuration: 1,
                       delay: 0,
                       options: [.curveEaseInOut, .autoreverse, .repeat],
                       animations: {
                        self.tapToFinishLabel.alpha = 0.7
        }, completion: nil)
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    @objc func backgroundTapped() {
        finishHandler?()
    }
}
