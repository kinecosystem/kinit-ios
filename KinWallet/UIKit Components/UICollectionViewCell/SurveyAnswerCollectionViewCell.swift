//
//  SurveyAnswerCollectionViewCell.swift
//  Kinit
//

import UIKit

protocol SurveyAnswerDelegate: class {
    func surveyAnswerCellDidStartSelecting(_ cell: SurveyAnswerCollectionViewCell)
    func surveyAnswerCellDidSelect(_ cell: SurveyAnswerCollectionViewCell)
    func surveyAnswerCellDidDeselect(_ cell: SurveyAnswerCollectionViewCell)
    func surveyAnswerCellDidCancelSelecting(_ cell: SurveyAnswerCollectionViewCell)
}

private struct Constants {
    struct Normal {
        static let textColor = UIColor.kin.gray
    }

    struct Highlighted {
        static let textColor = UIColor.white
    }
}

class SurveyAnswerCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var touchUpEffectControl: UIControl!
    @IBOutlet weak var backgroundImageView: UIImageView?

    var animatingTouchStart = false
    var animatingTouchEnd = false
    weak var delegate: SurveyAnswerDelegate?
    var didToggleAnswer = false
    var indexPath: IndexPath!
    var isTouchHappening = false

    override var isSelected: Bool {
        didSet {
            applySelectedLook(isSelected)
        }
    }

    func applySelectedLook(_ selected: Bool) {
        titleLabel?.textColor = selected ? Constants.Highlighted.textColor : Constants.Normal.textColor
        backgroundImageView?.image = selected ? selectedBackgroundImage : backgroundImage
    }

    override func awakeFromNib() {
        super.awakeFromNib()

        titleLabel?.textColor = Constants.Normal.textColor
        titleLabel?.font = FontFamily.Roboto.regular.font(size: 16)
        touchUpEffectControl.addTarget(self, action: #selector(didTouchUpInside(_:)), for: .touchUpInside)
        touchUpEffectControl.addTarget(self, action: #selector(didStartTouching(_:)), for: .touchDown)
        touchUpEffectControl.addTarget(self, action: #selector(didStartTouching(_:)), for: .touchDragEnter)
        touchUpEffectControl.addTarget(self, action: #selector(didEndTouching(_:)), for: .touchDragOutside)
    }

    var titleLabel: UILabel? {
        return nil
    }

    var imageView: UIImageView? {
        return nil
    }

    var backgroundImage: UIImage? {
        return nil
    }

    var selectedBackgroundImage: UIImage? {
        return nil
    }

    @objc func didTouchUpInside(_ sender: UIControl) {
        guard !animatingTouchStart else {
            didToggleAnswer = true
            return
        }

        commitToggleSelection(sender)
        isTouchHappening = false
    }

    @objc func didStartTouching(_ sender: UIControl) {
        if animatingTouchStart || animatingTouchEnd {
            return
        }

        isTouchHappening = true

        applySelectedLook(!isSelected)

        delegate?.surveyAnswerCellDidStartSelecting(self)
        animatingTouchStart = true

        touchUpEffectControl.beginTouchUpEffect { [weak self] _ in
            guard let aSelf = self else {
                return
            }

            aSelf.animatingTouchStart = false

            if aSelf.didToggleAnswer {
                aSelf.commitToggleSelection(sender)
            }
        }
    }

    func commitToggleSelection(_ sender: UIControl) {
        didEndTouching(sender)
        isSelected.toggle()

        if isSelected {
            delegate?.surveyAnswerCellDidSelect(self)
        } else {
            delegate?.surveyAnswerCellDidDeselect(self)
        }

        didToggleAnswer = false
    }

    @objc func didEndTouching(_ sender: UIControl) {
        isTouchHappening = false

        if animatingTouchStart || animatingTouchEnd {
            return
        }

        finishTouching(force: false)
    }

    func cancelTouchIfNeeded() {
        guard isTouchHappening else {
            return
        }

        finishTouching(force: true)
    }

    private func finishTouching(force: Bool) {
        animatingTouchEnd = true
        touchUpEffectControl.endTouchUpEffect { [weak self] _ in
            self?.animatingTouchEnd = false
            self?.isTouchHappening = false
        }

        if !didToggleAnswer || force {
            delegate?.surveyAnswerCellDidCancelSelecting(self)
            applySelectedLook(isSelected)
        }
    }
}

class SurveyViewsFactory {
    class func drawCell(_ cell: SurveyAnswerCollectionViewCell, for result: Result, questionType: QuestionType) {
        cell.titleLabel?.accessibilityIdentifier = result.identifier
        cell.imageView?.accessibilityIdentifier = result.identifier

        if questionType == .textEmoji,
            let text = result.text,
            let emoji = text.split(separator: " ").first,
            emoji.unicodeScalars.contains(where: { $0.isEmoji }) {
            let range = (text as NSString).range(of: String(emoji))
            let attributedAnswer = NSMutableAttributedString(string: text,
                                                             attributes: [.baselineOffset: 3])
            attributedAnswer.addAttributes([.font: UIFont.systemFont(ofSize: 28), .baselineOffset: 0],
                                           range: range)
            cell.titleLabel?.attributedText = attributedAnswer
            cell.titleLabel?.textAlignment = .left
        } else {
            cell.titleLabel?.text = result.text
            cell.titleLabel?.textAlignment = questionType == .multipleText
                ? .left
                : .center
        }

        if
            let imageURL = result.imageURL,
            let imageView = cell.imageView {
            imageView.loadImage(url: imageURL.kinImagePathAdjustedForDevice(),
                                placeholderColor: UIColor.kin.lightGray)
        }
    }

    class func draw(_ view: SurveyQuestionCollectionReusableView, for question: Question, size: CGSize) {
        let questionFont = FontFamily.Roboto.regular.font(size: 22)
        let attributedString = NSMutableAttributedString(string: question.text,
                                                         attributes: [.font: questionFont!,
                                                                      .foregroundColor: UIColor.kin.blue])

        if question.allowsMultipleSelection {
            let noteFont = FontFamily.Roboto.regular.font(size: 14)
            let multipleNote = NSAttributedString(string: "\n\nCheck all that apply",
                                                  attributes: [.font: noteFont!,
                                                               .foregroundColor: UIColor.kin.gray])
            attributedString.append(multipleNote)
        }

        view.questionLabel.attributedText = attributedString

        if let imageURL = question.imageURL {
            view.imageView.loadImage(url: imageURL.kinImagePathAdjustedForDevice(),
                placeholderColor: UIColor.kin.lightGray,
                size: CGSize(width: size.width, height: view.imageViewHeightConstraint.constant))
        } else {
            view.imageViewHeightConstraint.constant = 0
        }
    }
}

class SurveyImageAnswerCollectionViewCell: SurveyAnswerCollectionViewCell, NibLoadableView {
    @IBOutlet weak var aImageView: UIImageView!

    override var imageView: UIImageView? {
        return aImageView
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        let path = UIBezierPath(roundedRect: aImageView.bounds,
                                byRoundingCorners: [.allCorners],
                                cornerRadii: CGSize(width: 8, height: 8))

        let maskLayer = CAShapeLayer()
        maskLayer.path = path.cgPath
        aImageView.layer.mask = maskLayer
    }
}

class SurveyTextAnswerCollectionViewCell: SurveyAnswerCollectionViewCell, NibLoadableView {
    @IBOutlet weak var textLabel: UILabel!

    override var backgroundImage: UIImage? {
        return Asset.textAnswerShape.image
    }

    override var selectedBackgroundImage: UIImage? {
        return Asset.textAnswerShapeSelected.image
    }

    override var titleLabel: UILabel {
        return textLabel
    }
}

//swiftlint:disable:next type_name
class SurveyMultipleTextAnswerCollectionViewCell: SurveyAnswerCollectionViewCell, NibLoadableView {
    @IBOutlet weak var textLabel: UILabel!

    @IBOutlet weak var selectionStateImageView: UIImageView!

    override var titleLabel: UILabel {
        return textLabel
    }

    override var backgroundImage: UIImage? {
        return Asset.multipleAnswerBackground.image
    }

    override var selectedBackgroundImage: UIImage? {
        return Asset.multipleAnswerBackgroundSelected.image
    }

    override func applySelectedLook(_ selected: Bool) {
        super.applySelectedLook(selected)

        selectionStateImageView.image = selected
            ? Asset.multipleAnswerCheckmark.image
            : Asset.multipleAnswerPlus.image
    }
}

class SurveyTextImageAnswerCollectionViewCell: SurveyAnswerCollectionViewCell, NibLoadableView {
    @IBOutlet weak var textLabel: UILabel!
    @IBOutlet weak var aImageView: UIImageView!

    override var backgroundImage: UIImage? {
        return Asset.imageAnswerBorder.image
    }

    override var selectedBackgroundImage: UIImage? {
        return Asset.imageAnswerBorderSelected.image
    }

    override var titleLabel: UILabel {
        return textLabel
    }

    override var imageView: UIImageView? {
        return aImageView
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        let path = UIBezierPath(roundedRect: aImageView.bounds,
                                byRoundingCorners: [.topRight, .topLeft],
                                cornerRadii: CGSize(width: 8, height: 8))

        let maskLayer = CAShapeLayer()
        maskLayer.path = path.cgPath
        aImageView.layer.mask = maskLayer
    }
}
