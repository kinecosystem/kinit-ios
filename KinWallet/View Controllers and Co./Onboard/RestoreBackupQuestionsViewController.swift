//
//  RestoreBackupQuestionsViewController.swift
//  KinWallet
//
//  Copyright © 2018 KinFoundation. All rights reserved.
//

import UIKit

class RestoreBackupQuestionsViewController: UITableViewController {
    var questions = [String]()
    var encryptedWallet: String!

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

extension RestoreBackupQuestionsViewController: RestoreBackupCellDelegate {
    func restoreBackupCellDidTapNext() {
        guard
            let firstQuestionCell = tableView.cellForRow(at: IndexPath(row: 0, section: 1))
                as? RestoreBackupQuestionCell,
            let secondQuestionCell = tableView.cellForRow(at: IndexPath(row: 1, section: 1))
                as? RestoreBackupQuestionCell,
            let actionCell = tableView.cellForRow(at: IndexPath(row: 0, section: 2))
                as? RestoreBackupActionCell else {
                    return
        }

        let firstAnswer = firstQuestionCell.textField.textOrEmpty
        let secondAnswer = secondQuestionCell.textField.textOrEmpty

        guard firstAnswer.isBackupStringValid, secondAnswer.isBackupStringValid else {
            return
        }

        actionCell.actionButton.isLoading = true

        DispatchQueue.global().async {
            do {
                try Kin.shared.importWallet(self.encryptedWallet, with: firstAnswer + secondAnswer)
                WebRequests.Backup.restoreUserId(with: Kin.shared.publicAddress)
                    .withCompletion { [weak self] userId, _ in
                        guard let userId = userId else {
                            //TODO: handle error
                            DispatchQueue.main.async {
                            }
                            return
                        }

                        var user = User.current!
                        user.userId = userId
                        user.publicAddress = Kin.shared.publicAddress
                        user.save()

                        KinLoader.shared.loadAllData()
                        Kin.setPerformedBackup()

                        DispatchQueue.main.async {
                            let accountReadyVC = StoryboardScene.Onboard.accountReadyViewController.instantiate()
                            accountReadyVC.walletSource = .restored
                            self?.navigationController?.pushViewController(accountReadyVC, animated: true)
                        }
                    }.load(with: KinWebService.shared)
            } catch {
                //TODO: handle error
                DispatchQueue.main.async {
                    actionCell.actionButton.isLoading = false
                }

                KLogError("Could not decrypt wallet with given passphrase")
            }
        }
    }
}
