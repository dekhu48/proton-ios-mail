//
//  Crypto.swift
//  ProtonMail - Created on 9/11/19.
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
import Crypto
import CryptoKit
import ProtonCore_Crypto
import ProtonCore_DataModel

typealias SplitMessage        = CryptoPGPSplitMessage
typealias SymmetricKey        = CryptoSessionKey

/// Helper
class MailCrypto {

    enum CryptoError: Error {
        case failedGeneratingKeypair(Error?)
        case verificationFailed
        case decryptionFailed
    }

    private let EXPECTED_TOKEN_LENGTH: Int = 64

    // delete this method once it's upstreamed to Core
    func decrypt(encrypted message: String, keys: [(privateKey: String, passphrase: String)]) throws -> String {
        let keyRing = try buildPrivateKeyRing(keys: keys)

        var error: NSError?
        let pgpMsg = CryptoNewPGPMessageFromArmored(message, &error)
        if let err = error {
            throw err
        }

        let plainMessage = try keyRing.decrypt(pgpMsg, verifyKey: nil, verifyTime: 0)
        return plainMessage.getString()
    }

    // MARK: - Message

    func verifyDetached(signature: String, plainText: String, binKeys: [Data], verifyTime: Int64) throws -> Bool {
        var error: NSError?

        guard let publicKeyRing = buildPublicKeyRing(keys: binKeys) else {
            return false
        }

        let plainMessage = CryptoNewPlainMessageFromString(plainText)
        let signature = CryptoNewPGPSignatureFromArmored(signature, &error)
        if let err = error {
            throw err
        }

        do {
            try publicKeyRing.verifyDetached(plainMessage, signature: signature, verifyTime: verifyTime)
            return true
        } catch {
            return false
        }
    }

    /**
     * Check that the key token is a 32 byte value encoded in hexadecimal form.
     */
    private func verifyTokenFormat(decryptedToken: String) -> Bool {
        decryptedToken.count == EXPECTED_TOKEN_LENGTH && decryptedToken.allSatisfy { $0.isHexDigit }
    }

    // MARK: - static

    static func updateTime( _ time: Int64, processInfo: SystemUpTimeProtocol? = nil) {
        if var processInfo = processInfo {
            processInfo.updateLocalSystemUpTime(time: processInfo.systemUpTime)
            processInfo.localServerTime = TimeInterval(time)
        }
        CryptoUpdateTime(time)
    }

    // delete this method once it's upstreamed to Core
    func buildPrivateKeyRing(keys: [(privateKey: String, passphrase: String)]) throws -> CryptoKeyRing {
        var error: NSError?

        guard let privateKeyRing = CryptoNewKeyRing(nil, &error) else {
            throw ProtonCore_Crypto.CryptoError.couldNotCreateKeyRing
        }

        for key in keys {
            let lockedKey = CryptoNewKeyFromArmored(key.privateKey, &error)

            if let err = error {
                throw err
            }

            let passSlic = Data(key.passphrase.utf8)

            do {
                let unlockedKey = try lockedKey?.unlock(passSlic)
                try privateKeyRing.add(unlockedKey)
            } catch {
                continue
            }
        }
        return privateKeyRing
    }

    func buildPublicKeyRing(keys: [Data]) -> CryptoKeyRing? {
        var error: NSError?
        let newKeyRing = CryptoNewKeyRing(nil, &error)
        guard let keyRing = newKeyRing else {
            return nil
        }
        for key in keys {
            do {
                guard let keyToAdd = CryptoNewKey(key, &error) else {
                    continue
                }
                guard keyToAdd.isPrivate() else {
                    try keyRing.add(keyToAdd)
                    continue
                }
                guard let publicKeyData = try? keyToAdd.getPublicKey() else {
                    continue
                }
                var error: NSError?
                let publicKey = CryptoNewKey(publicKeyData, &error)
                if let error = error {
                    throw error
                } else {
                    try keyRing.add(publicKey)
                }
            } catch {
                continue
            }
        }
        return keyRing
    }

    static func generateRandomKeyPair() throws -> (passphrase: String, publicKey: String, privateKey: String) {
        let passphrase = UUID().uuidString
        let username = UUID().uuidString
        let domain = "protonmail.com"
        let email = "\(username)@\(domain)"
        let keyType = "x25519"
        var error: NSError?

        guard let unlockedKey = CryptoGenerateKey(username, email, keyType, 0, &error) else {
            throw CryptoError.failedGeneratingKeypair(error)
        }

        let cryptoKey = try unlockedKey.lock(passphrase.data(using: .utf8))
        unlockedKey.clearPrivateParams()

        let publicKey = cryptoKey.getArmoredPublicKey(&error)
        if let concreteError = error {
            throw CryptoError.failedGeneratingKeypair(concreteError)
        }
        let privateKey = cryptoKey.armor(&error)
        if let concreteError = error {
            throw CryptoError.failedGeneratingKeypair(concreteError)
        }

        return (passphrase, publicKey, privateKey)
    }

    // Extracts the right passphrase for migrated/non-migrated keys and verifies the signature
    static func getAddressKeyPassphrase(userKeys: [Data], passphrase: String, key: Key) throws -> String {
        guard let token = key.token, let signature = key.signature else {
            return passphrase
        }

        let plainToken = try token.decryptMessageNonOptional(binKeys: userKeys, passphrase: passphrase)

        guard MailCrypto().verifyTokenFormat(decryptedToken: plainToken) else {
            throw Self.CryptoError.verificationFailed
        }

        let verification = try MailCrypto().verifyDetached(signature: signature,
                                                           plainText: plainToken,
                                                           binKeys: userKeys,
                                                           verifyTime: 0) // Temporary: ignore time to support devices with wrong time
        if verification == true {
            return plainToken
        } else {
            throw Self.CryptoError.verificationFailed
        }
    }
}
