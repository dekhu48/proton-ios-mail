//
// Copyright 2015 ArcTouch, Inc.
// All rights reserved.
//
// This file, its contents, concepts, methods, behavior, and operation
// (collectively the "Software") are protected by trade secret, patent,
// and copyright laws. The use of the Software is governed by a license
// agreement. Disclosure of the Software to third parties, in any form,
// in whole or in part, is expressly prohibited except as authorized by
// the license agreement.
//

import UIKit

class ComposeViewController: ProtonMailViewController {

    private struct EncryptionStep {
        static let DefinePassword = "DefinePassword"
        static let ConfirmPassword = "ConfirmPassword"
        static let DefineHintPassword = "DefineHintPassword"
    }
    
    // MARK: - Private attributes
    
    var attachments: [AnyObject]?
    var message: Message?
    var action: String!
    var selectedContacts: [ContactVO]! = [ContactVO]()
    private var contacts: [ContactVO]! = [ContactVO]()
    private var composeView: ComposeView!
    private var actualEncryptionStep = EncryptionStep.DefinePassword
    private var encryptionPassword: String = ""
    private var encryptionConfirmPassword: String = ""
    private var encryptionPasswordHint: String = ""
    private var hasAccessToAddressBook: Bool = false

    
    // MARK: - View Controller lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.composeView = self.view as? ComposeView
        self.composeView.datasource = self
        self.composeView.delegate = self
        
        if let message = message {
            self.composeView.setMessage(message, action: action)
            let recipientsName = split(message.recipientNameList) {$0 == ","}
            let recipientsEmail = split(message.recipientList) {$0 == ","}
            
            for (var i = 0; i < countElements(recipientsName); i++) {
                selectedContacts.append(ContactVO(id: "", name: recipientsName[i], email: recipientsEmail[i]))
            }
        }
        
        retrieveAddressBook()
        retrieveServerContactList { () -> Void in
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.contacts.sort { $0.name.lowercaseString < $1.name.lowercaseString }
                self.composeView.toContactPicker.reloadData()
                self.composeView.ccContactPicker.reloadData()
                self.composeView.bccContactPicker.reloadData()
                self.composeView.finishRetrievingContacts()
            })
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        if (selectedContacts.count == 0) {
            self.composeView.toContactPicker.becomeFirstResponder()
        } else {
            self.composeView.bodyTextView.becomeFirstResponder()
        }
    }
    
    
    // MARK: ProtonMail View Controller
    
    override func shouldShowSideMenu() -> Bool {
        return false
    }
}


// MARK: - AttachmentsViewControllerDelegate
extension ComposeViewController: AttachmentsViewControllerDelegate {
    func attachmentsViewController(attachmentsViewController: AttachmentsViewController, didFinishPickingAttachments attachments: [AnyObject]) {
        self.attachments = attachments
    }
}


// MARK: - ComposeViewDelegate
extension ComposeViewController: ComposeViewDelegate {
    func composeViewDidTapCancelButton(composeView: ComposeView) {
        self.navigationController?.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func composeViewDidTapSendButton(composeView: ComposeView) {
        sharedMessageDataService.send(
            recipientList: composeView.toContacts,
            bccList: composeView.bccContacts,
            ccList: composeView.ccContacts,
            title: composeView.subjectTitle,
            encryptionPassword: encryptionPassword,
            passwordHint: encryptionPasswordHint,
            expirationTimeInterval: composeView.expirationTimeInterval,
            body: composeView.body,
            attachments: attachments)
        
        self.navigationController?.dismissViewControllerAnimated(true, completion: nil)
    }

    func composeViewDidTapEncryptedButton(composeView: ComposeView) {
        self.actualEncryptionStep = EncryptionStep.DefinePassword
        self.composeView.showDefinePasswordView()
        self.composeView.hidePasswordAndConfirmDoesntMatch()
    }
    
    func composeViewDidTapNextButton(composeView: ComposeView) {
        switch(actualEncryptionStep) {
        case EncryptionStep.DefinePassword:
            self.encryptionPassword = composeView.encryptedPasswordTextField.text ?? ""
            self.actualEncryptionStep = EncryptionStep.ConfirmPassword
            self.composeView.showConfirmPasswordView()
            
        case EncryptionStep.ConfirmPassword:
            self.encryptionConfirmPassword = composeView.encryptedPasswordTextField.text ?? ""
            
            if (self.encryptionPassword == self.encryptionConfirmPassword) {
                self.actualEncryptionStep = EncryptionStep.DefineHintPassword
                self.composeView.hidePasswordAndConfirmDoesntMatch()
                self.composeView.showPasswordHintView()
            } else {
                self.composeView.showPasswordAndConfirmDoesntMatch()
            }
            
        case EncryptionStep.DefineHintPassword:
            self.encryptionPasswordHint = composeView.encryptedPasswordTextField.text ?? ""
            self.actualEncryptionStep = EncryptionStep.DefinePassword
            self.composeView.showEncryptionDone()
        default:
            println("No step defined.")
        }
    }
    
    func composeViewDidAddContact(composeView: ComposeView, contact: ContactVO) {
        self.selectedContacts.append(contact)
    }
    
    func composeViewDidRemoveContact(composeView: ComposeView, contact: ContactVO) {
        var contactIndex = -1
        for (index, selectedContact) in enumerate(selectedContacts) {
            if (contact.email == selectedContact.email) {
                contactIndex = index
            }
        }
        
        if (contactIndex >= 0) {
            selectedContacts.removeAtIndex(contactIndex)
        }
    }
    
    func composeViewDidTapAttachmentButton(composeView: ComposeView) {
        if let viewController = UIStoryboard.instantiateInitialViewController(storyboard: .attachments) as? UINavigationController {
            if let attachmentsViewController = viewController.viewControllers.first as? AttachmentsViewController {
                attachmentsViewController.delegate = self
                
                if let attachments = attachments {
                    attachmentsViewController.attachments = attachments
                }
            }
            
            presentViewController(viewController, animated: true, completion: nil)
        }
    }
}


// MARK: - ComposeViewDataSource
extension ComposeViewController: ComposeViewDataSource {
    func composeViewContactsModel(composeView: ComposeView) -> [AnyObject]! {
        return contacts
    }
    
    func composeViewSelectedContacts(composeView: ComposeView) ->  [AnyObject]! {
        return selectedContacts
    }
}


// MARK: - Address book
extension ComposeViewController {
    private func retrieveAddressBook() {
        
        if (sharedAddressBookService.hasAccessToAddressBook()) {
            self.hasAccessToAddressBook = true
        } else {
            sharedAddressBookService.requestAuthorizationWithCompletion({ (granted: Bool, error: NSError?) -> Void in
                if (granted) {
                    self.hasAccessToAddressBook = true
                }
                
                if let error = error {
                    let alertController = error.alertController()
                    alertController.addAction(UIAlertAction(title: NSLocalizedString("OK"), style: .Default, handler: nil))
                    
                    self.presentViewController(alertController, animated: true, completion: nil)
                    println("Error trying to access Address Book = \(error.localizedDescription).")
                }
            })
        }
        
        if (self.hasAccessToAddressBook) {
            let addressBookContacts = sharedAddressBookService.contacts()
            for contact: RHPerson in addressBookContacts as [RHPerson] {
                var name: String? = contact.name
                let emails: RHMultiStringValue = contact.emails
                
                for (var emailIndex: UInt = 0; Int(emailIndex) < Int(emails.count()); emailIndex++) {
                    let emailAsString = emails.valueAtIndex(emailIndex) as String
                    
                    if (emailAsString.isValidEmail()) {
                        let email = emailAsString
                        
                        if (name == nil) {
                            name = email
                        }
                        
                        self.contacts.append(ContactVO(name: name, email: email, isProtonMailContact: false))
                    }
                }
            }
        }
    }
    
    private func retrieveServerContactList(completion: () -> Void) {
        sharedContactDataService.fetchContacts { (contacts: [Contact]?, error: NSError?) -> Void in
            if error != nil {
                NSLog("\(error)")
                return
            }
            
            if let contacts = contacts {
                for contact in contacts {
                    self.contacts.append(ContactVO(id: contact.contactID, name: contact.name, email: contact.email, isProtonMailContact: true))
                }
            }
            
            completion()
        }
    }
}