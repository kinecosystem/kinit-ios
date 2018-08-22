//
//  RestoreBackupQRScannerViewController.swift
//  KinWallet
//
//  Copyright © 2018 KinFoundation. All rights reserved.
//

import UIKit
import KinitDesignables

class RestoreBackupQRScannerViewController: UIViewController {
    let qrCodeScannerViewController = QRCodeScannerViewController()
    var scanningLineBottomConstraint: NSLayoutConstraint!
    var scanningLineTopConstraint: NSLayoutConstraint?

    @IBOutlet weak var introView: UIVisualEffectView!

    @IBOutlet weak var startScanningButton: UIButton! {
        didSet {
           startScanningButton.setTitle(L10n.startAction, for: .normal)
            startScanningButton.makeKinButtonFilled()
        }
    }

    @IBOutlet weak var titleLabel: UILabel! {
        didSet {
            titleLabel.text = L10n.restoreBackupScanTitle
            titleLabel.font = FontFamily.Roboto.medium.font(size: 22)
        }
    }

    @IBOutlet weak var messageLabel: UILabel! {
        didSet {
            messageLabel.text = L10n.restoreBackupScanSubtitle
            messageLabel.font = FontFamily.Roboto.regular.font(size: 16)
        }
    }

    let scanningLine: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.backgroundColor = UIColor.white
        v.heightAnchor.constraint(equalToConstant: 1).isActive = true

        let gradientView = GradientView()
        gradientView.backgroundColor = .clear
        gradientView.direction = .vertical
        gradientView.translatesAutoresizingMaskIntoConstraints = false
        v.addSubview(gradientView)
        gradientView.colors = [.clear,
                               UIColor.white.withAlphaComponent(0.2),
                               .clear]
        gradientView.heightAnchor.constraint(equalToConstant: 20).isActive = true
        gradientView.leadingAnchor.constraint(equalTo: v.leadingAnchor).isActive = true
        gradientView.trailingAnchor.constraint(equalTo: v.trailingAnchor).isActive = true
        gradientView.centerYAnchor.constraint(equalTo: v.centerYAnchor).isActive = true

        return v
    }()

    @IBOutlet weak var fakeNavigationBar: UIVisualEffectView!

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.backBarButtonItem = UIBarButtonItem.grayBarButtonItem

        qrCodeScannerViewController.delegate = self
        addAndFit(qrCodeScannerViewController)
        view.sendSubview(toBack: qrCodeScannerViewController.view)

        scanningLine.alpha = 0
        view.addSubview(scanningLine)
        scanningLine.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        scanningLine.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        scanningLineBottomConstraint = scanningLine.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        scanningLineBottomConstraint.isActive = true
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        qrCodeScannerViewController.start()
        introView.alpha = 1
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }

    @IBAction func cancel(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }

    private func animateScanningLine() {
        self.scanningLine.alpha = 1
        UIView.animate(withDuration: 1.6, delay: 0, options: [.autoreverse, .repeat], animations: {
            self.scanningLineBottomConstraint.isActive = false
            if self.scanningLineTopConstraint == nil {
                self.scanningLineTopConstraint
                    = self.scanningLine.topAnchor.constraint(equalTo: self.fakeNavigationBar.bottomAnchor)
            }

            self.scanningLineTopConstraint?.isActive = true
            self.view.layoutIfNeeded()
        }, completion: nil)
    }

    @IBAction func startScanning(_ sender: Any) {
        UIView.animate(withDuration: 0.3, animations: {
            self.introView.alpha = 0
        }, completion: { _ in
            self.animateScanningLine()
        })
    }
}

extension RestoreBackupQRScannerViewController: QRCodeScannerDelegate {
    func scannerDidFind(code: String) {
        let restoreQuestionsVC = StoryboardScene.Onboard.restoreBackupQuestionsViewController.instantiate()
        restoreQuestionsVC.encryptedWallet = code
        navigationController?.pushViewController(restoreQuestionsVC, animated: true)

        scanningLine.alpha = 0
        scanningLine.layer.removeAllAnimations()
        scanningLineTopConstraint?.isActive = false
        scanningLineBottomConstraint.isActive = true
    }

    func scannerDidFail() {
        //show alert
    }
}
