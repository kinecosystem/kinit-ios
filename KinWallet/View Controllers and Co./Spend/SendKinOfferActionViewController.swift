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

    @IBAction func sendKin(_ sender: Any) {
        let contactsViewController = KinCNContactPickerViewController()
        contactsViewController.delegate = self
        present(contactsViewController, animated: true)
        contactsViewController.navigationController?.navigationBar.setBackgroundImage(.from(.white), for: .default)
    }

    fileprivate func contactNotFound(contactName: String?) {
        let alertController = UIAlertController(title: "\(contactName ?? "Your friend") Isn't Using Kinit",
                                                message: "Sorry, you can only send Kin to Kinit users.",
                                                preferredStyle: .alert)
        alertController.addAction(.ok())
        present(alertController, animated: true)
    }
}

extension SendKinOfferActionViewController: CNContactPickerDelegate {
    func contactPicker(_ picker: CNContactPickerViewController, didSelect contactProperty: CNContactProperty) {
        guard let cnPhoneNumber = contactProperty.value as? CNPhoneNumber else {
            return
        }

        let imageFromContact: UIImage? = contactProperty.contact.imageData != nil
            ? UIImage(data: contactProperty.contact.imageData!)
            : nil
        let contactImage = imageFromContact ?? UIImage.from(.lightGray)

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
                    self.contactNotFound(contactName: contactName)
                    return
                }

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

private class KinCNContactPickerViewController: CNContactPickerViewController {
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)

        predicateForEnablingContact = NSPredicate(format: "phoneNumbers.@count > 0")
        displayedPropertyKeys = [CNContactPhoneNumbersKey]
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
}
