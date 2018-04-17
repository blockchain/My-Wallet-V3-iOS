//
//  BlockchainSettings.swift
//  Blockchain
//
//  Created by Chris Arriola on 4/17/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

/**
 Settings for the current user.
 All settings are written and read from NSUserDefaults.
*/
@objc
final class BlockchainSettings: NSObject {
    static let shared = BlockchainSettings()
    
    // class function declared so that the BlockchainSettings singleton can be accessed from obj-C
    @objc class func sharedInstance() -> BlockchainSettings {
        return BlockchainSettings.shared
    }
    
    private override init() {
        // Private initializer so that `shared` and `sharedInstance` are the only ways to
        // access an instance of this class.
        super.init()
    }
    
    @objc var isPinSet: Bool {
        return pinKey != nil && encryptedPinPassword != nil
    }
    
    @objc var pinKey: String? {
        get {
            return defaults.string(forKey: SettingsKeys.pinKey)
        }
        set {
            defaults.set(newValue, forKey: SettingsKeys.pinKey)
        }
    }
    
    @objc var encryptedPinPassword: String? {
        get {
            return defaults.string(forKey: SettingsKeys.encryptedPinPassword)
        }
        set {
            defaults.set(newValue, forKey: SettingsKeys.encryptedPinPassword)
        }
    }
    
    private lazy var defaults: UserDefaults = {
       return UserDefaults.standard
    }()
    
    private struct SettingsKeys {
        static let pinKey = "pinKey"
        static let encryptedPinPassword = "encryptedPINPassword"
    }
}
