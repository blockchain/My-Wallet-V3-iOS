//
//  BlockchainSettings.swift
//  Blockchain
//
//  Created by Chris Arriola on 4/17/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

protocol KeyNamespaceable { }

protocol BCSettings: KeyNamespaceable {
    associatedtype SettingsKey: RawRepresentable
}

extension KeyNamespaceable {
    private static func namespace(_ key: String) -> String {
        return key
    }

    static func namespace<T: RawRepresentable>(_ key: T) -> String where T.RawValue == String {
        return namespace(key.rawValue)
    }
}

extension BCSettings where SettingsKey.RawValue == String {

    // Primitives
    static func set(_ obj: Any, forKey key: SettingsKey) {
        let key = namespace(key)
        UserDefaults.standard.set(obj, forKey: key)
    }

    static func get(forKey key: SettingsKey) -> Any? {
        let key = namespace(key)
        return UserDefaults.standard.object(forKey: key)
    }

    static func remove(forKey key: SettingsKey) {
        let key = namespace(key)
        UserDefaults.standard.removeObject(forKey: key)
    }

    // Bools
    static func set(_ bool: Bool, forKey key: SettingsKey) {
        let key = namespace(key)
        UserDefaults.standard.set(bool, forKey: key)
    }

    static func bool(forKey key: SettingsKey) -> Bool {
        let key = namespace(key)
        return UserDefaults.standard.bool(forKey: key)
    }

    // Strings
    static func set(_ string: String, forKey key: SettingsKey) {
        let key = namespace(key)
        UserDefaults.standard.set(NSString(string: string), forKey: key)
    }

    static func string(forKey key: SettingsKey) -> String? {
        let key = namespace(key)
        return UserDefaults.standard.string(forKey: key)
    }

    // Floats
    static func set(_ float: Float, forKey key: SettingsKey) {
        let key = namespace(key)
        UserDefaults.standard.set(float, forKey: key)
    }

    static func float(forKey key: SettingsKey) -> Float {
        let key = namespace(key)
        return UserDefaults.standard.float(forKey: key)
    }

    // Ints
    static func set(_ integer: Int, forKey key: SettingsKey) {
        let key = namespace(key)
        UserDefaults.standard.set(integer, forKey: key)
    }

    static func integer(forKey key: SettingsKey) -> Int {
        let key = namespace(key)
        return UserDefaults.standard.integer(forKey: key)
    }

    // Objects
    static func set(_ object: AnyObject, forKey key: SettingsKey) {
        let key = namespace(key)
        UserDefaults.standard.set(object, forKey: key)
    }

    static func object(forKey key: SettingsKey) -> Any? {
        let key = namespace(key)
        return UserDefaults.standard.object(forKey: key)
    }

    // Doubles
    static func set(_ double: Double, forKey key: SettingsKey) {
        let key = namespace(key)
        UserDefaults.standard.set(double, forKey: key)
    }

    static func double(forKey key: SettingsKey) -> Double {
        let key = namespace(key)
        return UserDefaults.standard.double(forKey: key)
    }

    //URLs
    static func set(_ url: URL, forKey key: SettingsKey) {
        let key = namespace(key)
        UserDefaults.standard.set(url, forKey: key)
    }

    static func url(forKey key: SettingsKey) -> URL? {
        let key = namespace(key)
        return UserDefaults.standard.url(forKey: key)
    }
}

extension UserDefaults {
    struct System: BCSettings {
        private init() { }
        //swiftlint:disable next nesting
        enum SettingsKey: String {
            case reminderModalDate,
            certificatePinning,
            symbolLocal,
            appBecameActiveCount
        }
    }
    struct User: BCSettings {
        private init() { }
        //swiftlint:disable next nesting
        enum SettingsKey: String {
            case encryptedPINPassword, reminderModalDate,
            pinKey,
            passwordPartHash,
            defaultAccountLabelledAddressesCount,
            hasEndedFirstSession, hasSeenEmailReminder, biometryEnabled,
            swipeToReceive, hideTransferAllFundsAlert, dontAskUserToShowAppReviewPrompt,
            didFailBiometrySetup, hasSeenUpgradeToHdScreen, shouldShowBiometrySetup,
            firstRun, shouldHideBuySellNotificationCard, hasSeenAllCards, password, pin, guid, sharedKey
        }
    }
}
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

    @objc class func sharedOnboardingInstance() -> Onboarding {
        return Onboarding.shared
    }

    // MARK: - App

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

        // MARK: - Properties

        @objc var appBecameActiveCount: Int {
            get {
                return UserDefaults.System.integer(forKey: .appBecameActiveCount)
            }
            set {
                UserDefaults.System.set(newValue, forKey: .appBecameActiveCount)
            }
        }

        /// The encrypted wallet password (encryption key was generated by the user's pin)
        @objc var encryptedPinPassword: String? {
            get {
                return UserDefaults.User.string(forKey: .encryptedPINPassword)
            }
            set {
                if let hasPin = newValue {
                    UserDefaults.User.set(hasPin, forKey: .encryptedPINPassword)
                }
            }
        }

        @objc var walletGuid: String? {
            get {
                return UserDefaults.User.string(forKey: .guid)
            }
            set {
                if let hasPin = newValue {
                    UserDefaults.User.set(hasPin, forKey: .guid)
                }
            }
        }

        @objc var enableCertificatePinning: Bool {
            get {
                return UserDefaults.System.bool(forKey: .certificatePinning)
            }
            set {
                UserDefaults.System.set(newValue, forKey: .certificatePinning)
            }
        }

        @objc var hasEndedFirstSession: Bool {
            get {
                return UserDefaults.User.bool(forKey: .hasEndedFirstSession)
            }
            set {
                UserDefaults.User.set(newValue, forKey: .hasEndedFirstSession)
            }
        }

        @objc var hasSeenEmailReminder: Bool {
            get {
                return UserDefaults.User.bool(forKey: .hasSeenEmailReminder)
            }
            set {
                UserDefaults.User.set(newValue, forKey: .hasSeenEmailReminder)
            }
        }

        @objc var pin: String? {
            get {
                return KeychainItemWrapper.pinFromKeychain()
            }
            set {
                guard let pin = newValue else {
                    KeychainItemWrapper.removePinFromKeychain()
                    return
                }
                KeychainItemWrapper.setPINInKeychain(pin)
            }
        }

        @objc var isPinSet: Bool {
            return pinKey != nil && encryptedPinPassword != nil
        }

        @objc var pinKey: String? {
            get {
                return UserDefaults.User.string(forKey: .pinKey)
            }
            set {
                if let pinKey = newValue {
                    UserDefaults.User.set(pinKey, forKey: .pinKey)
                }
            }
        }

        var onSymbolLocalChanged: ((Bool) -> ())?

        /// Property indicating whether or not the currency symbol that should be used throughout the app
        /// should be fiat, if set to true, or the asset-specific symbol, if false.
        @objc var symbolLocal: Bool {
            get {
                return UserDefaults.System.bool(forKey: .symbolLocal)
            }
            set {
                let oldValue = symbolLocal
                UserDefaults.System.set(newValue, forKey: .symbolLocal)
                if oldValue != newValue {
                    onSymbolLocalChanged?(newValue)
                }
            }
        }

        /// The first 5 characters of SHA256 hash of the user's password
        @objc var passwordPartHash: String? {
            get {
                return UserDefaults.User.string(forKey: .passwordPartHash)
            }
            set {
                if let pph = newValue {
                     UserDefaults.User.set(pph, forKey: .passwordPartHash)
                }
            }
        }

        @objc var biometryEnabled: Bool {
            get {
                return UserDefaults.User.bool(forKey: .biometryEnabled)
            }
            set {
                UserDefaults.User.set(newValue, forKey: .biometryEnabled)
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
                return UserDefaults.User.get(forKey: .reminderModalDate) as? NSDate
            }
            set {
                guard let date = newValue else {
                    UserDefaults.User.remove(forKey: .reminderModalDate)
                    return
                }
                UserDefaults.User.set(date, forKey: .reminderModalDate)
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

        @objc var swipeToReceiveEnabled: Bool {
            get {
                return UserDefaults.User.bool(forKey: .swipeToReceive)
            }
            set {
                UserDefaults.User.set(newValue, forKey: .swipeToReceive)
            }
        }

        @objc var hideTransferAllFundsAlert: Bool {
            get {
                return UserDefaults.User.bool(forKey: .hideTransferAllFundsAlert)
            }
            set {
                UserDefaults.User.set(newValue, forKey: .hideTransferAllFundsAlert)
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

        /// Number of labelled addresses for default account
        @objc var defaultAccountLabelledAddressesCount: Int {
            get {
                return UserDefaults.User.integer(forKey: .defaultAccountLabelledAddressesCount)
            }
            set {
                UserDefaults.User.set(newValue, forKey: .defaultAccountLabelledAddressesCount)
            }
        }

        @objc var dontAskUserToShowAppReviewPrompt: Bool {
            get {
                return UserDefaults.User.bool(forKey: .dontAskUserToShowAppReviewPrompt)
            }
            set {
                UserDefaults.User.set(newValue, forKey: .dontAskUserToShowAppReviewPrompt)
            }
        }

        private override init() {
            // Private initializer so that `shared` and `sharedInstance` are the only ways to
            // access an instance of this class.
            super.init()

            defaults.register(defaults: [
                UserDefaults.Keys.swipeToReceiveEnabled.rawValue: true,
                UserDefaults.Keys.assetType.rawValue: AssetType.bitcoin.rawValue,
                UserDefaults.DebugKeys.enableCertificatePinning.rawValue: true
            ])
            migratePasswordAndPinIfNeeded()
            handleMigrationIfNeeded()
        }

        // MARK: - Public

        func clearPin() {
            pin = nil
            encryptedPinPassword = nil
            pinKey = nil
            passwordPartHash = nil
            AuthenticationCoordinator.shared.lastEnteredPIN = Pin.Invalid
        }

        /// Migrates pin and password from NSUserDefaults to the Keychain
        func migratePasswordAndPinIfNeeded() {
            guard let password = UserDefaults.User.string(forKey: .password),
                let pinStr = UserDefaults.User.string(forKey: .pin),
                let pinUInt = UInt(pinStr) else {
                    return
            }

            WalletManager.shared.wallet.password = password

            try? Pin(code: pinUInt).save()
            UserDefaults.User.remove(forKey: .password)
            UserDefaults.User.remove(forKey: .pin)
        }

        //: Handles settings migration when keys change
        func handleMigrationIfNeeded() {
            defaults.migrateLegacyKeysIfNeeded()
        }
    }

    // MARK: - App

    /// Encapsulates all onboarding-related settings for the user
    @objc class Onboarding: NSObject {
        static let shared: Onboarding = Onboarding()

        private lazy var defaults: UserDefaults = {
            return UserDefaults.standard
        }()

        /// Property indicating if setting up biometric authentication failed
        var didFailBiometrySetup: Bool {
            get {
                return UserDefaults.User.bool(forKey: .didFailBiometrySetup)
            }
            set {
                UserDefaults.User.set(newValue, forKey: .didFailBiometrySetup)
            }
        }

        /// Property indicating if the user saw the HD wallet upgrade screen
        var hasSeenUpgradeToHdScreen: Bool {
            get {
                return UserDefaults.User.bool(forKey: .hasSeenUpgradeToHdScreen)
            }
            set {
                UserDefaults.User.set(newValue, forKey: .hasSeenUpgradeToHdScreen)
            }
        }

        /// Property indicating if the biometric authentication set-up should be shown to the user
        var shouldShowBiometrySetup: Bool {
            get {
                return UserDefaults.User.bool(forKey: .shouldShowBiometrySetup)
            }
            set {
                UserDefaults.User.set(newValue, forKey: .shouldShowBiometrySetup)
            }
        }

        /// Property indicating if this is the first time the user is running the application
        var firstRun: Bool {
            get {
                return UserDefaults.User.bool(forKey: .firstRun)
            }
            set {
                UserDefaults.User.set(newValue, forKey: .firstRun)
            }
        }

        /// Property indicating if the buy/sell onboarding card should be shown
        @objc var shouldHideBuySellCard: Bool {
            get {
                return UserDefaults.User.bool(forKey: .shouldHideBuySellNotificationCard)
            }
            set {
                UserDefaults.User.set(newValue, forKey: .shouldHideBuySellNotificationCard)
            }
        }

        /// Property indicating if the user has seen all onboarding cards
        @objc var hasSeenAllCards: Bool {
            get {
                return UserDefaults.User.bool(forKey: .hasSeenAllCards)
            }
            set {
                UserDefaults.User.set(newValue, forKey: .hasSeenAllCards)
            }
        }

        private override init() {
            super.init()
        }
    }

    private override init() {
        // Private initializer so that an instance of BLockchainSettings can't be created
        super.init()
    }
}
