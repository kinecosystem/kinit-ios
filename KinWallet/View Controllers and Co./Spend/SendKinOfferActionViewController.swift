//
//  SendKinOfferActionViewController.swift
//  KinWallet
//
//  Copyright © 2018 KinFoundation. All rights reserved.
//

import UIKit
import ContactsUI
import Contacts

class SendKinOfferActionViewController: SpendOfferActionViewController {
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
    @IBOutlet weak var sendKinButton: UIButton! {
        didSet {
            sendKinButton.makeKinButtonFilled()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    @IBAction func sendKin(_ sender: Any) {
        let contactsViewController = CNContactPickerViewController()
        contactsViewController.predicateForEnablingContact = NSPredicate(format: "phoneNumbers.@count > 0")
        contactsViewController.displayedPropertyKeys = [CNContactPhoneNumbersKey]
        contactsViewController.delegate = self
        present(contactsViewController, animated: true)
    }
}

extension SendKinOfferActionViewController: CNContactPickerDelegate {
    func contactPickerDidCancel(_ picker: CNContactPickerViewController) {
        KLogDebug("Did cancel CNContactPickerViewController")
    }

    func contactPicker(_ picker: CNContactPickerViewController, didSelect contactProperty: CNContactProperty) {
        guard let cnPhoneNumber = contactProperty.value as? CNPhoneNumber else {
            return
        }

        let imageFromContact: UIImage? = contactProperty.contact.imageData != nil
            ? UIImage(data: contactProperty.contact.imageData!)
            : nil
        let contactImage = imageFromContact ?? Asset.recordsLedger.image

        let contactName = [contactProperty.contact.givenName, contactProperty.contact.familyName]
            .joined(separator: " ")
            .trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)

        let phoneNumber = cnPhoneNumber.stringValue
            .replacingOccurrences(of: "-", with: "")
            .replacingOccurrences(of: " ", with: "")

        activityIndicatorView.startAnimating()
        sendKinButton.setTitle(nil, for: .normal)

        WebRequests.searchPhoneNumber(phoneNumber).withCompletion { [weak self] address, _ in
            DispatchQueue.main.async {
                guard let `self` = self else {
                    return
                }

                self.activityIndicatorView.stopAnimating()
                self.sendKinButton.setTitle("Send Kin", for: .normal)

                guard let address = address else {
                    //present alert
                    KLogDebug("Couldn't find address for user with phone \(phoneNumber)")
                    return
                }

                KLogDebug("User with phone \(phoneNumber) has address \(address)")

                let sendKinViewController = StoryboardScene.Spend.sendKinViewController.instantiate()
                sendKinViewController.contactImage = contactImage
                sendKinViewController.contactName = contactName
                sendKinViewController.phoneNumber = phoneNumber
                sendKinViewController.publicAddress = address
                self.navigationController?.pushViewController(sendKinViewController, animated: true)
            }
        }.load(with: KinWebService.shared)
    }
}
