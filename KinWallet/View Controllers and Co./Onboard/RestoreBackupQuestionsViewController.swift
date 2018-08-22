//
//  RestoreBackupQuestionsViewController.swift
//  KinWallet
//
//  Copyright © 2018 KinFoundation. All rights reserved.
//

import Foundation

class RestoreBackupHeaderCell: UITableViewCell {
    @IBOutlet weak var titleLabel: UILabel! {
        didSet {
            titleLabel.font = FontFamily.Roboto.medium.font(size: 22)
            titleLabel.textColor = UIColor.kin.darkGray
            titleLabel.text = L10n.restoreBackupQuestionsTitle
        }
    }

    @IBOutlet weak var subtitleLabel: UILabel! {
        didSet {
            subtitleLabel.font = FontFamily.Roboto.regular.font(size: 16)
            subtitleLabel.textColor = UIColor.kin.gray
            subtitleLabel.text = L10n.restoreBackupQuestionsSubtitle
        }
    }
}

class RestoreBackupQuestionCell: UITableViewCell {
    static let fontFamily = FontFamily.Roboto.self

    @IBOutlet weak var questionLabel: UILabel! {
        didSet {
            questionLabel.font = RestoreBackupQuestionCell.fontFamily.regular.font(size: 14)
            questionLabel.textColor = UIColor.kin.gray
        }
    }

    @IBOutlet weak var titleLabel: UILabel! {
        didSet {
            titleLabel.font = FontFamily.Roboto.medium.font(size: 16)
            titleLabel.textColor = UIColor.kin.darkGray
            titleLabel.text = L10n.restoreBackupYourAnswerTitle
        }
    }

    @IBOutlet weak var textField: UITextField! {
        didSet {
            textField.placeholder = L10n.restoreBackupYourAnswerPlaceholder
            textField.makeBackupTextField()
        }
    }
}

class RestoreBackupActionCell: UITableViewCell {
    let actionButton = ButtonAccessoryInputView.nextActionButton()

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        contentView.addAndCenter(actionButton)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class RestoreBackupQuestionsViewController: UITableViewController {
    var questions = [String]()
    var backupString: String!

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.register(class: RestoreBackupActionCell.self)
        guard let storedHints: SelectedHintIds = SimpleDatastore.loadObject(selectedHintIdsKey) else {
            fatalError("Got to RestoreBackupQuestionsViewController but no stored hint ids")
        }

        let storedHintsIds = storedHints.hints

        KinLoader.shared.fetchAvailableBackupHints { [weak self] hints in
            DispatchQueue.main.async {
                guard let `self` = self else {
                    return
                }

                self.questions = storedHintsIds.map { hintId in
                    hints.first(where: { $0.id == hintId })!.text
                }

                self.tableView.insertSections(IndexSet(integersIn: (1...2)), with: .fade)
            }
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        navigationController?.setNavigationBarHidden(false, animated: animated)
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return questions.isEmpty ? 1 : 3
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0, 2: return 1
        case 1: return questions.count
        default: fatalError("RestoreBackupQuestionViewController should have only 3 sections")
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            return tableView.dequeueReusableCell(forIndexPath: indexPath) as RestoreBackupHeaderCell
        }

        if indexPath.section == 1 {
            let cell = tableView.dequeueReusableCell(forIndexPath: indexPath) as RestoreBackupQuestionCell
            cell.textField.delegate = self
            NotificationCenter.default.addObserver(self,
                                                   selector: #selector(textDidChangeNotification(_:)),
                                                   name: .UITextFieldTextDidChange,
                                                   object: nil)
            let question = questions[indexPath.row]
            let attributedQuestion = NSMutableAttributedString(string: "Q\(indexPath.row + 1): \(question)")
            attributedQuestion.addAttribute(.font,
                                            value: RestoreBackupQuestionCell.fontFamily.bold.font(size: 14),
                                            range: NSRange(location: 0, length: 3))
            cell.questionLabel.attributedText = attributedQuestion

            return cell
        }

        defer {
            verifyActionButtonState()
        }

        let actionCell = tableView.dequeueReusableCell(forIndexPath: indexPath) as RestoreBackupActionCell
        actionCell.actionButton.isEnabled = areAnswersValid

        return actionCell
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.section {
        case 0: return 120
        case 1: return 150
        case 2: return ButtonAccessoryInputView.intrinsicHeight
        default: fatalError("RestoreBackupQuestionViewController should have only 3 sections")
        }
    }

    var areAnswersValid: Bool {
        guard
            let firstQuestionCell = tableView.cellForRow(at: IndexPath(row: 0, section: 1))
                as? RestoreBackupQuestionCell,
            let secondQuestionCell = tableView.cellForRow(at: IndexPath(row: 1, section: 1))
                as? RestoreBackupQuestionCell else {
                return false
        }

        return firstQuestionCell.textField.textOrEmpty.count >= 4
            && secondQuestionCell.textField.textOrEmpty.count >= 4
    }

    @objc func textDidChangeNotification(_ sender: Any) {
        verifyActionButtonState()
    }

    private func verifyActionButtonState() {
        guard let actionCell = tableView.cellForRow(at: IndexPath(row: 0, section: 2))
            as? RestoreBackupActionCell else {
            return
        }

        actionCell.actionButton.isEnabled = areAnswersValid
    }
}

extension RestoreBackupQuestionsViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        guard
            let firstQuestionCell = tableView.cellForRow(at: IndexPath(row: 0, section: 1))
                as? RestoreBackupQuestionCell,
            let secondQuestionCell = tableView.cellForRow(at: IndexPath(row: 1, section: 1))
                as? RestoreBackupQuestionCell else {
                    return false
        }

        if textField == firstQuestionCell.textField {
            if textField.textOrEmpty.isBackupStringValid {
                secondQuestionCell.textField.becomeFirstResponder()
                tableView.scrollToRow(at: IndexPath(row: 1, section: 1),
                                      at: .bottom,
                                      animated: true)
            }
        } else if textField == secondQuestionCell.textField {
            if textField.textOrEmpty.isBackupStringValid {
                tableView.scrollToRow(at: IndexPath(row: 0, section: 2),
                                      at: .bottom,
                                      animated: true)
            }
        }

        return false
    }

    func textField(_ textField: UITextField,
                     shouldChangeCharactersIn range: NSRange,
                     replacementString string: String) -> Bool {
        guard let currentText = textField.text else {
            return false
        }

        let newText = (currentText as NSString).replacingCharacters(in: range, with: string)
        if newText.count < currentText.count {
            return true
        } else if string == " " {
            return currentText.count >= 4
        } else if newText.hasSpaceBefore(index: 4) {
            return false
        }

        return true
    }
}

extension String {
    var isBackupStringValid: Bool {
        guard count >= 4 else {
            return false
        }

        guard rangeOfCharacter(from: CharacterSet.alphanumericsAndWhiteSpace.inverted) == nil else {
            return false
        }

        guard !hasSpaceBefore(index: 4) else {
            return false
        }

        return true
    }

    func hasSpaceBefore(index: Int) -> Bool {
        let spaceRange = (self as NSString).range(of: " ").location
        return spaceRange != NSNotFound && spaceRange < index
    }
}

extension CharacterSet {
    static var alphanumericsAndWhiteSpace: CharacterSet {
        return CharacterSet.alphanumerics.union(.whitespaces)
    }
}
