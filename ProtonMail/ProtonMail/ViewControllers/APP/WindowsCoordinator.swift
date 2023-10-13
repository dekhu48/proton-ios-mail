//
//  WindowsCoordinator.swift
//  Proton Mail - Created on 12/11/2018.
//
//
//  Copyright (c) 2019 Proton AG
//
//  This file is part of Proton Mail.
//
//  Proton Mail is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  Proton Mail is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with Proton Mail.  If not, see <https://www.gnu.org/licenses/>.

import LifetimeTracker
import MBProgressHUD
import ProtonCoreDataModel
import ProtonCoreKeymaker
import ProtonCoreNetworking
import ProtonCoreUIFoundations
import ProtonMailAnalytics
import SafariServices

final class WindowsCoordinator {
    typealias Dependencies = MenuCoordinator.Dependencies
    & LockCoordinator.Dependencies
    & HasDarkModeCacheProtocol
    & HasNotificationCenter

    private lazy var snapshot = Snapshot()
    private var launchedByNotification = false

    private var deepLink: DeepLink?

    private(set) var appWindow: UIWindow! = UIWindow(
        root: PlaceholderViewController(color: .red),
        scene: nil
    ) {
        didSet {
            guard appWindow == nil else { return }
            if let oldAppWindow = oldValue {
                oldAppWindow.rootViewController?.dismiss(animated: false)
            }
            menuCoordinator = nil
        }
    }

    private(set) var lockWindow: UIWindow?
    private var menuCoordinator: MenuCoordinator?

    private var currentWindow: UIWindow? {
        didSet {
            switch dependencies.darkModeCache.darkModeStatus {
            case .followSystem:
                self.currentWindow?.overrideUserInterfaceStyle = .unspecified
            case .forceOn:
                self.currentWindow?.overrideUserInterfaceStyle = .dark
            case .forceOff:
                self.currentWindow?.overrideUserInterfaceStyle = .light
            }
            self.currentWindow?.makeKeyAndVisible()
        }
    }

    private var arePrimaryUserSettingsFetched = false

    enum Destination {
        enum SignInDestination: String { case form, mailboxPassword }
        case lockWindow, appWindow, signInWindow(SignInDestination)
    }

    var scene: UIScene? {
        didSet {
                assert(scene is UIWindowScene, "Scene should be of type UIWindowScene")
        }
    }
    private let dependencies: Dependencies
    private let showPlaceHolderViewOnly: Bool

    init(dependencies: Dependencies, showPlaceHolderViewOnly: Bool = ProcessInfo.isRunningUnitTests) {
        self.showPlaceHolderViewOnly = showPlaceHolderViewOnly
        self.dependencies = dependencies
        setupNotifications()
        trackLifetime()
    }

    func start(launchedByNotification: Bool = false) {
        self.launchedByNotification = launchedByNotification
        let placeholder = UIWindow(root: PlaceholderViewController(color: .white), scene: self.scene)
        self.currentWindow = placeholder

        if showPlaceHolderViewOnly {
            // While running the unit test, call this to generate the main key.
            _ = dependencies.keyMaker.mainKeyExists()
            return
        }

        // We should not trigger the touch id here. because it is also done in the sign in vc. If we need to check lock, we just go to lock screen first.
        // clean this up later.

        let flow = dependencies.unlockManager.getUnlockFlow()
        Breadcrumbs.shared.add(message: "WindowsCoordinator.start unlockFlow = \(flow)", to: .randomLogout)
        if dependencies.lockCacheStatus.isAppLockedAndAppKeyEnabled {
            self.lock()
        } else {
            DispatchQueue.main.async {
                // initiate unlock process which will send .didUnlock or .requestMainKey eventually
                self.dependencies.unlockManager.initiateUnlock(flow: flow,
                                             requestPin: self.lock,
                                             requestMailboxPassword: self.lock)
            }
        }
    }

    private func navigateToSignInFormAndReport(reason: UserKickedOutReason) {
        Analytics.shared.sendEvent(.userKickedOut(reason: reason), trace: Breadcrumbs.shared.trace(for: .randomLogout))
        go(dest: .signInWindow(.form))
    }

    func go(dest: Destination) {
        DispatchQueue.main.async { // cuz
            switch dest {
            case .signInWindow(let signInDestination):
                // do not recreate coordinator in case it's already displayed with right configuration
                if let signInVC = self.currentWindow?.rootViewController as? SignInCoordinator.VC,
                   signInVC.coordinator.startingPoint == signInDestination {
                    signInVC.coordinator.start()
                    return
                }
                self.lockWindow = nil
                self.appWindow = nil
                // TODO: refactor SignInCoordinatorEnvironment init
                let signInEnvironment = SignInCoordinatorEnvironment.live(
                    dependencies: self.dependencies
                )
                let coordinator: SignInCoordinator = .loginFlowForFirstAccount(
                    startingPoint: signInDestination, environment: signInEnvironment
                ) { [weak self] flowResult in
                    switch flowResult {
                    case .succeeded:
                        self?.go(dest: .appWindow)
                        delay(1) {
                            // Waiting for init of Menu coordinate to receive the notification
                            self?.dependencies.notificationCenter.post(name: .switchView, object: nil)
                        }
                    case .userWantsToGoToTroubleshooting:
                        self?.currentWindow?.rootViewController?.present(
                            doh: BackendConfiguration.shared.doh,
                            modalPresentationStyle: .fullScreen,
                            onDismiss: { [weak self] in
                                // restart the process after user returns from troubleshooting
                                self?.go(dest: .signInWindow(signInDestination))
                            }
                        )
                    case .alreadyLoggedIn, .loggedInFreeAccountsLimitReached, .errored:
                        // not sure what else I can do here instead of restarting the process
                        self?.navigateToSignInFormAndReport(reason: .unexpected(description: "\(flowResult)"))
                    case .dismissed:
                        assertionFailure("this should never happen as the loginFlowForFirstAccount is not dismissable")
                        self?.navigateToSignInFormAndReport(reason: .unexpected(description: "\(flowResult)"))
                    }
                }
                let newWindow = UIWindow(root: coordinator.actualViewController, scene: self.scene)
                self.navigate(from: self.currentWindow, to: newWindow, animated: false) {
                    coordinator.start()
                }

            case .lockWindow:
                if let topVC = self.appWindow?.topmostViewController() {
                    topVC.view.becomeFirstResponder()
                    topVC.view.endEditing(true)
                }
                guard self.lockWindow == nil else {
                    guard let lockVC = self.currentWindow?.rootViewController as? LockCoordinator.VC,
                          lockVC.coordinator.startedOrScheduledForAStart == false
                    else {
                        return
                    }
                    lockVC.coordinator.start()
                    return
                }

                let coordinator = LockCoordinator(
                    dependencies: self.dependencies,
                    finishLockFlow: { [weak self] flowResult in
                        switch flowResult {
                        case .mailbox:
                            self?.go(dest: .appWindow)
                        case .mailboxPassword:
                            self?.go(dest: .signInWindow(.mailboxPassword))
                        case .signIn(let reason):
                            self?.navigateToSignInFormAndReport(reason: .afterLockScreen(description: reason))
                        }
                    }
                )
                let lock = UIWindow(root: coordinator.actualViewController, scene: self.scene)
                self.lockWindow?.rootViewController?.presentedViewController?.dismiss(animated: false)
                self.lockWindow = lock
                coordinator.startedOrScheduledForAStart = true
                self.navigate(from: self.currentWindow, to: lock, animated: false) { [weak coordinator] in
                    if UIApplication.shared.applicationState != .background {
                        coordinator?.start()
                    } else {
                        coordinator?.startedOrScheduledForAStart = false
                    }
                }

            case .appWindow:
                self.lockWindow = nil
                if self.appWindow == nil || self.appWindow.rootViewController is PlaceholderViewController {
                    let root = PMSideMenuController(isUserInfoAlreadyFetched: self.arePrimaryUserSettingsFetched)
                    let menuWidth = MenuViewController.calcProperMenuWidth()
                    let coordinator = MenuCoordinator(
                        dependencies: self.dependencies,
                        sideMenu: root,
                        menuWidth: menuWidth
                    )
                    coordinator.delegate = self
                    self.menuCoordinator = coordinator
                    coordinator.start(launchedByNotification: self.launchedByNotification)
                    self.appWindow = UIWindow(root: root, scene: self.scene)
                    self.launchedByNotification = false
                }
                if self.appWindow.windowScene == nil {
                    self.appWindow.windowScene = self.scene as? UIWindowScene
                }
                if self.navigate(from: self.currentWindow, to: self.appWindow, animated: true), let deeplink = self.deepLink {
                    self.handleDeepLinkIfNeeded(deeplink)
                }
            }
        }
    }

    private func restoreAppStates() {
        guard appWindow != nil else { return }
        self.appWindow.enumerateViewControllerHierarchy { controller, stop in
            if let _ = controller as? MenuViewController,
               let coordinator = self.menuCoordinator {
                coordinator.handleSwitchView(deepLink: self.deepLink)
                stop = true
            }
        }
    }

    @discardableResult
    private func navigate(from source: UIWindow?, to destination: UIWindow, animated: Bool, completion: (() -> Void)? = nil) -> Bool {
        guard source != destination else {
            return false
        }

        let effectView = UIVisualEffectView(frame: UIScreen.main.bounds)
        source?.addSubview(effectView)
        destination.alpha = 0.0

        UIView.animate(withDuration: animated ? 0.5 : 0.0, animations: {
            effectView.effect = UIBlurEffect(style: .dark)
            destination.alpha = 1.0
        }, completion: { _ in
            _ = source
            _ = destination
            effectView.removeFromSuperview()

            // ensure proper view(Will|Did)(Appear|Disappear) callbacks are called
            let topSource = source?.topmostViewController()
            let topDestination = destination.topmostViewController()

            topSource?.beginAppearanceTransition(false, animated: false)
            topDestination?.loadViewIfNeeded()
            topDestination?.beginAppearanceTransition(true, animated: false)

            topSource?.endAppearanceTransition()
            topDestination?.endAppearanceTransition()

            completion?()
        })
        self.currentWindow = destination
        return true
    }

    private func setupNotifications() {
        dependencies.notificationCenter.addObserver(
            self,
            selector: #selector(unlock),
            name: .didUnlock,
            object: nil
        )
        dependencies.notificationCenter.addObserver(
            forName: .didRevoke,
            object: nil,
            queue: .main
        ) { [weak self] noti in
            if let uid = noti.userInfo?["uid"] as? String {
                self?.didReceiveTokenRevoke(uid: uid)
            }
        }

        dependencies.notificationCenter.addObserver(
            forName: .didFetchSettingsForPrimaryUser,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            if self?.arePrimaryUserSettingsFetched == false {
                self?.arePrimaryUserSettingsFetched = true
                self?.restoreAppStates()
            }
        }

        dependencies.notificationCenter.addObserver(
            forName: .switchView,
            object: nil,
            queue: .main
        ) { [weak self] notification in
            self?.arePrimaryUserSettingsFetched = true
            // trigger the menu to follow the deeplink or show inbox
            self?.handleSwitchViewDeepLinkIfNeeded(notification.object as? DeepLink)
        }

        dependencies.notificationCenter.addObserver(
            forName: .scheduledMessageSucceed,
            object: nil,
            queue: .main
        ) { [weak self] notification in
            guard let tuple = notification.object as? (MessageID, Date, UserID) else { return }
            self?.showScheduledSendSucceedBanner(
                messageID: tuple.0,
                deliveryTime: tuple.1,
                userID: tuple.2
            )
        }

        dependencies.notificationCenter.addObserver(
            forName: .showScheduleSendUnavailable,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.showScheduledSendUnavailableAlert()
        }

        dependencies.notificationCenter.addObserver(
            self,
            selector: #selector(messageSendFailAddressValidationIncorrect),
            name: .messageSendFailAddressValidationIncorrect,
            object: nil
        )

        // This will be triggered when the keymaker clear the mainkey from the memory.
        // We will lock the app at this moment.
        dependencies.notificationCenter.addObserver(
            forName: Keymaker.Const.removedMainKeyFromMemory,
            object: nil,
            queue: .main) { _ in
                self.lock()
            }

            dependencies.notificationCenter.addObserver(
                self,
                selector: #selector(updateUserInterfaceStyle),
                name: .shouldUpdateUserInterfaceStyle,
                object: nil
            )
    }
}

// MARK: DeepLink methods
extension WindowsCoordinator {
    func followDeepLink(_ deepLink: DeepLink) {
        self.deepLink = deepLink
        _ = deepLink.popFirst
        self.start()
    }

    func followDeepDeepLinkIfNeeded(_ deepLink: DeepLink) {
        self.deepLink = deepLink
        _ = deepLink.popFirst

        if arePrimaryUserSettingsFetched {
            start()
        }
    }

    private func handleDeepLinkIfNeeded(_ deepLink: DeepLink) {
        guard arePrimaryUserSettingsFetched else { return }
        self.appWindow.enumerateViewControllerHierarchy { controller, stop in
            if let _ = controller as? MenuViewController,
               let coordinator = self.menuCoordinator {
                coordinator.follow(deepLink)
                stop = true
            }
        }
    }

    private func shouldOpenURL(deepLink: DeepLink?) -> URL? {
        guard let headNode = deepLink?.head else { return nil }

        if headNode.name == .toWebSupportForm {
            return URL(string: .webSupportFormLink)
        }
        if headNode.name == .toWebBrowser {
            guard let urlString = headNode.value else {
                return nil
            }
            return URL(string: urlString)
        }
        return nil
    }

    private func handleWebUrl(url: URL) {
        let linkOpener: LinkOpener = userCachedStatus.browser
        let url = linkOpener.deeplink(to: url)

        if linkOpener == .inAppSafari {
            presentInAppSafari(url: url)
        } else {
            openUrl(url)
        }
    }

    private func openUrl(_ url: URL) {
        guard UIApplication.shared.canOpenURL(url) else {
            SystemLogger.log(message: "url can't be opened by the system: \(url.absoluteString)", isError: true)
            return
        }
        DispatchQueue.main.async {
            UIApplication.shared.open(url)
        }
    }

    private func presentInAppSafari(url: URL) {
        let safari = SFSafariViewController(url: url)
        DispatchQueue.main.async { [weak self] in
            self?.appWindow.topmostViewController()?.present(safari, animated: true)
        }
    }

    private func handleSwitchViewDeepLinkIfNeeded(_ deepLink: DeepLink?) {
        self.deepLink = deepLink
        if let url = shouldOpenURL(deepLink: deepLink) {
            self.deepLink = nil
            handleWebUrl(url: url)
            return
        }
        guard arePrimaryUserSettingsFetched && appWindow != nil else {
            return
        }
        self.appWindow.enumerateViewControllerHierarchy { controller, stop in
            if let _ = controller as? MenuViewController,
               let coordinator = self.menuCoordinator {
                coordinator.handleSwitchView(deepLink: deepLink)
                stop = true
            }
        }
    }
}

// MARK: Actions
extension WindowsCoordinator {
    func willEnterForeground() {
        self.snapshot.remove()
    }

    func didEnterBackground() {
        if let vc = self.currentWindow?.topmostViewController(),
           !(vc is ComposeContainerViewController) {
            vc.view.endEditing(true)
        }
        if let window = self.currentWindow {
            self.snapshot.show(at: window)
        }
    }

    @objc
    private func lock() {
        Breadcrumbs.shared.add(message: "WindowsCoordinator.lock called", to: .randomLogout)
        guard dependencies.usersManager.hasUsers() else {
            Breadcrumbs.shared.add(message: "WindowsCoordinator.lock no users found", to: .randomLogout)
            navigateToSignInFormAndReport(reason: .noUsersFoundInUsersManager(action: #function))
            return
        }
        // The mainkey could be removed while changing the protection of the app. We should check
        // if the lock notification should be ignored by checking the `LockPreventor`
        let isLockSupressed = LockPreventor.shared.isLockSuppressed
        let showOnlyPlaceHolder = showPlaceHolderViewOnly
        guard !isLockSupressed && !showOnlyPlaceHolder else {
            let msg = "lock ignored: isLockSupressed=\(isLockSupressed) showOnlyPlaceHolder=\(showOnlyPlaceHolder)"
            SystemLogger.log(message: msg, category: .appLock)
            return
        }
        go(dest: .lockWindow)
    }

    @objc
    private func unlock() {
        self.lockWindow = nil

        guard dependencies.usersManager.hasUsers() else {
            navigateToSignInFormAndReport(reason: .noUsersFoundInUsersManager(action: "\(#function) \(#line)"))
            return
        }
        if dependencies.usersManager.count <= 0 {
            _ = dependencies.usersManager.clean()
            navigateToSignInFormAndReport(reason: .noUsersFoundInUsersManager(action: "\(#function) \(#line)"))
        } else {
            // To register again in case the registration on app launch didn't go through because the app was locked
            UNUserNotificationCenter.current().delegate = dependencies.pushService
            dependencies.pushService.registerForRemoteNotifications()
            self.go(dest: .appWindow)
        }
    }

    @objc
    private func didReceiveTokenRevoke(uid: String) {
        if let user = dependencies.usersManager.getUser(by: uid),
           !dependencies.usersManager.loggingOutUserIDs.contains(user.userID) {
            let shouldShowBadTokenAlert = dependencies.usersManager.count == 1

            Analytics.shared.sendEvent(.userKickedOut(reason: .apiAccessTokenInvalid))

            dependencies.queueManager.unregisterHandler(for: user.userID, completion: nil)
            dependencies.usersManager.logout(user: user, shouldShowAccountSwitchAlert: true) { [weak self] in
                guard let self = self else { return }
                guard let appWindow = self.appWindow else {return}

                if self.dependencies.usersManager.hasUsers() {
                    appWindow.enumerateViewControllerHierarchy { controller, stop in
                        if let menu = controller as? MenuViewController {
                            // Work Around: trigger viewDidLoad of menu view controller
                            _ = menu.view
                            menu.navigateTo(label: MenuLabel(location: .inbox))
                        }
                    }
                }
                if shouldShowBadTokenAlert {
                    NSError.alertBadToken(in: appWindow)
                }

                let handler = LocalNotificationService(userID: user.userID)
                handler.showSessionRevokeNotification(email: user.defaultEmail)
            }
        }
    }

    @objc
    private func updateUserInterfaceStyle() {
        switch dependencies.darkModeCache.darkModeStatus {
        case .followSystem:
            currentWindow?.overrideUserInterfaceStyle = .unspecified
        case .forceOff:
            currentWindow?.overrideUserInterfaceStyle = .light
        case .forceOn:
            currentWindow?.overrideUserInterfaceStyle = .dark
        }
    }
}

// MARK: Schedule message
extension WindowsCoordinator {

    private func showScheduledSendSucceedBanner(
        messageID: MessageID,
        deliveryTime: Date,
        userID: UserID
    ) {
        let topVC = self.currentWindow?.topmostViewController() ?? UIViewController()

        typealias Key = PMBanner.UserInfoKey
        PMBanner
            .getBanners(in: topVC)
            .filter {
                $0.userInfo?[Key.type.rawValue] as? String == Key.sending.rawValue &&
                $0.userInfo?[Key.messageID.rawValue] as? String == messageID.rawValue
            }
            .forEach { $0.dismiss(animated: false) }

        let timeTuple = PMDateFormatter.shared.titleForScheduledBanner(from: deliveryTime)
        let message = String(format: LocalString._edit_scheduled_button_message,
                             timeTuple.0,
                             timeTuple.1)
        let banner = PMBanner(message: message, style: PMBannerNewStyle.info)
        banner.addButton(text: LocalString._messages_undo_action) { banner in
            self.handleEditScheduleMessage(
                messageID: messageID,
                userID: userID
            ) {
                let deepLink = DeepLink(
                    String(describing: MailboxViewController.self),
                    sender: Message.Location.draft.rawValue
                )
                deepLink.append(
                    .init(name: MailboxCoordinator.Destination.composeScheduledMessage.rawValue,
                          value: messageID.rawValue,
                          states: ["originalScheduledTime": deliveryTime])
                )
                self.dependencies.notificationCenter.post(name: .switchView, object: deepLink)
            }
            banner.dismiss()
        }
        banner.show(at: .bottom, on: topVC)
    }

    private func showScheduledSendUnavailableAlert() {
        let title = LocalString._message_saved_to_draft
        let message = LocalString._schedule_send_unavailable_message
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addOKAction()

        let topVC = self.currentWindow?.topmostViewController() ?? UIViewController()
        topVC.present(alert, animated: true, completion: nil)
    }

    @objc private func messageSendFailAddressValidationIncorrect() {
        let title = LocalString._address_invalid_error_to_draft_action_title
        let toDraftAction = UIAlertAction(title: title, style: .default) { (_) in
            self.dependencies.notificationCenter.post(
                name: .switchView,
                object: DeepLink(
                    String(describing: MailboxViewController.self),
                    sender: Message.Location.draft.rawValue
                )
            )
        }
        UIAlertController.showOnTopmostVC(
            title: LocalString._address_invalid_error_sending_title,
            message: LocalString._address_invalid_error_sending,
            action: toDraftAction
        )
    }

    private func handleEditScheduleMessage(
        messageID: MessageID,
        userID: UserID,
        completion: @escaping () -> Void
    ) {
        let users = dependencies.usersManager
        let user = users.getUser(by: userID)
        user?.messageService.undoSend(
            of: messageID,
            completion: { result in
                guard result.error == nil else {
                    return
                }
                user?.eventsService.fetchEvents(
                    byLabel: Message.Location.allmail.labelID,
                    notificationMessageID: nil,
                    completion: { _ in
                        completion()
                    })
            }
        )
    }
}

extension WindowsCoordinator: MenuCoordinatorDelegate {
    func lockTheScreen() {
        go(dest: .lockWindow)
    }
}

extension WindowsCoordinator: LifetimeTrackable {
    class var lifetimeConfiguration: LifetimeConfiguration {
        .init(maxCount: 1)
    }
}
