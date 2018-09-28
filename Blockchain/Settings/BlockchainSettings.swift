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

        /**
         Determines if the application should *ask the system* to show the app review prompt.

         - Note:
         This value increments whenever the application is launched or enters the foreground.

         - Important:
         This setting **should** be set reset upon logging the user out of the application.
         */
        @objc var appBecameActiveCount: Int {
            get {
                return defaults.integer(forKey: UserDefaults.Keys.appBecameActiveCount.rawValue)
            }
            set {
                defaults.set(newValue, forKey: UserDefaults.Keys.appBecameActiveCount.rawValue)
            }
        }

        /**
         Stores the encrypted wallet password.

         - Note:
         The value of this setting is the result of calling the `encrypt(_ data: String, password: String)` function of the wallet.

         - Important:
         The encryption key is generated from the pin created by the user.
        */
        var encryptedPinPassword: String? {
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

        @objc var hasEndedFirstSession: Bool {
            get {
                return defaults.bool(forKey: UserDefaults.Keys.hasEndedFirstSession.rawValue)
            }
            set {
                defaults.set(newValue, forKey: UserDefaults.Keys.hasEndedFirstSession.rawValue)
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
                return defaults.string(forKey: UserDefaults.Keys.pinKey.rawValue)
            }
            set {
                defaults.set(newValue, forKey: UserDefaults.Keys.pinKey.rawValue)
            }
        }

        var onSymbolLocalChanged: ((Bool) -> Void)?

        /// Property indicating whether or not the currency symbol that should be used throughout the app
        /// should be fiat, if set to true, or the asset-specific symbol, if false.
        @objc var symbolLocal: Bool {
            get {
                return defaults.bool(forKey: UserDefaults.Keys.symbolLocal.rawValue)
            }
            set {
                let oldValue = symbolLocal

                defaults.set(newValue, forKey: UserDefaults.Keys.symbolLocal.rawValue)

                if oldValue != newValue {
                    onSymbolLocalChanged?(newValue)
                }
            }
        }

        @objc var fiatCurrencySymbol: String? {
            return WalletManager.shared.latestMultiAddressResponse?.symbol_local.symbol
        }

        @objc var fiatCurrencyCode: String? {
            return WalletManager.shared.latestMultiAddressResponse?.symbol_local.code
        }

        @objc func fiatSymbolFromCode(currencyCode: String) -> String? {
            guard let currencyCodeDict = WalletManager.shared.wallet.btcRates[currencyCode] as? [String: Any] else {
                return nil
            }
            return currencyCodeDict["symbol"] as? String
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

        /**
         Keeps track if the user has elected to use biometric authentication in the application.

         - Note:
         This setting should be **deprecated** in the future, as we should always assume a user
         wants to use this feature if it is enabled system-wide.

         - SeeAlso:
         [Human Interface Guidelines](https://developer.apple.com/design/human-interface-guidelines/ios/user-interaction/authentication)
         */
        @objc var biometryEnabled: Bool {
            get {
                return defaults.bool(forKey: UserDefaults.Keys.biometryEnabled.rawValue)
            }
            set {
                defaults.set(newValue, forKey: UserDefaults.Keys.biometryEnabled.rawValue)
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

        /**
         Keeps track of the last time the security reminder alert was shown to the user.

         - Note:
         The value of this setting is updated each time the `showSecurityReminder` method of the `ReminderPresenter` is called.

         The value of this setting is set to `nil` upon calling the `didCreateNewAccount` method of the wallet delegate.

         The default value of this setting is `nil`.
        */
        @objc var dateOfLastSecurityReminder: NSDate? {
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

        /**
         Determines if the application should allow access to swipe-to-receive on the pin screen.

         - Note:
         The value of this setting is controlled by a switch on the settings screen.

         The default of this setting is `true`.
         */
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

        /**
         Determines the number of labeled addresses for the default account.

         - Note:
         This value is set when the wallet has gotten its latest multi-address response.

         This setting is currently only used in the `didGet(_ response: MultiAddressResponse)` function of the wallet manager.
        */
        @objc var defaultAccountLabelledAddressesCount: Int {
            get {
                return defaults.integer(forKey: UserDefaults.Keys.defaultAccountLabelledAddressesCount.rawValue)
            }
            set {
                defaults.set(newValue, forKey: UserDefaults.Keys.defaultAccountLabelledAddressesCount.rawValue)
            }
        }

        /**
         Determines if the application should never prompt the user to write an app review.

         - Note:
         This value is set to `true` if the user has chosen to write an app review or not to be asked again.
        */
        var dontAskUserToShowAppReviewPrompt: Bool {
            get {
                return defaults.bool(forKey: UserDefaults.Keys.dontAskUserToShowAppReviewPrompt.rawValue)
            }
            set {
                defaults.set(newValue, forKey: UserDefaults.Keys.dontAskUserToShowAppReviewPrompt.rawValue)
            }
        }

        /**
         Determines if the application should show the *Continue verification* announcement card on the dashboard.

         - Note:
         This value is set to `true` whenever the user taps on the primary button on the KYC welcome screen.

         This value is set to `false` whenever the *Application complete* screen in the KYC flow will disappear.

         - Important:
         This setting **MUST** be set to `false` upon logging the user out of the application.
         */
        @objc var shouldShowKYCAnnouncementCard: Bool {
            get {
                return defaults.bool(forKey: UserDefaults.Keys.shouldShowKYCAnnouncementCard.rawValue)
            }
            set {
                defaults.set(newValue, forKey: UserDefaults.Keys.shouldShowKYCAnnouncementCard.rawValue)
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

        /**
         Resets app-specific settings back to their initial value.
         - Note:
           This function will not reset any settings which are derived from wallet options.
        */
        func reset() {
            // TICKET: IOS-1365 - Finish UserDefaults refactor (tickets, documentation, linter issues)
            // TODO: - reset all appropriate settings upon logging out
            clearPin()
            App.shared.appBecameActiveCount = 0
            App.shared.shouldShowKYCAnnouncementCard = false
            Logger.shared.info("Application settings have been reset.")
        }

        /// - Warning: Calling This function will remove **ALL** settings in the application.
        func clear() {
            UserDefaults.standard.removePersistentDomain(forName: Bundle.main.bundleIdentifier!)
            Logger.shared.info("Application settings have been cleared.")
        }

        func clearPin() {
            pin = nil
            encryptedPinPassword = nil
            pinKey = nil
            passwordPartHash = nil
            AuthenticationCoordinator.shared.lastEnteredPIN = Pin.Invalid
        }

        /// Migrates pin and password from NSUserDefaults to the Keychain
        func migratePasswordAndPinIfNeeded() {
            guard let password = defaults.string(forKey: UserDefaults.Keys.password.rawValue),
                let pinStr = defaults.string(forKey: UserDefaults.Keys.pin.rawValue),
                let pinUInt = UInt(pinStr) else {
                    return
            }

            WalletManager.shared.wallet.password = password

            Pin(code: pinUInt).saveToKeychain()

            defaults.removeObject(forKey: UserDefaults.Keys.password.rawValue)
            defaults.removeObject(forKey: UserDefaults.Keys.pin.rawValue)
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
                return defaults.bool(forKey: UserDefaults.Keys.didFailBiometrySetup.rawValue)
            }
            set {
                defaults.set(newValue, forKey: UserDefaults.Keys.didFailBiometrySetup.rawValue)
            }
        }

        /// Property indicating if the user saw the HD wallet upgrade screen
        var hasSeenUpgradeToHdScreen: Bool {
            get {
                return defaults.bool(forKey: UserDefaults.Keys.hasSeenUpgradeToHdScreen.rawValue)
            }
            set {
                defaults.set(newValue, forKey: UserDefaults.Keys.hasSeenUpgradeToHdScreen.rawValue)
            }
        }

        /**
         Determines if the biometric authentication setup should be shown to the user.

         - Note:
         This value is set to `true` if the value of `didFailBiometrySetup` is `true` and the value of `biometryEnabled` is false.

         This value is set to `false` whenever the user is reminded to very their email.

         The default value of this setting is `false`.
        */
        var shouldShowBiometrySetup: Bool {
            get {
                return defaults.bool(forKey: UserDefaults.Keys.shouldShowBiometrySetup.rawValue)
            }
            set {
                defaults.set(newValue, forKey: UserDefaults.Keys.shouldShowBiometrySetup.rawValue)
            }
        }

        /**
         Determines if this is the first time the user is running the application.

         - Note:
         This value is set to `true` if the application is running for the first time.

         This setting is currently not used for anything else.
        */
        var firstRun: Bool {
            get {
                return defaults.bool(forKey: UserDefaults.Keys.firstRun.rawValue)
            }
            set {
                defaults.set(newValue, forKey: UserDefaults.Keys.firstRun.rawValue)
            }
        }

        /// Property indicating if the buy/sell onboarding card should be shown
        @objc var shouldHideBuySellCard: Bool {
            get {
                return defaults.bool(forKey: UserDefaults.Keys.shouldHideBuySellCard.rawValue)
            }
            set {
                defaults.set(newValue, forKey: UserDefaults.Keys.shouldHideBuySellCard.rawValue)
            }
        }

        /// Property indicating if the user has seen all onboarding cards
        @objc var hasSeenAllCards: Bool {
            get {
                return defaults.bool(forKey: UserDefaults.Keys.hasSeenAllCards.rawValue)
            }
            set {
                defaults.set(newValue, forKey: UserDefaults.Keys.hasSeenAllCards.rawValue)
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
