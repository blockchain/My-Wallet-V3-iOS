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

        @objc var didFailTouchIDSetup: Bool {
            get {
                return defaults.bool(forKey: UserDefaults.Keys.didFailTouchIDSetup.rawValue)
            }
            set {
                defaults.set(newValue, forKey: UserDefaults.Keys.didFailTouchIDSetup.rawValue)
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

        @objc var enableCertificatePinning: Bool {
            get {
                return defaults.bool(forKey: UserDefaults.DebugKeys.enableCertificatePinning.rawValue)
            }
            set {
                defaults.set(newValue, forKey: UserDefaults.DebugKeys.enableCertificatePinning.rawValue)
            }
        }

        @objc var firstRun: Bool {
            get {
                return defaults.bool(forKey: UserDefaults.Keys.firstRun.rawValue)
            }
            set {
                defaults.set(newValue, forKey: UserDefaults.Keys.firstRun.rawValue)
            }
        }

        @objc var hasEndedFirstSession: Bool {
            get {
                return defaults.bool(forKey: UserDefaults.Keys.hasEndedFirstSession.rawValue)
            }
            set {
                defaults.set(newValue, forKey: UserDefaults.Keys.hasEndedFirstSession.rawValue)
            }
        }

        @objc var hasSeenAllCards: Bool {
            get {
                return defaults.bool(forKey: UserDefaults.Keys.hasSeenAllCards.rawValue)
            }
            set {
                defaults.set(newValue, forKey: UserDefaults.Keys.hasSeenAllCards.rawValue)
            }
        }

        @objc var hasSeenEmailReminder: Bool {
            get {
                return defaults.bool(forKey: UserDefaults.Keys.hasSeenEmailReminder.rawValue)
            }
            set {
                defaults.set(newValue, forKey: UserDefaults.Keys.hasSeenEmailReminder.rawValue)
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

        @objc var symbolLocal: Bool {
            get {
                return defaults.bool(forKey: UserDefaults.Keys.symbolLocal.rawValue)
            }
            set {
                defaults.set(newValue, forKey: UserDefaults.Keys.symbolLocal.rawValue)
            }
        }

        /// The first 5 characters of SHA256 hash of the user's password
        @objc var passwordPartHash: String? {
            get {
                return defaults.string(forKey: UserDefaults.Keys.passwordPartHash.rawValue)
            }
            set {
                defaults.set(newValue, forKey: UserDefaults.Keys.passwordPartHash.rawValue)
            }
        }

        @objc var touchIDEnabled: Bool {
            get {
                return defaults.bool(forKey: UserDefaults.Keys.touchIDEnabled.rawValue)
            }
            set {
                defaults.set(newValue, forKey: UserDefaults.Keys.touchIDEnabled.rawValue)
            }
        }

        @objc var guid: String? {
            get {
                return KeychainItemWrapper.guid()
            }
            set {
                guard let guid = newValue else {
                    KeychainItemWrapper.removeGuidFromKeychain()
                    return
                }
                KeychainItemWrapper.setGuidInKeychain(guid)
            }
        }

        @objc var reminderModalDate: NSDate? {
            get {
                return defaults.object(forKey: UserDefaults.Keys.reminderModalDate.rawValue) as? NSDate
            }
            set {
                guard let date = newValue else {
                    defaults.removeObject(forKey: UserDefaults.Keys.reminderModalDate.rawValue)
                    return
                }
                defaults.set(date, forKey: UserDefaults.Keys.reminderModalDate.rawValue)
            }
        }

        @objc var sharedKey: String? {
            get {
                return KeychainItemWrapper.sharedKey()
            }
           
            
            set {
                guard let sharedKey = newValue else {
                    KeychainItemWrapper.removeSharedKeyFromKeychain()
                    return
                }
                KeychainItemWrapper.setSharedKeyInKeychain(sharedKey)
            }
        }
        
        @objc var shouldHideAllCards: Bool {
            get {
                return defaults.bool(forKey: UserDefaults.Keys.shouldHideAllCards.rawValue)
            }
            set {
                defaults.set(newValue, forKey: UserDefaults.Keys.shouldHideAllCards.rawValue)
            }
        }
        
        @objc var shouldHideBuySellCard: Bool {
            get {
                return defaults.bool(forKey: UserDefaults.Keys.shouldHideBuySellCard.rawValue)
            }
            set {
                defaults.set(newValue, forKey: UserDefaults.Keys.shouldHideBuySellCard.rawValue)
            }
        }

        @objc var shouldShowTouchIDSetup: Bool {
            get {
                return defaults.bool(forKey: UserDefaults.Keys.shouldShowTouchIDSetup.rawValue)
            }
            set {
                defaults.set(newValue, forKey: UserDefaults.Keys.shouldShowTouchIDSetup.rawValue)
            }
        }

        @objc var swipeToReceiveEnabled: Bool {
            get {
                return defaults.bool(forKey: UserDefaults.Keys.swipeToReceiveEnabled.rawValue)
            }
            set {
                defaults.set(newValue, forKey: UserDefaults.Keys.swipeToReceiveEnabled.rawValue)
            }
        }

        @objc var hideTransferAllFundsAlert: Bool {
            get {
                return defaults.bool(forKey: UserDefaults.Keys.hideTransferAllFundsAlert.rawValue)
            }
            set {
                defaults.set(newValue, forKey: UserDefaults.Keys.hideTransferAllFundsAlert.rawValue)
            }
        }

        /// Ether address to be used for swipe to receive
        @objc var swipeAddressForEther: String? {
            get {
                return KeychainItemWrapper.getSwipeEtherAddress()
            }
            set {
                guard let etherAddress = newValue else {
                    KeychainItemWrapper.removeSwipeEtherAddress()
                    return
                }
                KeychainItemWrapper.setSwipeEtherAddress(etherAddress)
            }
        }

        private override init() {
            // Private initializer so that `shared` and `sharedInstance` are the only ways to
            // access an instance of this class.
            super.init()

            defaults.register(defaults: [
                UserDefaults.Keys.swipeToReceiveEnabled.rawValue: true,
                //: Was initialized with `NSNumber numberWithInt:AssetTypeBitcoin` before, could cause side unwanted effects...
                // TODO: test for potential side effects
                UserDefaults.Keys.assetType.rawValue: AssetType.bitcoin.rawValue,
                UserDefaults.DebugKeys.enableCertificatePinning.rawValue: true
            ])
        }

        func clearPin() {
            encryptedPinPassword = nil
            pinKey = nil
            passwordPartHash = nil
            AuthenticationCoordinator.shared.lastEnteredPIN = Pin.Invalid
        }
    }

    private override init() {
        // Private initializer so that an instance of BLockchainSettings can't be created
        super.init()
    }
}
