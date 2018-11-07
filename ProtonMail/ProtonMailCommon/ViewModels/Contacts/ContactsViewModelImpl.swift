//
//  ContactViewModelImpl.swift
//  ProtonMail
//
//  Created by Yanfeng Zhang on 5/1/17.
//  Copyright © 2017 ProtonMail. All rights reserved.
//

import Foundation
import CoreData

final class ContactsViewModelImpl : ContactsViewModel {
    // MARK: - fetch controller
    fileprivate var fetchedResultsController: NSFetchedResultsController<NSFetchRequestResult>?
    fileprivate var isSearching: Bool = false
    
    override func setupFetchedResults(delaget: NSFetchedResultsControllerDelegate?) {
        self.fetchedResultsController = self.getFetchedResultsController()
        self.correctCachedData()
        self.fetchedResultsController?.delegate = delaget
    }
    
    func correctCachedData() {
        if let objects = fetchedResultsController?.fetchedObjects as? [Contact] {
            if let context = self.fetchedResultsController?.managedObjectContext {
                var needsSave = false
                for obj in objects {
                    if obj.fixName() {
                        needsSave = true
                    }
                }
                if needsSave {
                    let _ = context.saveUpstreamIfNeeded()
                    self.fetchedResultsController = self.getFetchedResultsController()
                }
            }
        }
    }
    
    private func getFetchedResultsController() -> NSFetchedResultsController<NSFetchRequestResult>? {
        if let fetchedResultsController = sharedContactDataService.resultController() {
            do {
                try fetchedResultsController.performFetch()
            } catch let ex as NSError {
                PMLog.D("error: \(ex)")
            }
            return fetchedResultsController
        }
        return nil
    }
    
    override func set(searching isSearching: Bool) {
        self.isSearching = isSearching
    }
    
    override func search(text: String) {
        if text.isEmpty {
            fetchedResultsController?.fetchRequest.predicate = nil
        } else {
            fetchedResultsController?.fetchRequest.predicate = NSPredicate(format: "name CONTAINS[cd] %@ OR ANY emails.email CONTAINS[cd] %@", argumentArray: [text, text])
        }
        
        do {
            try fetchedResultsController?.performFetch()
        } catch let ex as NSError {
            PMLog.D("error: \(ex)")
        }
        
    }
    
    // MARK: - table view part
    override func sectionCount() -> Int {
        return fetchedResultsController?.numberOfSections() ?? 0
    }
    
    override func rowCount(section: Int) -> Int {
        return fetchedResultsController?.numberOfRows(in: section) ?? 0
    }
    
    override func sectionIndexTitle() -> [String]? {
        if isSearching {
            return nil
        }
        return fetchedResultsController?.sectionIndexTitles
    }
    
    override func sectionForSectionIndexTitle(title: String, atIndex: Int) -> Int {
        if isSearching {
            return -1
        }
        return fetchedResultsController?.section(forSectionIndexTitle: title, at: atIndex) ?? -1
    }
    
    override func item(index: IndexPath) -> Contact? {
        return fetchedResultsController?.object(at: index) as? Contact
    }
    
    override func isExsit(uuid: String) -> Bool {
        if let contacts = fetchedResultsController?.fetchedObjects as? [Contact] {
            for c in contacts {
                if c.uuid == uuid {
                    return true
                }
            }
        }
        return false
    }
    
    // MARK: - api part
    override func delete(contactID: String!, complete : @escaping ContactDeleteComplete) {
        sharedContactDataService.delete(contactID: contactID, completion: { (error) in
            if let err = error {
                complete(err)
            } else {
                complete(nil)
            }
        })
    }
    
    private var isFetching : Bool = false
    private var fetchComplete : ContactFetchComplete? = nil
    override func fetchContacts(completion: ContactFetchComplete?) {
        if let c = completion {
            fetchComplete = c
        }
        if !isFetching {
            isFetching = true
            
            sharedMessageDataService.fetchNewMessagesForLocation(.inbox, notificationMessageID: nil, completion: { (task, res, error) in
                self.isFetching = false
                self.fetchComplete?(nil, nil)
            })
            
            sharedContactDataService.fetchContacts { (_, error) in
                
            }
        }
        
    }

    // MARK: - timer overrride
    override internal func fireFetch() {
        self.fetchContacts(completion: nil)
    }
}
