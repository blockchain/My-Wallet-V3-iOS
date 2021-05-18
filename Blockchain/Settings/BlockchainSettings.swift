//
//  BlockchainSettings.swift
//  Blockchain
//
//  Created by Chris Arriola on 4/17/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import BuySellKit
import DIKit
import KYCKit
import PlatformKit
import PlatformUIKit
import RxRelay
import RxSwift
import ToolKit

/**
 Settings for the current user.
 All settings are written and read from NSUserDefaults.
 */
@objc
final class BlockchainSettings: NSObject {

    // MARK: - App

    @objc(BlockchainSettingsApp)
    class App: NSObject, AppSettingsAPI, AppSettingsAuthenticating, SwipeToReceiveConfiguring, CloudBackupConfiguring, PermissionSettingsAPI {

        @Inject @objc static var shared: App

        @LazyInject private var defaults: CacheSuite

        var isPairedWithWallet: Bool {
            guid != nil
                && sharedKey != nil
                && pinKey != nil
                && encryptedPinPassword != nil
        }

        // MARK: - Properties

        /**
         Determines if the application should *ask the system* to show the app review prompt.

         - Note:
         This value increments whenever the application is launched or enters the foreground.

         - Important:
         This setting **should** be set reset upon logging the user out of the application.
         */
        var appBecameActiveCount: Int {
            get {
                defaults.integer(forKey: UserDefaults.Keys.appBecameActiveCount.rawValue)
            }
            set {
                defaults.set(newValue, forKey: UserDefaults.Keys.appBecameActiveCount.rawValue)
            }
        }

        var didRequestCameraPermissions: Bool {
            get {
                defaults.bool(forKey: UserDefaults.Keys.didRequestCameraPermissions.rawValue)
            }
            set {
                defaults.set(newValue, forKey: UserDefaults.Keys.didRequestCameraPermissions.rawValue)
            }
        }

        var didRequestMicrophonePermissions: Bool {
            get {
                defaults.bool(forKey: UserDefaults.Keys.didRequestMicrophonePermissions.rawValue)
            }
            set {
                defaults.set(newValue, forKey: UserDefaults.Keys.didRequestMicrophonePermissions.rawValue)
            }
        }

        var didRequestNotificationPermissions: Bool {
            get {
                defaults.bool(forKey: UserDefaults.Keys.didRequestNotificationPermissions.rawValue)
            }
            set {
                defaults.set(newValue, forKey: UserDefaults.Keys.didRequestNotificationPermissions.rawValue)
            }
        }

        /**
         Stores the encrypted wallet password.

         - Note:
         The value of this setting is the result of calling the `encrypt(_ data: String, password: String)` function of the wallet.

         - Important:
         The encryption key is generated from the pin created by the user.
         legacyEncryptedPinPassword is required for wallets that created a PIN prior to Homebrew release - see IOS-1537
         */
        var encryptedPinPassword: String? {
            get {
                defaults.string(forKey: UserDefaults.Keys.encryptedPinPassword.rawValue) ??
                    defaults.string(forKey: UserDefaults.Keys.legacyEncryptedPinPassword.rawValue)
            }
            set {
                defaults.set(newValue, forKey: UserDefaults.Keys.encryptedPinPassword.rawValue)
                defaults.set(nil, forKey: UserDefaults.Keys.legacyEncryptedPinPassword.rawValue)
            }
        }

        @objc var hasEndedFirstSession: Bool {
            get {
                defaults.bool(forKey: UserDefaults.Keys.hasEndedFirstSession.rawValue)
            }
            set {
                defaults.set(newValue, forKey: UserDefaults.Keys.hasEndedFirstSession.rawValue)
            }
        }

        var pin: String? {
            get {
                KeychainItemWrapper.pinFromKeychain()
            }
            set {
                guard let pin = newValue else {
                    KeychainItemWrapper.removePinFromKeychain()
                    return
                }
                KeychainItemWrapper.setPINInKeychain(pin)
            }
        }

        var isPinSet: Bool {
            pinKey != nil && encryptedPinPassword != nil
        }

        var pinKey: String? {
            get {
                defaults.string(forKey: UserDefaults.Keys.pinKey.rawValue)
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
                defaults.bool(forKey: UserDefaults.Keys.symbolLocal.rawValue)
            }
            set {
                let oldValue = symbolLocal

                defaults.set(newValue, forKey: UserDefaults.Keys.symbolLocal.rawValue)

                if oldValue != newValue {
                    onSymbolLocalChanged?(newValue)
                }
            }
        }
        
        @available(*, deprecated, message: "Do not use this. Instead use `FiatCurrencySettingsServiceAPI`")
        @objc var fiatCurrencySymbol: String {
            fiatCurrency.symbol
        }
        
        @available(*, deprecated, message: "Do not use this. Instead use `FiatCurrencySettingsServiceAPI`")
        var fiatCurrency: FiatCurrency {
            FiatCurrency(code: fiatSettings.legacyCurrency?.code ?? "USD")!
        }

        /// The first 5 characters of SHA256 hash of the user's password
        var passwordPartHash: String? {
            get {
                defaults.string(forKey: UserDefaults.Keys.passwordPartHash.rawValue)
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
        var biometryEnabled: Bool {
            get {
                defaults.bool(forKey: UserDefaults.Keys.biometryEnabled.rawValue)
            }
            set {
                defaults.set(newValue, forKey: UserDefaults.Keys.biometryEnabled.rawValue)
            }
        }

        @objc var guid: String? {
            get {
                KeychainItemWrapper.guid()
            }
            set {
                guard let guid = newValue else {
                    KeychainItemWrapper.removeGuidFromKeychain()
                    return
                }
                KeychainItemWrapper.setGuidInKeychain(guid)
            }
        }

        @objc var sharedKey: String? {
            get {
                KeychainItemWrapper.sharedKey()
            }
            set {
                guard let sharedKey = newValue else {
                    KeychainItemWrapper.removeSharedKeyFromKeychain()
                    return
                }
                KeychainItemWrapper.setSharedKeyInKeychain(sharedKey)
            }
        }

        @objc var selectedLegacyAssetType: LegacyAssetType {
            get {
                let rawValue = defaults.integer(forKey: UserDefaults.Keys.selectedLegacyAssetType.rawValue)
                guard let value = LegacyAssetType(rawValue: rawValue),
                    enabledCurrenciesService.allEnabledCryptoCurrencies.contains(CryptoCurrency(legacyAssetType: value)) else {
                        return .bitcoin
                }
                return value
            }
            set {
                defaults.set(newValue.rawValue, forKey: UserDefaults.Keys.selectedLegacyAssetType.rawValue)
            }
        }

        /**
         Determines if the application should back up credentials to iCloud.

         - Note:
         The value of this setting is controlled by a switch on the settings screen.

         The default of this setting is `true`.
         */
        var cloudBackupEnabled: Bool {
            get {
                defaults.bool(forKey: UserDefaults.Keys.cloudBackupEnabled.rawValue)
            }
            set {
                defaults.set(newValue, forKey: UserDefaults.Keys.cloudBackupEnabled.rawValue)
            }
        }

        /**
         Determines if the application should allow access to swipe-to-receive on the pin screen.

         - Note:
         The value of this setting is controlled by a switch on the settings screen.

         The default of this setting is `true`.
         */
        var swipeToReceiveEnabled: Bool {
            get {
                defaults.bool(forKey: UserDefaults.Keys.swipeToReceiveEnabled.rawValue)
            }
            set {
                defaults.set(newValue, forKey: UserDefaults.Keys.swipeToReceiveEnabled.rawValue)
            }
        }

        private func getSwipeAddress(for currency: CryptoCurrency) -> String? {
            KeychainItemWrapper.getSingleSwipeAddress(for: currency.legacy)
        }

        private func setSwipeAddress(_ address: String?, for currency: CryptoCurrency) {
            guard let address = address else {
                KeychainItemWrapper.removeAllSwipeAddresses(for: currency.legacy)
                return
            }
            KeychainItemWrapper.setSingleSwipeAddress(address, for: currency.legacy)
        }

        /// ETH address to be used for swipe to receive
        var swipeAddressForEther: String? {
            get { getSwipeAddress(for: .ethereum) }
            set { setSwipeAddress(newValue, for: .ethereum) }
        }

        /// XLM address to be used for swipe to receive
        var swipeAddressForStellar: String? {
            get { getSwipeAddress(for: .stellar) }
            set { setSwipeAddress(newValue, for: .stellar) }
        }

        /// PAX address to be used for swipe to receive
        var swipeAddressForPax: String? {
            get { getSwipeAddress(for: .pax) }
            set { setSwipeAddress(newValue, for: .pax) }
        }

        /// USDT address to be used for swipe to receive
        var swipeAddressForTether: String? {
            get { getSwipeAddress(for: .tether) }
            set { setSwipeAddress(newValue, for: .tether) }
        }

        var swipeAddressForWDGLD: String? {
            get { getSwipeAddress(for: .wDGLD) }
            set { setSwipeAddress(newValue, for: .wDGLD) }
        }

        var swipeAddressForYearnFinance: String? {
            get { getSwipeAddress(for: .yearnFinance) }
            set { setSwipeAddress(newValue, for: .yearnFinance) }
        }

        var swipeAddressForAave: String? {
            get { getSwipeAddress(for: .aave) }
            set { setSwipeAddress(newValue, for: .aave) }
        }

        /**
         Determines the number of labeled addresses for the default account.
         - Note:
         This value is set when the wallet has gotten its latest multi-address response.
         This setting is currently only used in the `didGet(_ response: MultiAddressResponse)` function of the wallet manager.
         */
        @objc var defaultAccountLabelledAddressesCount: Int {
            get {
                defaults.integer(forKey: UserDefaults.Keys.defaultAccountLabelledAddressesCount.rawValue)
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
                defaults.bool(forKey: UserDefaults.Keys.dontAskUserToShowAppReviewPrompt.rawValue)
            }
            set {
                defaults.set(newValue, forKey: UserDefaults.Keys.dontAskUserToShowAppReviewPrompt.rawValue)
            }
        }

        /**
         Determines if the user deep linked into the app using the airdrop dynamic link. This value is used in various
         places to handle the airdrop flow (e.g. prompt the user to KYC to finish the airdrop, to continue KYC'ing if
         they have already gone through the KYC flow, etc.)

         - Important:
         This setting **MUST** be set to `false` upon logging the user out of the application.
         */
        @objc var didTapOnAirdropDeepLink: Bool {
            get {
                defaults.bool(forKey: UserDefaults.Keys.didTapOnAirdropDeepLink.rawValue)
            }
            set {
                defaults.set(newValue, forKey: UserDefaults.Keys.didTapOnAirdropDeepLink.rawValue)
            }
        }

        /// Determines if the app already tried to route the user for the airdrop flow as a result
        /// of tapping on a deep link
        var didAttemptToRouteForAirdrop: Bool {
            get {
                defaults.bool(forKey: UserDefaults.Keys.didAttemptToRouteForAirdrop.rawValue)
            }
            set {
                defaults.set(newValue, forKey: UserDefaults.Keys.didAttemptToRouteForAirdrop.rawValue)
            }
        }

        /// Users that are linking their Exchange account to their blockchain wallet will deep-link
        /// from the Exchange into the mobile app.
        var exchangeLinkIdentifier: String? {
            get {
                defaults.string(forKey: UserDefaults.Keys.exchangeLinkIdentifier.rawValue)
            }
            set {
                defaults.set(newValue, forKey: UserDefaults.Keys.exchangeLinkIdentifier.rawValue)
            }
        }

        var didTapOnExchangeDeepLink: Bool {
            get {
                defaults.bool(forKey: UserDefaults.Keys.didTapOnExchangeDeepLink.rawValue)
            }
            set {
                defaults.set(newValue, forKey: UserDefaults.Keys.didTapOnExchangeDeepLink.rawValue)
            }
        }

        @objc var custodySendInterstitialViewed: Bool {
            get {
                defaults.bool(forKey: UserDefaults.Keys.custodySendInterstitialViewed.rawValue)
            }
            set {
                defaults.set(newValue, forKey: UserDefaults.Keys.custodySendInterstitialViewed.rawValue)
            }
        }
        
        private var buySellCache: EventCache {
            resolve()
        }
        
        private var fiatSettings: FiatCurrencySettingsServiceAPI {
            resolve()
        }

        private let enabledCurrenciesService: EnabledCurrenciesServiceAPI

        init(enabledCurrenciesService: EnabledCurrenciesServiceAPI = resolve()) {
            self.enabledCurrenciesService = enabledCurrenciesService

            super.init()

            defaults.register(defaults: [
                UserDefaults.Keys.swipeToReceiveEnabled.rawValue: true,
                UserDefaults.Keys.cloudBackupEnabled.rawValue: true,
                UserDefaults.Keys.selectedLegacyAssetType.rawValue: LegacyAssetType.bitcoin.rawValue
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
            appBecameActiveCount = 0
            custodySendInterstitialViewed = false
            didTapOnAirdropDeepLink = false
            didTapOnExchangeDeepLink = false
            didAttemptToRouteForAirdrop = false
            exchangeLinkIdentifier = nil

            let kycSettings: KYCSettingsAPI = resolve()
            kycSettings.reset()
            AnnouncementRecorder.reset()
            
            buySellCache.reset()

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
        }

        /// Migrates pin and password from NSUserDefaults to the Keychain
        func migratePasswordAndPinIfNeeded() {
            guard let password = defaults.string(forKey: UserDefaults.Keys.password.rawValue),
                let pinStr = defaults.string(forKey: UserDefaults.Keys.pin.rawValue),
                let pinUInt = UInt(pinStr) else {
                    return
            }

            WalletManager.shared.legacyRepository.legacyPassword = password

            Pin(code: pinUInt).save(using: self)

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
    final class Onboarding {
        static let shared: Onboarding = Onboarding()

        private lazy var defaults: UserDefaults = {
            .standard
        }()

        var walletIntroLatestLocation: WalletIntroductionLocation? {
            get {
                guard let value = defaults.object(forKey: UserDefaults.Keys.walletIntroLatestLocation.rawValue) as? Data else { return nil }
                do {
                    let result = try JSONDecoder().decode(WalletIntroductionLocation.self, from: value)
                    return result
                } catch {
                    return nil
                }
            }
            set {
                defaults.set(newValue, forKey: UserDefaults.Keys.walletIntroLatestLocation.rawValue)
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
                defaults.bool(forKey: UserDefaults.Keys.firstRun.rawValue)
            }
            set {
                defaults.set(newValue, forKey: UserDefaults.Keys.firstRun.rawValue)
            }
        }

        private init() { }

        func reset() {
            walletIntroLatestLocation = nil
        }
    }
}
