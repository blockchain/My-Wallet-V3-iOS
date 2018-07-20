//
//  KeychainItemWrapper.swift
//  Blockchain
//
//  Created by Justin on 7/19/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

protocol KeychainFlow {
    static func guid() -> String?
    static func hashedGuid() -> String?
    static func setGuidInKeychain(_ guid: String?)
    static func removeGuidFromKeychain()
    static func sharedKey() -> String?
    static func setSharedKeyInKeychain(_ sharedKey: String?)
    static func removeSharedKeyFromKeychain()
    static func setPINInKeychain(_ pin: String?)
    static func pinFromKeychain() -> String?
    static func removePinFromKeychain()
}

extension KeychainItemWrapper: KeychainFlow {
    // MARK: - GUID

    static func guid() -> String? {
        // Attempt to migrate guid from NSUserDefaults to KeyChain

        let guidFromUserDefaults = UserDefaults.User.string(forKey: .guid)
        if guidFromUserDefaults != nil {
            self.setGuidInKeychain(guidFromUserDefaults)
            if self.guidFromKeychain() != nil {
                UserDefaults.User.remove(forKey: .guid)
                // Remove all UIWebView cached data for users upgrading from older versions
                URLCache.shared.removeAllCachedResponses()
            } else {
                print("failed to set GUID in keychain")
                return guidFromUserDefaults
            }
        }
        return self.guidFromKeychain()
    }

    class func setGuidInKeychain(_ guid: String?) {
        let keychain = KeychainItemWrapper(identifier: "guid", accessGroup: nil)
        keychain?.setObject(kSecAttrAccessibleWhenUnlockedThisDeviceOnly, forKey: kSecAttrAccessible)
        keychain?.setObject("guid", forKey: kSecAttrAccount)
        keychain?.setObject(guid?.data(using: String.Encoding(rawValue: String.Encoding.utf8.rawValue)), forKey: kSecValueData)
    }

    class func guidFromKeychain() -> String? {
        let keychain = KeychainItemWrapper(identifier: "guid", accessGroup: nil)
        let guidData = keychain?.object(forKey: kSecValueData) as? Data
        var guid: String? = nil
        if let aData = guidData {
            guid = String(data: aData, encoding: .utf8)
        }
        return (guid?.count ?? 0) == 0 ? nil : guid
    }

    class func removeGuidFromKeychain() {
        let keychain = KeychainItemWrapper(identifier: "guid", accessGroup: nil)
        keychain?.resetKeychainItem()
    }

    class func hashedGuid() -> String? {
        return self.guid()?.sha256()
    }

    // MARK: - SharedKey
    class func sharedKey() -> String? {
        // Migrate sharedKey from NSUserDefaults (for users updating from old version)

        let sharedKeyFromUserDefaults =  UserDefaults.User.string(forKey: .sharedKey)
        if sharedKeyFromUserDefaults != nil {
            self.setSharedKeyInKeychain(sharedKeyFromUserDefaults)
            if self.sharedKeyFromKeychain() != nil {
                UserDefaults.User.remove(forKey: .sharedKey)
            } else {
                print("!!! failed to set sharedKey in keychain ???")
                return sharedKeyFromUserDefaults
            }
        }
        return self.sharedKeyFromKeychain()
    }
    
    class func sharedKeyFromKeychain() -> String? {
        guard let keychain = KeychainItemWrapper(identifier: "sharedKey", accessGroup: nil) else {
            return nil
        }
        let sharedKeyData = keychain.object(forKey: kSecValueData) as? Data
        var sharedKey: String? = nil
        if let aData = sharedKeyData {
            sharedKey = String(data: aData, encoding: .utf8)
        }
        return (sharedKey?.count ?? 0) == 0 ? nil : sharedKey
    }

    class func setSharedKeyInKeychain(_ sharedKey: String?) {
        if let keychain = KeychainItemWrapper(identifier: "sharedKey", accessGroup: nil) {
            keychain.setObject(kSecAttrAccessibleWhenUnlockedThisDeviceOnly, forKey: kSecAttrAccessible)
            keychain.setObject("sharedKey", forKey: kSecAttrAccount)
            keychain.setObject(sharedKey?.data(using: String.Encoding(rawValue: String.Encoding.utf8.rawValue)), forKey: kSecAttrAccount)
        } else {
            return
        }
    }

    class func removeSharedKeyFromKeychain() {
        let keychain = KeychainItemWrapper(identifier: "sharedKey", accessGroup: nil)
        keychain?.resetKeychainItem()
    }

    // MARK: - PIN
    class func setPINInKeychain(_ pin: String?) {
        let keychain = KeychainItemWrapper(identifier: "pin", accessGroup: nil)
        keychain?.setObject(kSecAttrAccessibleWhenUnlockedThisDeviceOnly, forKey: kSecAttrAccessible)
        keychain?.setObject("pin", forKey: kSecAttrAccount)
        keychain?.setObject(pin?.data(using: String.Encoding(rawValue: String.Encoding.utf8.rawValue)), forKey: kSecValueData)
    }

    class func pinFromKeychain() -> String? {
        let keychain = KeychainItemWrapper(identifier: "pin", accessGroup: nil)
        let pinData = keychain?.object(forKey: kSecValueData) as? Data
        var pin: String? = nil
        if let aData = pinData {
            pin = String(data: aData, encoding: .utf8)
        }
        return (pin?.count ?? 0) == 0 ? nil : pin
    }

    class func removePinFromKeychain() {
        let keychain = KeychainItemWrapper(identifier: "pin", accessGroup: nil)
        keychain?.resetKeychainItem()
    }
}
