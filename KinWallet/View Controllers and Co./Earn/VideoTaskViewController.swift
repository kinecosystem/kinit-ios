//
//  VideoTaskViewController.swift
//  Kinit
//

import UIKit
import AVKit
import KinUtil

protocol VideoTaskViewControllerDelegate: class {
    func videoTaskDidFinishPlaying()
    func videoTaskDidCancelPlaying()
}

func timeLabel() -> UILabel {
    let l = UILabel()
    l.textColor = .white
    l.font = FontFamily.Roboto.regular.font(size: 14)
    l.text = "-:--"
    l.widthAnchor.constraint(equalToConstant: 50).isActive = true
    l.textAlignment = .center
    return l
}

class VideoTaskViewController: UIViewController {
    weak var delegate: VideoTaskViewControllerDelegate?
    var videoURL: URL!
    var timeObserverToken: Any?
    var statusObserver: Any?

    let closeButton: UIButton = {
        let side: CGFloat = 60
        let b = UIButton()
        b.translatesAutoresizingMaskIntoConstraints = false
        b.tintColor = .white
        b.setImage(Asset.closeXButtonDarkGray.image.withRenderingMode(.alwaysTemplate), for: .normal)
        b.setBackgroundImage(UIImage.from(UIColor.kin.blackAlphaBackground),
                             for: .normal)
        b.widthAnchor.constraint(equalToConstant: side).isActive = true
        b.heightAnchor.constraint(equalTo: b.widthAnchor, multiplier: 1).isActive = true
        b.layer.masksToBounds = true
        b.layer.cornerRadius = side/2

        return b
    }()

    var videoControlsTimer: Timer?
    var videoControlsVisible = true
    var tapGestureEnabled = false

    let elapsedTimeLabel = timeLabel()
    let remainingTimeLabel = timeLabel()
    let dateComponentsFormatter: DateComponentsFormatter = {
        let f = DateComponentsFormatter()
        f.allowedUnits = [.minute, .second]
        f.zeroFormattingBehavior = [.pad]
        return f
    }()

    let stackViewContainer: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.backgroundColor = UIColor.kin.blackAlphaBackground
        v.layer.cornerRadius = 5
        v.layer.masksToBounds = true
        v.heightAnchor.constraint(equalToConstant: 30).isActive = true

        return v
    }()

    let playerViewController: AVPlayerViewController = {
        let p = AVPlayerViewController()
        p.view.isUserInteractionEnabled = false
        p.showsPlaybackControls = false
        return p
    }()

    let progressView: UIProgressView = {
        let p = UIProgressView()
        p.translatesAutoresizingMaskIntoConstraints = false
        p.trackTintColor = .white
        p.progressTintColor = UIColor.kin.blue
        p.progress = 0
        return p
    }()

    let activityIndicator: UIActivityIndicatorView = {
        let a = UIActivityIndicatorView(activityIndicatorStyle: .white)
        a.translatesAutoresizingMaskIntoConstraints = false
        a.hidesWhenStopped = true
        return a
    }()

    deinit {
        videoControlsTimer?.invalidate()
        videoControlsTimer = nil

        if let timeObserver = timeObserverToken {
            playerViewController.player?.removeTimeObserver(timeObserver)
            timeObserverToken = nil
        }

        statusObserver = nil
        NotificationCenter.default.removeObserver(self)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        addAndFit(playerViewController)
        playerViewController.player = AVPlayer(url: videoURL)

        addObservers()

        if #available(iOS 10.0, *) {
            playerViewController.updatesNowPlayingInfoCenter = false
        }

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(playerDidPlayToEndTime),
                                               name: .AVPlayerItemDidPlayToEndTime,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(willEnterForeground),
                                               name: .UIApplicationWillEnterForeground,
                                               object: nil)

        activityIndicator.startAnimating()
        view.addSubview(activityIndicator)
        activityIndicator.centerInSuperview()

        closeButton.addTarget(self, action: #selector(cancel), for: .touchUpInside)

        view.addSubview(stackViewContainer)
        let stackView = UIStackView(arrangedSubviews: [elapsedTimeLabel, progressView, remainingTimeLabel])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.distribution = .fill
        stackView.alignment = .center
        stackViewContainer.addAndFit(stackView)
        view.addSubview(closeButton)
        setupConstraints(bottomView: stackViewContainer)

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(toggleControlsVisibility))
        view.addGestureRecognizer(tapGesture)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        setOrientation(.landscapeRight)
        Events.Analytics.ViewVideoPage().send()
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .allButUpsideDown
    }

    private func setupConstraints(bottomView: UIView) {
        let leadingAnchor: NSLayoutXAxisAnchor
        let trailingAnchor: NSLayoutXAxisAnchor
        let bottomAnchor: NSLayoutYAxisAnchor
        let topAnchor: NSLayoutYAxisAnchor

        if #available(iOS 11.0, *) {
            leadingAnchor = view.safeAreaLayoutGuide.leadingAnchor
            trailingAnchor = view.safeAreaLayoutGuide.trailingAnchor
            bottomAnchor = view.safeAreaLayoutGuide.bottomAnchor
            topAnchor = view.safeAreaLayoutGuide.topAnchor
        } else {
            leadingAnchor = view.leadingAnchor
            trailingAnchor = view.trailingAnchor
            bottomAnchor = view.bottomAnchor
            topAnchor = view.topAnchor
        }

        bottomView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 60).isActive = true
        bottomView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -60).isActive = true
        bottomView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -30).isActive = true

        closeButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20).isActive = true
        closeButton.topAnchor.constraint(equalTo: topAnchor, constant: 20).isActive = true
    }

    private func addObservers() {
        statusObserver = playerViewController.player?
            .observe(\.status) { [unowned self] _, _ in
                guard let player = self.playerViewController.player else {
                        return
                }

                if player.status == .readyToPlay {
                    if self.activityIndicator.isAnimating {
                        self.activityIndicator.stopAnimating()
                    }

                    player.play()

                    self.tapGestureEnabled = true
                    self.startTimerToHideControls()
                } else {
                    if !self.activityIndicator.isAnimating {
                        self.activityIndicator.startAnimating()
                    }
                }
        }

        let timeBlock: (CMTime) -> Void = { [unowned self] time in
            guard let item = self.playerViewController.player?.currentItem else {
                return
            }

            let past = Double(CMTimeGetSeconds(time))
            let total = Double(CMTimeGetSeconds(item.duration))
            let remaining = total - past
            let progress = past / total

            self.elapsedTimeLabel.text = self.dateComponentsFormatter.string(from: past)
            self.remainingTimeLabel.text = self.dateComponentsFormatter.string(from: remaining)

            if progress > 0 {
                self.progressView.progress = Float(progress)
            }
        }

        timeObserverToken = playerViewController.player?.addPeriodicTimeObserver(forInterval: CMTimeMake(1, 60),
                                                                                 queue: .main,
                                                                                 using: timeBlock)
    }

    private func startTimerToHideControls() {
        videoControlsTimer?.invalidate()
        videoControlsTimer = Timer.scheduledTimer(timeInterval: 3,
                                                  target: self,
                                                  selector: #selector(hideControlsIfNeeded),
                                                  userInfo: nil,
                                                  repeats: false)
    }

    @objc private func willEnterForeground() {
        playerViewController.player?.play()
    }

    @objc private func hideControlsIfNeeded() {
        guard videoControlsVisible else {
            return
        }

        toggleControlsVisibility()
    }

    @objc private func toggleControlsVisibility() {
        guard tapGestureEnabled else {
            KLogDebug("Tap gesture not enabled. Doing nothing yet.")
            return
        }

        videoControlsVisible.toggle()

        UIView.animate(withDuration: 0.2) {
            [self.closeButton, self.stackViewContainer].forEach {
                $0.alpha = self.videoControlsVisible ? 1 : 0
            }
        }

        if videoControlsVisible {
            startTimerToHideControls()
        }
    }

    @objc func playerDidPlayToEndTime() {
        setOrientation(.portrait)
        delegate?.videoTaskDidFinishPlaying()
    }

    @objc func cancel() {
        setOrientation(.portrait)
        delegate?.videoTaskDidCancelPlaying()
    }
}
