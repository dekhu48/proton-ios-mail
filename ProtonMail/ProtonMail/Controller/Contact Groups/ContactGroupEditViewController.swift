//
//  ContactGroupEditViewController.swift
//  ProtonMail
//
//  Created by Chun-Hung Tseng on 2018/8/16.
//  Copyright © 2018 ProtonMail. All rights reserved.
//

import UIKit
import PromiseKit

/**
 The design for now is no auto-saving
 */
class ContactGroupEditViewController: ProtonMailViewController, ViewModelProtocol {
    let kToContactGroupSelectColorSegue = "toContactGroupSelectColorSegue"
    let kToContactGroupSelectEmailSegue = "toContactGroupSelectEmailSegue"
    
    @IBOutlet weak var contactGroupNameLabel: UITextField!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    @IBOutlet weak var navigationBarItem: UINavigationItem!
    @IBOutlet weak var tableView: UITableView!
    var viewModel: ContactGroupEditViewModel!
    
    func setViewModel(_ vm: Any) {
        viewModel = vm as! ContactGroupEditViewModel
    }
    
    func inactiveViewModel() {}
    
    @IBAction func cancelItem(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewModel.delegate = self
        
        loadDataIntoView()
        
        tableView.noSeparatorsBelowFooter()
    }
    
    func loadDataIntoView() {
        navigationBarItem.title = viewModel.getViewTitle()
        contactGroupNameLabel.text = viewModel.getContactGroupName()
        
        self.tableView.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func saveAction(_ sender: UIBarButtonItem) {
        // TODO: spinning while saving... (blocking)
//        do {
//            try viewModel.saveContactGroupDetail(name: contactGroupNameLabel.text,
//                                                 color: viewModel.getCurrentColorWithDefault(),
//                                                 emailList: NSSet())
//            self.dismiss(animated: true, completion: nil)
//        } catch {
//            let alert = UIAlertController(title: "Can't not save contact group",
//                                          message: error.localizedDescription,
//                                          preferredStyle: .alert)
//            alert.addOKAction()
//            present(alert, animated: true, completion: nil)
//        }
        
        firstly {
            viewModel.saveContactGroupDetail(name: contactGroupNameLabel.text,
                                             color: viewModel.getCurrentColorWithDefault(),
                                             emailList: NSSet())
            }.done {
                (_) -> Void in
                
                self.dismiss(animated: true, completion: nil)
            }.catch {
                error in
                
                let alert = UIAlertController(title: "Can't not save contact group",
                                              message: error.localizedDescription,
                                              preferredStyle: .alert)
                alert.addOKAction()
                self.present(alert, animated: true, completion: nil)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == kToContactGroupSelectColorSegue {
            let contactGroupSelectColorViewController = segue.destination as! ContactGroupSelectColorViewController
            
            let refreshHandler = {
                (newColor: String?) -> Void in
                self.viewModel.updateColor(newColor: newColor)
            }
            sharedVMService.contactGroupSelectColorViewModel(contactGroupSelectColorViewController,
                                                             currentColor: viewModel.getCurrentColorWithDefault(),
                                                             refreshHandler: refreshHandler)
        } else if segue.identifier == kToContactGroupSelectEmailSegue {
            let refreshHandler = {
                () -> Void in
                
                // TODO: take the new NSSet as a pass-in value?
            }
            
            let contactGroupSelectEmailViewController = segue.destination as! ContactGroupSelectEmailViewController
            let data = sender as! ContactGroupEditViewController
            sharedVMService.contactGroupSelectEmailViewModel(contactGroupSelectEmailViewController,
                                                             groupID: data.viewModel.getContactGroupID(),
                                                             selectedEmails: data.viewModel.getEmailIDsInContactGroup(),
                                                             refreshHandler: refreshHandler)
        } else {
            PMLog.D("No such segue")
            fatalError("No such segue")
        }
    }
}

extension ContactGroupEditViewController: UITableViewDataSource
{
    func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel.getTotalSections()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.getTotalRows(for: section)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch viewModel.getCellType(at: indexPath) {
        case .selectColor:
            let cell = tableView.dequeueReusableCell(withIdentifier: "ContactGroupColorCell", for: indexPath)
            return cell
        case .manageContact:
            let cell = tableView.dequeueReusableCell(withIdentifier: "ContactGroupManageCell", for: indexPath)
            return cell
        case .email:
            let cell = tableView.dequeueReusableCell(withIdentifier: "ContactGroupMemberCell", for: indexPath)
            
            let (name, email) = viewModel.getEmail(at: indexPath)
            cell.textLabel?.text = name
            cell.detailTextLabel?.text = email
            return cell
        case .deleteGroup:
            let cell = tableView.dequeueReusableCell(withIdentifier: "ContactGroupDeleteCell", for: indexPath)
            return cell
        case .error:
            fatalError("This is a bug")
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        switch viewModel.getCellType(at: indexPath) {
        case .selectColor:
            // display color
            cell.detailTextLabel?.backgroundColor = UIColor(hexString: viewModel.getCurrentColorWithDefault(), alpha: 1.0)
        case .error:
            fatalError("This is a bug")
        default:
            return
        }
    }
}

extension ContactGroupEditViewController: UITableViewDelegate
{
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        switch viewModel.getCellType(at: indexPath) {
        case .selectColor:
            self.performSegue(withIdentifier: kToContactGroupSelectColorSegue, sender: self)
        case .manageContact:
            self.performSegue(withIdentifier: kToContactGroupSelectEmailSegue, sender: self)
        case .email:
            print("email actions")
        case .deleteGroup:
            viewModel.deleteContactGroup()
            self.dismiss(animated: true, completion: nil)
        case .error:
            fatalError("This is a bug")
        }
    }
}

extension ContactGroupEditViewController: ContactGroupEditViewModelDelegate
{
    func update() {
        loadDataIntoView()
    }
}
