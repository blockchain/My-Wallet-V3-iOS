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

    // class function declared so that the BlockchainSettings singleton can be accessed from obj-C
    // TODO remove this once all Obj-C references of this file have been removed
    @objc class func sharedAppInstance() -> App {
        return App.shared
    }

    @objc
    final class App: NSObject {
        static let shared = App()

        private lazy var defaults: UserDefaults = {
            return UserDefaults.standard
        }()

        // class function declared so that the App singleton can be accessed from obj-C
        @objc class func sharedInstance() -> App {
            return App.shared
        }

        @objc var firstRun: Bool {
            get {
                return defaults.bool(forKey: UserDefaults.Keys.firstRun.rawValue)
            }
            set {
                defaults.set(newValue, forKey: UserDefaults.Keys.firstRun.rawValue)
            }
        }

        @objc var hasSeenUpgradeToHdScreen: Bool {
            get {
                return defaults.bool(forKey: UserDefaults.Keys.hasSeenUpgradeToHdScreen.rawValue)
            }
            set {
                defaults.set(newValue, forKey: UserDefaults.Keys.hasSeenUpgradeToHdScreen.rawValue)
            }
        }

        @objc var isPinSet: Bool {
            return pinKey != nil && encryptedPinPassword != nil
        }

        @objc var pinKey: String? {
            get {
                return defaults.string(forKey: UserDefaults.Keys.pinKey.rawValue)
            }
            set {
                defaults.set(newValue, forKey: UserDefaults.Keys.pinKey.rawValue)
            }
        }

        @objc var encryptedPinPassword: String? {
            get {
                return defaults.string(forKey: UserDefaults.Keys.encryptedPinPassword.rawValue)
            }
            set {
                defaults.set(newValue, forKey: UserDefaults.Keys.encryptedPinPassword.rawValue)
            }
        }

        private override init() {
            // Private initializer so that `shared` and `sharedInstance` are the only ways to
            // access an instance of this class.
            super.init()
        }
    }

    private override init() {
        // Private initializer so that an instance of BLockchainSettings can't be created
        super.init()
    }
}
