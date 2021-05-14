//
//  MailboxCoordinator.swift.swift
//  ProtonMail - Created on 12/10/18.
//
//
//  Copyright (c) 2019 Proton Technologies AG
//
//  This file is part of ProtonMail.
//
//  ProtonMail is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  ProtonMail is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with ProtonMail.  If not, see <https://www.gnu.org/licenses/>.


import Foundation
import SideMenuSwift

class MailboxCoordinator : DefaultCoordinator {
    typealias VC = MailboxViewController
    
    let viewModel : MailboxViewModel
    var services: ServiceFactory
    
    internal weak var viewController: MailboxViewController?
    internal weak var navigation: UINavigationController?
    internal weak var sideMenu: SideMenuController?
    // whole the ref until started
    internal var navBeforeStart: UINavigationController?
    var pendingActionAfterDismissal: (() -> Void)? = nil
    
    init(sideMenu: SideMenuController?, vm: MailboxViewModel, services: ServiceFactory) {
        self.sideMenu = sideMenu
        self.viewModel = vm
        self.services = services
        
        let inbox : UIStoryboard = UIStoryboard.Storyboard.inbox.storyboard
        let vc = inbox.make(VC.self)
        let nav = UINavigationController(rootViewController: vc)
        self.viewController = vc
        self.navBeforeStart = nav
        self.navigation = nav
    }
    
    init(nav: UINavigationController?, vc: MailboxViewController, vm: MailboxViewModel, services: ServiceFactory) {
        self.viewModel = vm
        self.viewController = vc
        self.services = services
        self.navigation = nav
    }
    
    init(vc: MailboxViewController, vm: MailboxViewModel, services: ServiceFactory) {
        self.viewModel = vm
        self.services = services
        self.viewController = vc
    }
    
    init(sideMenu: SideMenuController?, nav: UINavigationController?, vc: MailboxViewController, vm: MailboxViewModel, services: ServiceFactory) {
        self.sideMenu = sideMenu
        self.navigation = nav
        self.viewController = vc
        self.viewModel = vm
        self.services = services
    }
    
    weak var delegate: CoordinatorDelegate?
    
    enum Destination : String {
        case composer          = "toCompose"
        case composeShow       = "toComposeShow"
        case composeMailto     = "toComposeMailto"
        case search            = "toSearchViewController"
        case details           = "SingleMessageViewController"
        //        case detailsFromNotify = "SingleMessageViewController"
        case onboarding        = "to_onboarding_segue"
        case feedback          = "to_feedback_segue"
        case feedbackView      = "to_feedback_view_segue"
        case humanCheck        = "toHumanCheckView"
        case folder            = "toMoveToFolderSegue"
        case labels            = "toApplyLabelsSegue"
        case troubleShoot      = "toTroubleShootSegue"
        case newFolder = "toNewFolder"
        case newLabel = "toNewLabel"
        
        init?(rawValue: String) {
            switch rawValue {
            case "toCompose": self = .composer
            case "toComposeShow", String(describing: ComposeContainerViewController.self): self = .composeShow
            case "toComposeMailto": self = .composeMailto
            case "toSearchViewController", String(describing: SearchViewController.self): self = .search
            case "toMessageDetailViewController", String(describing: SingleMessageViewController.self): self = .details
            //            case "toMessageDetailViewControllerFromNotification": self = .detailsFromNotify
            case "to_onboarding_segue": self = .onboarding
            case "to_feedback_segue": self = .feedback
            case "to_feedback_view_segue": self = .feedbackView
            case "toHumanCheckView": self = .humanCheck
            case "toMoveToFolderSegue": self = .folder
            case "toApplyLabelsSegue": self = .labels
            case "toTroubleShootSegue": self = .troubleShoot
            default: return nil
            }
        }
    }
    
    /// if called from a segue prepare don't call push again
    func start() {
        self.viewController?.set(viewModel: self.viewModel)
        self.viewController?.set(coordinator: self)
        
        if self.navigation != nil, self.sideMenu != nil {
            self.sideMenu?.setContentViewController(to: self.navigation!)
            self.sideMenu?.hideMenu()
        }
        if let presented = self.viewController?.presentedViewController {
            presented.dismiss(animated: false, completion: nil)
        }
        self.navBeforeStart = nil
    }

    func navigate(from source: UIViewController, to destination: UIViewController, with identifier: String?, and sender: AnyObject?) -> Bool {
        guard let segueID = identifier, let dest = Destination(rawValue: segueID) else {
            return false
        }
        
        switch dest {
        case .details:
            guard let next = destination as? MessageContainerViewController else {
                return false
            }
            let vmService = services.get() as ViewModelService
            vmService.messageDetails(fromList: next)
            guard let indexPathForSelectedRow = self.viewController?.tableView.indexPathForSelectedRow,
                let message = self.viewModel.item(index: indexPathForSelectedRow) else {
                    return false
            }
            
            next.set(viewModel: .init(message: message, msgService: self.viewModel.messageService, user: self.viewModel.user, labelID: viewModel.labelID))
            next.set(coordinator: .init(controller: next))
        case .composer:
            guard let nav = destination as? UINavigationController,
                let next = nav.viewControllers.first as? ComposeContainerViewController else
            {
                return false
            }
            let user = self.viewModel.user
            let viewModel = ContainableComposeViewModel(msg: nil, action: .newDraft, msgService: user.messageService, user: user, coreDataService: self.services.get(by: CoreDataService.self))
            next.set(viewModel: ComposeContainerViewModel(editorViewModel: viewModel, uiDelegate: next))
            next.set(coordinator: ComposeContainerViewCoordinator(controller: next))
            
        case .composeShow, .composeMailto:
            self.viewController?.cancelButtonTapped()
            
            guard let nav = destination as? UINavigationController,
                let next = nav.viewControllers.first as? ComposeContainerViewController,
                let message = sender as? Message else
            {
                return false
            }

            let user = self.viewModel.user
            let viewModel = ContainableComposeViewModel(msg: message, action: .openDraft, msgService: user.messageService, user: user, coreDataService: self.services.get(by: CoreDataService.self))
            next.set(viewModel: ComposeContainerViewModel(editorViewModel: viewModel, uiDelegate: next))
            next.set(coordinator: ComposeContainerViewCoordinator(controller: next))
            
        case .search, .onboarding:
            return true
        case .feedback:
            return false

        case .feedbackView:
            return false
        case .humanCheck:
            guard let next = destination as? MailboxCaptchaViewController else {
                return false
            }
            let user = self.viewModel.user
            next.viewModel = CaptchaViewModelImpl(api: user.apiService)
            next.delegate = self.viewController
        case .folder:
            guard let next = destination as? LablesViewController else {
                return false
            }
            
            guard let messages = sender as? [Message] else {
                return false
            }

            let user = self.viewModel.user
            next.viewModel = FolderApplyViewModelImpl(msg: messages, folderService: user.labelService, messageService: user.messageService, apiService: user.apiService)
            next.delegate = self.viewController
        case .labels:
            guard let next = destination as? LablesViewController else {
                return false
            }
            guard let messages = sender as? [Message] else {
                return false
            }
            
            let user = self.viewModel.user
            next.viewModel = LabelApplyViewModelImpl(msg: messages, labelService: user.labelService, messageService: user.messageService, apiService: user.apiService, cacheService: user.cacheService)
            next.delegate = self.viewController
            
        case .troubleShoot:
            guard let nav = destination as? UINavigationController else
            {
                return false
            }
            
            let tsVC = NetworkTroubleShootCoordinator.init(segueNav: nav, vm: NetworkTroubleShootViewModelImpl(), services: services)
            tsVC.start()
        case .newFolder, .newLabel:
            break
        }
        return true
    }   
    
    func go(to dest: Destination, sender: Any? = nil) {
        switch dest {
        case .details:
            presentSingleMessageViewController()
        case .newFolder:
            presentCreateFolder(type: .folder)
        case .newLabel:
            presentCreateFolder(type: .label)
        default:
            guard let vc = self.viewController else {return}
            if let presented = vc.presentedViewController {
                presented.dismiss(animated: false, completion: nil)
            }
            self.viewController?.performSegue(withIdentifier: dest.rawValue, sender: sender)
        }
    }

    private func presentCreateFolder(type: PMLabelType) {
        let user = viewModel.user
        let vm = NEWLabelEditViewModel(user: user, label: nil, type: type, labels: [])
        let vc = NEWLabelEditViewController.instance()
        let coordinator = LabelEditCoordinator(services: self.services,
                                               viewController: vc,
                                               viewModel: vm,
                                               mailboxCoordinator: self)
        coordinator.start()
        // We want to call back when navController is dismissed to show sheet again
        if let navigation = vc.navigationController {
            viewController?.navigationController?.present(navigation, animated: true, completion: nil)
        }
    }

    func labelEditCoordinatorDidDismiss() {
        pendingActionAfterDismissal?()
        pendingActionAfterDismissal = nil
    }

    private func presentSingleMessageViewController() {
        guard let indexPathForSelectedRow = self.viewController?.tableView.indexPathForSelectedRow,
            let message = self.viewModel.item(index: indexPathForSelectedRow),
            let navigationController = viewController?.navigationController else { return }
        let coordinator = SingleMessageCoordinator(
            navigationController: navigationController,
            labelId: viewModel.labelID,
            message: message,
            user: viewModel.user
        )
        coordinator.start()
    }
    
    func follow(_ deeplink: DeepLink) {
        guard let path = deeplink.popFirst, let dest = Destination(rawValue: path.name) else { return }
            
        switch dest {
        case .details:
            let coreDataService = self.services.get(by: CoreDataService.self)
            guard let messageId = path.value,
                  let message = viewModel.user.messageService.fetchMessages(
                    withIDs: [messageId],
                    in: coreDataService.mainContext
                  ).first,
                  let navigationController = viewController?.navigationController else { return }
            let coordinator = SingleMessageCoordinator(
                navigationController: navigationController,
                labelId: viewModel.labelID,
                message: message,
                user: viewModel.user
            )
            coordinator.start()
            viewModel.resetNotificationMessage()
        case .composeShow where path.value != nil:
            let coreDataService = self.services.get(by: CoreDataService.self)
            
            if let messageID = path.value,
                let nav = self.navigation,
                let next = nav.viewControllers.first as? ComposeContainerViewController,
                case let user = self.viewModel.user,
                case let msgService = user.messageService,
                let message = msgService.fetchMessages(withIDs: [messageID], in: coreDataService.mainContext).first
            {
                let viewModel = ContainableComposeViewModel(msg: message, action: .openDraft, msgService: msgService, user: user, coreDataService: coreDataService)
                let composer = ComposeContainerViewCoordinator.init(nav: nav, viewModel: ComposeContainerViewModel(editorViewModel: viewModel, uiDelegate: next), services: services)
                composer.start()
                composer.follow(deeplink)
            }
            
        case .composeShow where path.value == nil:
            if let nav = self.navigation,
               let next = nav.viewControllers.first as? ComposeContainerViewController {
                let user = self.viewModel.user
                let viewModel = ContainableComposeViewModel(msg: nil, action: .newDraft, msgService: user.messageService, user: user, coreDataService: self.services.get(by: CoreDataService.self))
                let composer = ComposeContainerViewCoordinator.init(nav: nav, viewModel: ComposeContainerViewModel(editorViewModel: viewModel, uiDelegate: next), services: services)
                composer.start()
                composer.follow(deeplink)
            }
        case .composeMailto where path.value != nil:
            if let nav = self.navigation,
               let next = nav.viewControllers.first as? ComposeContainerViewController,
               let value = path.value {
                let user = self.viewModel.user
                let mailToURL = URL(string: value)!
                let viewModel = ContainableComposeViewModel(msg: nil, action: .newDraft, msgService: user.messageService, user: user, coreDataService: self.services.get(by: CoreDataService.self))
                
                if let mailToData = mailToURL.parseMailtoLink() {
                    PMLog.D("mailto: \(mailToData)")
                    
                    mailToData.to.forEach { (receipient) in
                        viewModel.addToContacts(ContactVO(name: receipient, email: receipient))
                    }
                    
                    mailToData.cc.forEach { (receipient) in
                        viewModel.addCcContacts(ContactVO(name: receipient, email: receipient))
                    }
                    
                    mailToData.bcc.forEach { (receipient) in
                        viewModel.addBccContacts(ContactVO(name: receipient, email: receipient))
                    }
                    
                    if let subject = mailToData.subject {
                        viewModel.setSubject(subject)
                    }
                    
                    if let body = mailToData.body {
                        viewModel.setBody(body)
                    }
                }
                    
                let composer = ComposeContainerViewCoordinator.init(nav: nav, viewModel: ComposeContainerViewModel(editorViewModel: viewModel, uiDelegate: next), services: services)
                composer.start()
                composer.follow(deeplink)
            }
            
        default:
            self.go(to: dest, sender: deeplink)
        }
    }
}
