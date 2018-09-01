//
//  ContactGroupSelectEmailViewModelImpl.swift
//  ProtonMail
//
//  Created by Chun-Hung Tseng on 2018/8/27.
//  Copyright © 2018 ProtonMail. All rights reserved.
//

import Foundation

/// View model for ContactGroupSelectEmailController
class ContactGroupSelectEmailViewModelImpl: ContactGroupSelectEmailViewModel
{
    /// all of the emails that the user have in the contact
    let allEmails: [Email]
    
    /// the list of email that is current in the contact group
    let selectedEmails: NSMutableSet
    
    /// after saving the email list, we refresh the edit view controller's data
    let refreshHandler: () -> Void
    
    /**
     Initializes a new ContactGroupSelectEmailViewModel
    */
    init(selectedEmails: NSSet, refreshHandler: @escaping () -> Void) {
        self.allEmails = sharedContactDataService.allEmails()
        // TODO: fix this
        self.selectedEmails = selectedEmails.mutableCopy() as! NSMutableSet
        self.refreshHandler = refreshHandler
    }
    
    /**
     Call this function when the a specific row is selected
     
     - Parameter indexPath: The row that is selected
     - Returns: The status of current row, after selection, is in the contact group or not
    */
    func selectEmail(at indexPath: IndexPath) -> Bool {
        let selectedEmail = allEmails[indexPath.row]
        let currentSelectionState = selectedEmails.contains(selectedEmail)
        
        if currentSelectionState == true {
            selectedEmails.remove(selectedEmail)
        } else {
            selectedEmails.add(selectedEmail)
        }
        
        return !currentSelectionState
    }
    
    func getSelectionStatus(at indexPath: IndexPath) -> Bool {
        return false
    }
    
    func getTotalEmailCount() -> Int {
        return allEmails.count
    }
    
    // TODO: fix this function
    func getCellData(at indexPath: IndexPath) -> String {
        return String(describing: allEmails[indexPath.row].email)
    }
    
    /**
     Save the selected emails to the contact group
    */
    // TODO: fix this function
    func save() {

    }
    
}
