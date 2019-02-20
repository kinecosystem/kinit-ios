//
//  RestoreBackupQuestionsViewController.swift
//  KinWallet
//
//  Copyright © 2018 KinFoundation. All rights reserved.
//

import UIKit
import KinCoreSDK

class RestoreBackupQuestionsViewController: UITableViewController {
    var questions = [String]()
    var encryptedWallet: String!

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.register(class: RestoreBackupActionCell.self)
        guard let storedHints: SelectedHintIds = SimpleDatastore.loadObject(selectedHintIdsKey) else {
            fatalError("Got to RestoreBackupQuestionsViewController but no stored hint ids")
        }

        let storedHintsIds = storedHints.hints

        DataLoaders.kinit.fetchAvailableBackupHints { [weak self] hints in
            DispatchQueue.main.async {
                guard let self = self else {
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

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        Events.Analytics.ViewAnswerSecurityQuestionsPage().send()
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
                                                   name: UITextField.textDidChangeNotification,
                                                   object: nil)
            let question = questions[indexPath.row]
            let attributedQuestion = NSMutableAttributedString(string: "Q\(indexPath.row + 1): \(question)")
            attributedQuestion.addAttribute(.font,
                                            value: RestoreBackupQuestionCell.fontFamily.bold.font(size: 14),
                                            range: NSRange(location: 0, length: 3))
            cell.questionLabel.attributedText = attributedQuestion

            if indexPath.row == 0 {
                cell.textField.returnKeyType = .next
            } else {
                cell.textField.returnKeyType = .done
            }

            return cell
        }

        defer {
            verifyActionButtonState()
        }

        let actionCell = tableView.dequeueReusableCell(forIndexPath: indexPath) as RestoreBackupActionCell
        actionCell.delegate = self
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

        return firstQuestionCell.textField.textOrEmpty.isBackupStringValid
            && secondQuestionCell.textField.textOrEmpty.isBackupStringValid
    }

    @objc private func textDidChangeNotification(_ sender: Any) {
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
                tableView.scrollToRow(at: IndexPath(row: 0, section: 2),
                                      at: .bottom,
                                      animated: true)
            }
        } else if textField == secondQuestionCell.textField {
            if textField.textOrEmpty.isBackupStringValid {
                let actionCell = tableView.cellForRow(at: IndexPath(row: 0, section: 2))
                    as? RestoreBackupActionCell
                actionCell?.actionButton.shake()
                tableView.scrollToRow(at: IndexPath(row: 0, section: 2),
                                      at: .bottom,
                                      animated: true)
            }
        }

        return false
    }
}

extension RestoreBackupQuestionsViewController: RestoreBackupCellDelegate {
    func restoreBackupCellDidTapNext() {
        Events.Analytics.ClickConfirmButtonOnAnswerSecurityQuestionsPage().send()

        guard
            let firstQuestionCell = tableView.cellForRow(at: IndexPath(row: 0, section: 1))
                as? RestoreBackupQuestionCell,
            let secondQuestionCell = tableView.cellForRow(at: IndexPath(row: 1, section: 1))
                as? RestoreBackupQuestionCell else {
                    return
        }

        let firstAnswer = firstQuestionCell.textField.textOrEmpty
        let secondAnswer = secondQuestionCell.textField.textOrEmpty

        guard firstAnswer.isBackupStringValid, secondAnswer.isBackupStringValid else {
            return
        }

        attemptRestore(with: (firstAnswer, secondAnswer))
    }

    private func attemptRestore(with answers: (String, String), isRetryingWithoutTrimming: Bool = false) {
        let actionCell = tableView.cellForRow(at: IndexPath(row: 0, section: 2))
            as? RestoreBackupActionCell
        actionCell?.actionButton.isLoading = true

        let firstAnswer: String
        let secondAnswer: String

        if isRetryingWithoutTrimming {
            firstAnswer = answers.0
            secondAnswer = answers.1
        } else {
            firstAnswer = answers.0.trimmingCharacters(in: .whitespacesAndNewlines)
            secondAnswer = answers.1.trimmingCharacters(in: .whitespacesAndNewlines)
        }

        DispatchQueue.global().async {
            do {
                try Kin.shared.importWallet(self.encryptedWallet, with: firstAnswer + secondAnswer)
                WebRequests.Backup
                    .restoreUserId(with: Kin.shared.publicAddress)
                    .withCompletion(self.backRestoreCompletion)
                    .load(with: KinWebService.shared)
            } catch {
                DispatchQueue.main.async {
                    let shouldRetry = firstAnswer != answers.0 || secondAnswer != answers.1

                    if shouldRetry {
                        self.attemptRestore(with: answers, isRetryingWithoutTrimming: true)
                    } else {
                        actionCell?.actionButton.isLoading = false
                        self.presentBackupRestoreSupportAlert(title: L10n.backupWrongAnswersTitle,
                                                 message: L10n.backupWrongAnswersMessage)
                    }
                }

                KLogError("Could not decrypt wallet with given passphrase")
            }
        }
    }

    private func backRestoreCompletion(userId: String?, error: Error?) {
        guard let userId = userId else {
            Kin.shared.resetKeyStore()

            DispatchQueue.main.async {
                self.presentBackupRestoreSupportAlert(title: L10n.restoreBackupUserMatchFailedTitle,
                                         message: L10n.restoreBackupUserMatchFailedMessage)
            }

            return
        }

        var user = User.current!
        user.userId = userId
        user.publicAddress = Kin.shared.publicAddress
        user.save()

        Analytics.userId = userId

        DataLoaders.loadAllData()
        Kin.setPerformedBackup()

        DispatchQueue.main.async {
            let accountReadyVC = StoryboardScene.Onboard.accountReadyViewController.instantiate()
            accountReadyVC.walletSource = .restored
            self.navigationController?.pushViewController(accountReadyVC, animated: true)
        }

        Events.Business.WalletRestored().send()
    }
}
