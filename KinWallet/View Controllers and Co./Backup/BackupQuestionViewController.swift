//
//  BackupQuestionViewController.swift
//  KinWallet
//
//  Copyright © 2018 KinFoundation. All rights reserved.
//

import UIKit
import KinitDesignables

private class BackupQuestionCell: UITableViewCell {
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        commonInit()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        commonInit()
    }

    func commonInit() {
        textLabel?.textColor = UIColor.kin.gray
        textLabel?.font = FontFamily.Roboto.regular.font(size: 16)
        textLabel?.adjustsFontSizeToFitWidth = true
        textLabel?.minimumScaleFactor = 0.5
    }
}

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

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.register(class: BackupQuestionCell.self)

        setAnswerStackViewHidden(true, animated: false)
        tableViewHeightConstraint.constant = 0
        NSLayoutConstraint.deactivate([tableViewBottomConstraint])
        questionNumberLabel.text = step.title
        observationLabel.text = L10n.backupMinimum4Characters
        textField.placeholder = L10n.backupYourAnswerPlaceholder

        stepsProgressView.currentStep = step.rawValue

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(textDidChangeNotification(_:)),
                                               name: UITextField.textDidChangeNotification,
                                               object: nil)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        Events.Analytics
            .ViewBackupFlowPage(backupFlowStep: step.analyticsStep)
            .send()
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
                guard let self = self else {
                    return
                }

                self.animatingTableView = false

                guard self.selectedHintId != nil  else {
                    return
                }

                self.setAnswerStackViewHidden(!isOpen)

                if isOpen {
                    self.textField.becomeFirstResponder()
                    self.accessoryView.isEnabled = self.isInputTextValid()
                }
        })
    }

    fileprivate func setAnswerStackViewHidden(_ hidden: Bool, animated: Bool = true) {
        UIView.animate(withDuration: animated ? 0.3 : 0) { [weak self] in
            self?.answerStackView.arrangedSubviews.forEach { $0.alpha = hidden ? 0 : 1 }
        }
    }

    @objc private func textDidChangeNotification(_ sender: Any) {
        verifyActionButtonState()
    }

    private func verifyActionButtonState() {
        accessoryView.isEnabled = isInputTextValid()
    }

    override func isInputTextValid(text: String? = nil) -> Bool {
        return (text ?? textField.textOrEmpty).isBackupStringValid
    }

    override func moveToNextStep() {
        Events.Analytics
            .ClickCompletedStepButtonOnBackupFlowPage(backupFlowStep: step.analyticsStep)
            .send()

        guard
            let thisHintId = selectedHintId,
            isInputTextValid() else {
                let e = "BackupQuestionViewController received moveToNextStep without selectedHintId or answerTextField"
                fatalError(e)
        }

        let answer = textField
            .textOrEmpty
            .trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)

        if step == BackupStep.firstQuestion {
            chosenHints = []
        }

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
            alertExactAnswersNeeded()
        } else {
            fatalError("BackupQuestionViewController can only have step set to .firstQuestion or .secondQuestion")
        }
    }

    private func alertExactAnswersNeeded() {
        let alertController = UIAlertController(title: L10n.backupExactAnswersAlertTitle,
                                                message: L10n.backupExactAnswersAlertMessage,
                                                preferredStyle: .alert)
        alertController.addAction(title: L10n.backupExactAnswerContinueAction,
                                  style: .default,
                                  handler: acknowledgedExactAnswersNeeded)
        presentAnimated(alertController)
    }

    private func acknowledgedExactAnswersNeeded() {
        accessoryView.isLoading = true

        DispatchQueue.global().async {
            guard let encryptedWallet = try? self.encryptWallet() else {
                DispatchQueue.main.async {
                    self.presentSupportAlert(title: L10n.generalErrorTitle,
                                             message: L10n.generalErrorMessage)

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
        let cell = tableView.dequeueReusableCell(forIndexPath: indexPath) as BackupQuestionCell
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
                guard let self = self else {
                    return
                }

                if self.titleStackViewTopConstraint.constant > 0 {
                    let delta = self.questionNumberLabel.frame.minY - self.titleStackViewTopConstraint.constant
                    self.titleStackViewTopConstraint.constant -= delta
                    self.view.layoutIfNeeded()
                }
            }

            guard let self = self else {
                return
            }

            self.setAnswerStackViewHidden(false)
            self.textField.becomeFirstResponder()
            self.accessoryView.isEnabled = self.isInputTextValid()
        }
    }
}
