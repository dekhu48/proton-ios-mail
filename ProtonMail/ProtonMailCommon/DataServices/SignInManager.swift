//
//  SignInManager.swift
//  ProtonMail - Created on 18/10/2018.
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
import ProtonCore_DataModel
import ProtonCore_Networking
import ProtonCore_Services
import ProtonCore_Login

class SignInManager: Service {
    let usersManager: UsersManager
    let queueManager: QueueManager
    private var lastUpdatedStore: LastUpdatedStoreProtocol
    private(set) var userInfo: UserInfo?
    private(set) var auth: AuthCredential?
    
    init(usersManager: UsersManager, lastUpdatedStore: LastUpdatedStoreProtocol, queueManager: QueueManager) {
        self.usersManager = usersManager
        self.lastUpdatedStore = lastUpdatedStore
        self.queueManager = queueManager
    }
    
    internal func signUpSignIn(username: String,
                         password: String,
                         onError: @escaping (NSError)->Void,
                         onSuccess: @escaping (_ mpwd: String?, _ auth: AuthCredential?, _ userinfo: UserInfo?) -> Void)
    {
        self.auth = nil
        self.userInfo = nil
        // one time api and service
        let service = PMAPIService(doh: usersManager.doh, sessionUID: "")
        service.humanDelegate = HumanVerificationManager.shared.humanCheckHelper(apiService: service)
        service.forceUpgradeDelegate = ForceUpgradeManager.shared.forceUpgradeHelper
        let userService = UserDataService(check: false, api: service)
        userService.sign(in: username,
                         password: password,
                         noKeyUser: true,
                         twoFACode: nil,
                         faillogout: false,
                         ask2fa: nil,
                         onError: onError,
                         onSuccess: onSuccess)
    }
    
    internal func mailboxPassword(from cleartextPassword: String, auth: AuthCredential) -> String {
        var mailboxPassword = cleartextPassword
        if let keysalt = auth.passwordKeySalt, !keysalt.isEmpty {
            let keysalt_byte: Data = keysalt.decodeBase64()
            mailboxPassword = PasswordUtils.getMailboxPassword(cleartextPassword, salt: keysalt_byte)
        }
        return mailboxPassword
    }

    func finalizeSignIn(loginData: LoginData,
                        onError: @escaping (NSError) -> Void,
                        reachLimit: @escaping () -> Void,
                        existError: @escaping () -> Void,
                        showSkeleton: @escaping () -> Void,
                        tryUnlock: @escaping () -> Void) {
        let userInfo = loginData.toUserInfo
        let auth = loginData.credential
        if self.usersManager.isExist(userID: userInfo.userId) {
            existError()
            return
        }

        self.usersManager.add(auth: auth, user: userInfo)
        self.auth = nil
        self.userInfo = nil

        let user = self.usersManager.getUser(bySessionID: auth.sessionID)!
        self.queueManager.registerHandler(user.mainQueueHandler)

        showSkeleton()

        let userDataService = user.userService
        userDataService.fetchSettings(userInfo: userInfo, auth: auth).done(on: .main) { [weak self] userInfo in
            guard let self = self else { return }
            self.usersManager.update(auth: auth, user: userInfo)
            userCachedStatus.initialSwipeActionIfNeeded(leftToRight: userInfo.swipeLeft,
                                                        rightToLeft: userInfo.swipeRight)

            guard userInfo.delinquent < 3 else {
                self.queueManager.unregisterHandler(user.mainQueueHandler)
                _ = self.usersManager.logout(user: user, shouldShowAccountSwitchAlert: false).ensure {
                    onError(NSError.init(domain: "", code: 0, localizedDescription: LocalString._general_account_disabled_non_payment))
                }
                return
            }

            self.usersManager.loggedIn()
            self.usersManager.active(uid: auth.sessionID)
            self.lastUpdatedStore.contactsCached = 0
            UserTempCachedStatus.restore()
            NotificationCenter.default.post(name: .didSignIn, object: nil)

            tryUnlock()
        }.catch(on: .main) { [weak self] (error) in
            onError(error as NSError)
            _ = self?.usersManager.clean()
            // this will happen if fetchUserInfo fails - maybe because of connectivity issues
        }
    }
}
