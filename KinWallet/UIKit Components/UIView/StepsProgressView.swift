//
//  StepsProgressView.swift
//  KinWallet
//
//  Copyright © 2018 KinFoundation. All rights reserved.
//

import UIKit

private enum ProgressViewStepState {
    case doing
    case todo
    case done
}

@IBDesignable
public final class StepsProgressView: UIView {
    var stackView: UIStackView?

    struct Constants {
        static let progressViewWidth: CGFloat = 28
        static let progressViewHeight: CGFloat = 10
        static let spacing: CGFloat = 10
        static let ongoingProgress: Float = 0.35
    }

    @IBInspectable public var numberOfSteps: Int = 1 {
        didSet {
            redraw()
        }
    }

    @IBInspectable public var currentStep: Int = 0 {
        didSet {
            redraw()
        }
    }

    @IBInspectable public var trackColor: UIColor = .gray {
        didSet {
            redraw()
        }
    }

    override public var intrinsicContentSize: CGSize {
        let columnsCount = numberOfSteps - 1
        let width = Constants.progressViewWidth * CGFloat(numberOfSteps) + Constants.spacing * CGFloat(columnsCount)
        return CGSize(width: width,
                      height: Constants.progressViewHeight)
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        commonInit()
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        commonInit()
    }

    private func commonInit() {

    }

    private func redraw() {
        subviews.forEach { $0.removeFromSuperview() }

        let range = 0..<numberOfSteps
        let progressViews = range.map { step -> UIProgressView in
            let state: ProgressViewStepState = {
                if step == currentStep {
                    return .doing
                } else if currentStep < step {
                    return .todo
                } else {
                    return .done
                }
            }()

            return generateProgressView(state: state)
        }

        let stackView = UIStackView(arrangedSubviews: progressViews)
        stackView.alignment = .leading
        stackView.spacing = 8
        stackView.distribution = .fillEqually
        stackView.axis = .horizontal
        addAndFit(stackView)

        self.stackView = stackView
    }

    private func generateProgressView(state: ProgressViewStepState) -> UIProgressView {
        let progressView = UIProgressView()
        progressView.trackTintColor = trackColor
        progressView.progressTintColor = tintColor
        progressView.progress = {
            switch state {
            case .doing: return Constants.ongoingProgress
            case .todo: return 0
            case .done: return 1
            }
        }()

        return progressView
    }

    func finishCurrentProgress() {
        let currentProgressView = stackView?.arrangedSubviews
            .compactMap {
                $0 as? UIProgressView
            }.filter {
                $0.progress > 0 && $0.progress < 1
            }
            .first

        guard let progressView = currentProgressView else {
            return
        }

        UIView.animate(withDuration: 0.3) {
            progressView.setProgress(1, animated: true)
        }
    }
}
