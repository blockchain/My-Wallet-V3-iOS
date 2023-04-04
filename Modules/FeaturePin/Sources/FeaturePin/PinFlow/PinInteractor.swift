// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import DIKit
import FeatureAuthenticationDomain
import Localization
import PlatformKit
import RxSwift
import ToolKit
import WalletPayloadKit

/// Interactor for the pin. This component interacts with the Blockchain API and the local
/// pin data store. When the pin is updated, the pin is also stored on the keychain.
final class PinInteractor: PinInteracting {

    // MARK: - Type

    private enum Constant {
        enum IncorrectPinAlertLockTimeTrigger {
            /// 60 seconds lock time to trigger too many attempts alert
            static let tooManyAttempts = 60000
            /// 24 hours lock time to trigger cannot log in alert
            static let cannotLogin = 86400000
        }
    }

    // MARK: - Properties

    /// In case the user attempted to logout while the pin was being sent to the server
    /// the app needs to disragard any future response
    var hasLogoutAttempted = false

    private let pinClient: PinClientAPI
    private let passwordRepository: PasswordRepositoryAPI
    private let appSettings: AppSettingsAuthenticating
    private let recorder: ErrorRecording
    private let cacheSuite: CacheSuite
    private let loginService: PinLoginServiceAPI
    private let walletCryptoService: WalletCryptoServiceAPI
    private let disposeBag = DisposeBag()

    // MARK: - Setup

    init(
        passwordRepository: PasswordRepositoryAPI = resolve(),
        pinClient: PinClientAPI = PinClient(),
        appSettings: AppSettingsAuthenticating = resolve(),
        recorder: Recording = DIKit.resolve(tag: "CrashlyticsRecorder"),
        cacheSuite: CacheSuite = resolve(),
        walletCryptoService: WalletCryptoServiceAPI = resolve()
    ) {
        self.loginService = PinLoginService(
            settings: appSettings,
            service: DIKit.resolve()
        )
        self.passwordRepository = passwordRepository
        self.pinClient = pinClient
        self.appSettings = appSettings
        self.recorder = recorder
        self.cacheSuite = cacheSuite
        self.walletCryptoService = walletCryptoService
    }

    // MARK: - API

    /// Creates a pin code in the remote pin store
    /// - Parameter payload: the pin payload
    /// - Returns: Completable indicating completion
    func create(using payload: PinPayload) -> Completable {
        pinClient.create(pinPayload: payload)
            .asSingle()
            .flatMapCompletable(weak: self) { (self, response) in
                self.handleCreatePinResponse(response: response, payload: payload)
            }
            .catch { error in
                throw PinError.map(from: error)
            }
            .observe(on: MainScheduler.instance)
    }

    /// Validates if the provided pin payload (i.e. pin code and pin key combination) is correct.
    /// Calling this method will also fetch the WalletOptions to see if the server is under maintenance,
    /// then, handle updating the local pin store (i.e. the keychain),
    /// depending on the response for the remote pin store.
    /// - Parameter payload: the pin payload
    /// - Returns: Single warpping the pin decryption key
    func validate(using payload: PinPayload) -> Single<String> {
        pinClient.validate(pinPayload: payload)
            .asSingle()
            .do(
                onSuccess: { [weak self] response in
                    guard let self else { return }
                    try updateCacheIfNeeded(response: response, pinPayload: payload)
                }
            )
            .map { [weak self] response -> String in
                guard let self else { throw PinError.unretainedSelf }
                return try pinValidationStatus(from: response)
            }
            .catch { [weak self] error in
                if let response = error as? PinStoreResponse {
                    // TODO: Check for invalid numerical value error by string comparison for now, should revisit when backend make necessary changes
                    if let error = response.error,
                       error.contains("Invalid Numerical Value")
                    {
                        throw PinError.invalid
                    }
                    let pinError = response.toPinError()
                    switch pinError {
                    case .incorrectPin(let message, let remaining, _):
                        let pinAlert = self?.getPinAlertIfNeeded(remaining)
                        throw PinError.incorrectPin(message, remaining, pinAlert)
                    case .backoff(let message, let remaining, _):
                        let pinAlert = self?.getPinAlertIfNeeded(remaining)
                        throw PinError.backoff(message, remaining, pinAlert)
                    default:
                        throw pinError
                    }
                } else {
                    throw PinError.map(from: error)
                }
            }
            .observe(on: MainScheduler.instance)
    }

    func password(from pinDecryptionKey: String) -> Single<String> {
        loginService.password(from: pinDecryptionKey)
            .observe(on: MainScheduler.instance)
    }

    /// Keep the PIN value on the local pin store (i.e the keychain), for biometrics auth.
    /// - Parameter pin: the pin value
    func persist(pin: Pin) {
        pin.save(using: appSettings)
        appSettings.set(biometryEnabled: true)
    }

    // MARK: - Accessors

    private func getPinAlertIfNeeded(_ remaining: Int) -> PinError.PinAlert? {
        switch remaining {
        case Constant.IncorrectPinAlertLockTimeTrigger.tooManyAttempts:
            return .tooManyAttempts
        case let time where time >= Constant.IncorrectPinAlertLockTimeTrigger.cannotLogin:
            return .cannotLogin
        default:
            return nil
        }
    }

    private func handleCreatePinResponse(response: PinStoreResponse, payload: PinPayload) -> Completable {
        passwordRepository.password
            .setFailureType(to: PinError.self)
            .flatMap { [weak self] password -> AnyPublisher<(pin: String, password: String), PinError> in
                // Wallet must have password at the stage
                guard let password else {
                    let error = PinError.serverError(LocalizationConstants.Pin.cannotSaveInvalidWalletState)
                    self?.recorder.error(error)
                    return .failure(error)
                }

                guard response.error == nil else {
                    self?.recorder.error(PinError.serverError(""))
                    return .failure(PinError.serverError(response.error!))
                }

                guard response.isSuccessful else {
                    let message = String(
                        format: LocalizationConstants.Errors.invalidStatusCodeReturned,
                        response.statusCode?.rawValue ?? -1
                    )
                    let error = PinError.serverError(message)
                    self?.recorder.error(error)
                    return .failure(error)
                }

                guard let pinValue = payload.pinValue,
                      !payload.pinKey.isEmpty,
                      !pinValue.isEmpty
                else {
                    let error = PinError.serverError(LocalizationConstants.Pin.responseKeyOrValueLengthZero)
                    self?.recorder.error(error)
                    return .failure(error)
                }
                return .just((pin: pinValue, password: password))
            }
            .flatMap { [walletCryptoService] data -> AnyPublisher<(encryptedPinPassword: String, password: String), PinError> in
                walletCryptoService
                    .encrypt(
                        pair: KeyDataPair(key: data.pin, data: data.password),
                        pbkdf2Iterations: WalletCryptoPBKDF2Iterations.pinLogin
                    )
                    .map { (encryptedPinPassword: $0, password: data.password) }
                    .mapError(PinError.encryptedPinPasswordFailed)
                    .eraseToAnyPublisher()
            }
            .asSingle()
            .flatMapCompletable(weak: self) { (self, data) -> Completable in
                // Update the cache
                self.appSettings.set(encryptedPinPassword: data.encryptedPinPassword)
                self.appSettings.set(pinKey: payload.pinKey)
                self.appSettings.set(passwordPartHash: hashPassword(data.password))
                try self.updateCacheIfNeeded(response: response, pinPayload: payload)
                return Completable.empty()
            }
    }

    /// Persists the pin if needed or deletes it according to the response code received from the backend
    private func updateCacheIfNeeded(
        response: PinStoreResponse,
        pinPayload: PinPayload
    ) throws {
        // Make sure the user has not logout
        guard !hasLogoutAttempted else {
            throw PinError.receivedResponseWhileLoggedOut
        }

        guard let responseCode = response.statusCode else { return }
        switch responseCode {
        case .success where pinPayload.persistsLocally:
            // Optionally save the pin to the keychain to enable biometric authenticators
            persist(pin: pinPayload.pin!)
        case .deleted:
            // Clear pin from keychain if the user exceeded the number of retries when entering the pin.
            appSettings.set(pin: nil)
            appSettings.set(biometryEnabled: false)
        default:
            break
        }
    }

    // Returns the pin decryption key, or throws error if cannot
    private func pinValidationStatus(from response: PinStoreResponse) throws -> String {

        // TODO: Check for invalid numerical value error by string comparison for now, should revisit when backend make necessary changes
        if let error = response.error, error.contains("Invalid Numerical Value") {
            throw PinError.invalid
        }

        // Verify that the status code was received
        guard let statusCode = response.statusCode else {
            let error = PinError.serverError(LocalizationConstants.Errors.genericError)
            recorder.error(error)
            throw error
        }

        switch statusCode {
        case .success:
            guard let pinDecryptionKey = response.pinDecryptionValue, !pinDecryptionKey.isEmpty else {
                throw PinError.custom(LocalizationConstants.Errors.genericError)
            }
            return pinDecryptionKey
        case .deleted:
            throw PinError.tooManyAttempts
        case .incorrect:
            guard let remaining = response.remaining else {
                fatalError("Incorrect PIN should have an remaining field")
            }
            let message = LocalizationConstants.Pin.incorrect
            throw PinError.incorrectPin(message, remaining, nil)
        case .backoff:
            guard let remaining = response.remaining else {
                fatalError("Backoff should have an remaining field")
            }
            let message = LocalizationConstants.Pin.backoff
            throw PinError.backoff(message, remaining, nil)
        case .duplicateKey, .unknown:
            throw PinError.custom(LocalizationConstants.Errors.genericError)
        }
    }
}
