// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit
import FeatureKYCDomain
import MoneyKit
import PermissionsKit
import PlatformKit
import RxRelay
import RxSwift
import ToolKit

public protocol KeychainItemWrapping: AnyObject {
    func pin() -> String?
    func setPin(_ pin: String?)

    func guid() -> String?
    func setGuid(_ guid: String?)

    func sharedKey() -> String?
    func setSharedKey(_ sharedKey: String?)
}

public protocol AppSettingsBaseAPI: AnyObject {
    func reset()
}

public typealias BlockchainSettingsAppAPI = AppSettingsAuthenticating
    & AppSettingsSecureChannel
    & PermissionSettingsAPI
    & AppSettingsBaseAPI

/**
 Settings for the current user.
 All settings are written and read from NSUserDefaults.
 */
final class BlockchainSettingsApp: BlockchainSettingsAppAPI {

    private let defaults: CacheSuite

    // MARK: - Properties

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
        atomicGet(on: readWriteQueue) {
            let encryptedPinPassword = defaults.string(
                forKey: UserDefaults.Keys.encryptedPinPassword.rawValue
            )
            let legacyEncryptedPinPassword = defaults.string(
                forKey: UserDefaults.Keys.legacyEncryptedPinPassword.rawValue
            )
            return encryptedPinPassword ?? legacyEncryptedPinPassword
        }
    }

    func set(encryptedPinPassword: String?) {
        atomicSet(value: encryptedPinPassword, on: readWriteQueue) { encryptedPinPasswordValue in
            defaults.set(
                encryptedPinPasswordValue,
                forKey: UserDefaults.Keys.encryptedPinPassword.rawValue
            )
            defaults.set(
                nil,
                forKey: UserDefaults.Keys.legacyEncryptedPinPassword.rawValue
            )
        }
    }

    var hasEndedFirstSession: Bool {
        get {
            defaults.bool(forKey: UserDefaults.Keys.hasEndedFirstSession.rawValue)
        }
        set {
            defaults.set(newValue, forKey: UserDefaults.Keys.hasEndedFirstSession.rawValue)
        }
    }

    var pin: String? {
        atomicGet(on: readWriteQueue) { [keychainItemWrapper] in
            keychainItemWrapper.pin()
        }
    }

    func set(pin: String?) {
        atomicSet(value: pin, on: readWriteQueue) { [keychainItemWrapper] pinValue in
            keychainItemWrapper.setPin(pinValue)
        }
    }

    var pinKey: String? {
        atomicGet(on: readWriteQueue) {
            defaults.string(forKey: UserDefaults.Keys.pinKey.rawValue)
        }
    }

    func set(pinKey: String?) {
        atomicSet(value: pinKey, on: readWriteQueue) { pinKeyValue in
            defaults.set(pinKeyValue, forKey: UserDefaults.Keys.pinKey.rawValue)
        }
    }

    /// The first 5 characters of SHA256 hash of the user's password
    var passwordPartHash: String? {
        atomicGet(on: readWriteQueue) {
            defaults.string(forKey: UserDefaults.Keys.passwordPartHash.rawValue)
        }
    }

    func set(passwordPartHash: String?) {
        atomicSet(value: passwordPartHash, on: readWriteQueue) { passwordPartHashValue in
            defaults.set(passwordPartHashValue, forKey: UserDefaults.Keys.passwordPartHash.rawValue)
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
        atomicGet(on: readWriteQueue) {
            defaults.bool(forKey: UserDefaults.Keys.biometryEnabled.rawValue)
        }
    }

    func set(biometryEnabled: Bool) {
        atomicSet(value: biometryEnabled, on: readWriteQueue) { biometryEnabledValue in
            defaults.set(
                biometryEnabledValue,
                forKey: UserDefaults.Keys.biometryEnabled.rawValue
            )
        }
    }

    var deviceKey: String? {
        get {
            defaults.string(forKey: UserDefaults.Keys.secureChannelDeviceKey.rawValue)
        }
        set {
            defaults.set(newValue, forKey: UserDefaults.Keys.secureChannelDeviceKey.rawValue)
        }
    }

    var browserIdentities: String? {
        get {
            defaults.string(forKey: UserDefaults.Keys.secureChannelBrowserIdentities.rawValue)
        }
        set {
            defaults.set(newValue, forKey: UserDefaults.Keys.secureChannelBrowserIdentities.rawValue)
        }
    }

    var custodySendInterstitialViewed: Bool {
        get {
            defaults.bool(forKey: UserDefaults.Keys.custodySendInterstitialViewed.rawValue)
        }
        set {
            defaults.set(newValue, forKey: UserDefaults.Keys.custodySendInterstitialViewed.rawValue)
        }
    }

    var sendToDomainAnnouncementViewed: Bool {
        get {
            defaults.bool(forKey: UserDefaults.Keys.sendToDomainAnnouncementViewed.rawValue)
        }
        set {
            defaults.set(newValue, forKey: UserDefaults.Keys.sendToDomainAnnouncementViewed.rawValue)
        }
    }

    private var buySellCache: EventCache {
        resolve()
    }

    private var fiatSettings: FiatCurrencySettingsServiceAPI {
        resolve()
    }

    private let enabledCurrenciesService: EnabledCurrenciesServiceAPI
    private let keychainItemWrapper: KeychainItemWrapping

    private let readWriteQueue = DispatchQueue(label: "Atomic read/write queue", attributes: .concurrent)

    init(
        enabledCurrenciesService: EnabledCurrenciesServiceAPI = resolve(),
        keychainItemWrapper: KeychainItemWrapping = resolve(),
        defaults: CacheSuite = resolve()
    ) {
        self.enabledCurrenciesService = enabledCurrenciesService
        self.defaults = defaults
        self.keychainItemWrapper = keychainItemWrapper

        defaults.register(defaults: [
            UserDefaults.Keys.cloudBackupEnabled.rawValue: true
        ])
    }

    // MARK: - Public

    /**
     Resets app-specific settings back to their initial value.
     - Note:
     This function will not reset any settings which are derived from wallet options.
     */
    func reset() {
        clearPin()
        sendToDomainAnnouncementViewed = false
        custodySendInterstitialViewed = false

        let kycSettings: KYCSettingsAPI = resolve()
        kycSettings.reset()
        resetAnnouncements()

        buySellCache.reset()

        Logger.shared.info("Application settings have been reset.")
    }

    private func resetAnnouncements() {
        let cacheSuite: CacheSuite = resolve()
        cacheSuite
            .dictionaryRepresentation()
            .keys
            .filter { key in
                key.hasPrefix("announcement-")
            }
            .forEach {
                cacheSuite.removeObject(forKey: $0)
            }
    }

    /// - Warning: Calling This function will remove **ALL** settings in the application.
    /// Resets secure keys from
    func clear() {
        let secureKeys: [UserDefaults.Keys] = [
            .passwordPartHash,
            .pinKey,
            .encryptedPinPassword,
            .legacyEncryptedPinPassword,
            .secureChannelDeviceKey,
            .secureChannelBrowserIdentities
        ]
        for key in secureKeys {
            defaults.removeObject(forKey: key.rawValue)
        }
        Logger.shared.info("Application settings have been cleared.")
    }

    func clearPin() {
        set(pin: nil)
        set(encryptedPinPassword: nil)
        set(pinKey: nil)
        set(passwordPartHash: nil)
    }
}

private func atomicGet<Value>(
    on queue: DispatchQueue,
    read: () -> Value
) -> Value {
    queue.sync {
        read()
    }
}

private func atomicSet<Value>(
    value: Value,
    on queue: DispatchQueue,
    write: (Value) -> Void
) {
    queue.sync(flags: .barrier) {
        write(value)
    }
}
