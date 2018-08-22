//
//  BackupQuestionViewController.swift
//  KinWallet
//
//  Copyright © 2018 KinFoundation. All rights reserved.
//

import UIKit
import KinitDesignables

class BackupQuestionViewController: BackupTextInputViewController {
    var step: BackupStep!
    var chosenHints: [(Int, String)]?
    var availableHints: [AvailableBackupHint]!
    var selectedHintId: Int?

    @IBOutlet weak var stepsProgressView: StepsProgressView!
    @IBOutlet weak var answerStackView: UIStackView!

    @IBOutlet weak var answerTitleLabel: UILabel! {
        didSet {
            answerTitleLabel.text = L10n.backupYourAnswerTitle
            answerTitleLabel.font = FontFamily.Roboto.medium.font(size: 16)
            answerTitleLabel.textColor = UIColor.kin.darkGray
        }
    }

    @IBOutlet weak var titleLabel: UILabel! {
        didSet {
            titleLabel.font = FontFamily.Roboto.medium.font(size: 22)
            titleLabel.textColor = UIColor.kin.darkGray
            titleLabel.text = L10n.securityQuestionsTitle
        }
    }

    @IBOutlet weak var subtitleLabel: UILabel! {
        didSet {
            subtitleLabel.font = FontFamily.Roboto.regular.font(size: 16)
            subtitleLabel.textColor = UIColor.kin.gray
            subtitleLabel.text = L10n.securityQuestionsSubtitle
        }
    }

    @IBOutlet weak var questionNumberLabel: UILabel! {
        didSet {
            questionNumberLabel.font = FontFamily.Roboto.medium.font(size: 16)
            questionNumberLabel.textColor = UIColor.kin.appTint
        }
    }

    @IBOutlet weak var chooseQuestionLabel: UILabel! {
        didSet {
            chooseQuestionLabel.textColor = UIColor.kin.gray
            chooseQuestionLabel.font = FontFamily.Roboto.medium.font(size: 16)
            chooseQuestionLabel.text = L10n.chooseSecurityQuestion
        }
    }

    @IBOutlet weak var pickerArrow: UIImageView!

    @IBOutlet var tableViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet var tableViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableView.tableFooterView = UIView()
        }
    }

    var animatingTableView = false

    var isTableViewOpen: Bool {
        return tableViewBottomConstraint.isActive
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setAnswerStackViewHidden(true, animated: false)
        tableViewHeightConstraint.constant = 0
        NSLayoutConstraint.deactivate([tableViewBottomConstraint])
        questionNumberLabel.text = step.title
        observationLabel.text = L10n.backupMinimum4Characters
        textField.placeholder = L10n.backupYourAnswerPlaceholder

        stepsProgressView.currentStep = step.rawValue
    }

    @IBAction func chooseQuestionTapped(_ sender: Any) {
        toggleQuestionsList()
    }

    fileprivate func toggleQuestionsList(completion: (() -> Void)? = nil) {
        guard !animatingTableView else {
            return
        }

        animatingTableView = true

        let isOpen = isTableViewOpen

        if !isOpen {
            view.endEditing(true)
        }

        let toActivate = isOpen
            ? tableViewHeightConstraint
            : tableViewBottomConstraint
        let toDeactivate = isOpen
            ? tableViewBottomConstraint
            : tableViewHeightConstraint

        UIView.animate(withDuration: 0.3, animations: { [weak self] in
            NSLayoutConstraint.activate([toActivate!])
            NSLayoutConstraint.deactivate([toDeactivate!])
            self?.pickerArrow.transform =  self!.pickerArrow.transform.rotated(by: CGFloat.pi)
            self?.view.layoutIfNeeded()
            }, completion: { [weak self] _ in
                completion?()
                self?.animatingTableView = false

                guard self?.selectedHintId != nil  else {
                    return
                }

                self?.setAnswerStackViewHidden(!isOpen)

                if isOpen {
                    self?.textField.becomeFirstResponder()
                    self?.accessoryView.isEnabled = false
                }
        })
    }

    fileprivate func setAnswerStackViewHidden(_ hidden: Bool, animated: Bool = true) {
        UIView.animate(withDuration: animated ? 0.3 : 0) { [weak self] in
            self?.answerStackView.arrangedSubviews.forEach { $0.alpha = hidden ? 0 : 1 }
        }
    }

    override func isInputTextValid(text: String? = nil) -> Bool {
        return (text ?? textField.textOrEmpty).isBackupStringValid
    }

    override func moveToNextStep() {
        guard
            let thisHintId = selectedHintId,
            isInputTextValid() else {
                let e = "BackupQuestionViewController received moveToNextStep without selectedHintId or answerTextField"
                fatalError(e)
        }

        let answer = textField.textOrEmpty

        chosenHints = chosenHints ?? []
        chosenHints!.append((thisHintId, answer))

        if step == .firstQuestion {
            let secondQuestion = StoryboardScene.Backup.backupQuestionViewController.instantiate()
            secondQuestion.step = .secondQuestion
            secondQuestion.chosenHints = chosenHints!
            secondQuestion.availableHints = availableHints.filter {
                $0.id != thisHintId
            }
            navigationController?.pushViewController(secondQuestion, animated: true)

        } else if step == .secondQuestion {
            accessoryView.isLoading = true

            DispatchQueue.global().async {
                guard let encryptedWallet = try? self.encryptWallet() else {
                    //TODO: handle error
                    DispatchQueue.main.async {
                        self.accessoryView.isLoading = false
                    }

                    return
                }

                DispatchQueue.main.async {
                    self.accessoryView.isLoading = false
                    let sendEmailViewController = StoryboardScene.Backup.backupSendEmailViewController.instantiate()
                    sendEmailViewController.chosenHints = self.chosenHints!.map { $0.0 }
                    sendEmailViewController.encryptedWallet = encryptedWallet
                    self.navigationController?.pushViewController(sendEmailViewController, animated: true)
                }
            }
        } else {
            fatalError("BackupQuestionViewController can only have step set to .firstQuestion or .secondQuestion")
        }
    }

    private func encryptWallet() throws -> String {
        let passphrase = chosenHints!.map { $1 }.joined()
        return try Kin.shared.exportWallet(with: passphrase)
    }
}

extension BackupQuestionViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return availableHints.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "BackupQuestionCellIdentifier", for: indexPath)
        cell.textLabel?.textColor = UIColor.kin.gray
        cell.textLabel?.font = FontFamily.Roboto.regular.font(size: 16)
        cell.textLabel?.text = availableHints[indexPath.item].text

        return cell
    }
}

extension BackupQuestionViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selected = availableHints[indexPath.item]
        chooseQuestionLabel.text = selected.text
        textField.text = nil

        selectedHintId = selected.id

        guard isTableViewOpen else {
            return
        }

        toggleQuestionsList { [weak self] in
            UIView.animate(withDuration: 0.3) { [weak self] in
                guard let `self` = self else {
                    return
                }

                if self.titleStackViewTopConstraint.constant > 0 {
                    let delta = self.questionNumberLabel.frame.minY - self.titleStackViewTopConstraint.constant
                    self.titleStackViewTopConstraint.constant -= delta
                    self.view.layoutIfNeeded()
                }
            }

            self?.setAnswerStackViewHidden(false)
            self?.textField.becomeFirstResponder()
            self?.accessoryView.isEnabled = false
        }
    }
}

extension BackupQuestionViewController {
    func textField(_ textField: UITextField,
                   shouldChangeCharactersIn range: NSRange,
                   replacementString string: String) -> Bool {
        guard let currentText = textField.text else {
            return false
        }

        let newText = (currentText as NSString).replacingCharacters(in: range, with: string)

        let returnValue: Bool

        if newText.count < currentText.count {
            returnValue = true
        } else if newText.hasSpaceBefore(index: 4) {
            returnValue = false
        } else if string.rangeOfCharacter(from: CharacterSet.alphanumericsAndWhiteSpace.inverted) != nil {
            returnValue = false
        } else {
            returnValue = true
        }

        if returnValue {
            accessoryView.isEnabled = isInputTextValid(text: newText)
        }

        return returnValue
    }
}
