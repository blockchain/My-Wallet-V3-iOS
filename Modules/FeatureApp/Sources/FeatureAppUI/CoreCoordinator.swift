// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import AnalyticsKit
import BlockchainNamespace
import CasePaths
import Combine
import ComposableArchitecture
import DelegatedSelfCustodyDomain
import DIKit
import ERC20Kit
import FeatureAppDomain
import FeatureAppUpgradeDomain
import FeatureAppUpgradeUI
import FeatureAuthenticationDomain
import FeatureAuthenticationUI
import FeatureSettingsDomain
import Localization
import ObservabilityKit
import PlatformKit
import PlatformUIKit
import RemoteNotificationsKit
import ToolKit
import UIKit
import UnifiedActivityDomain
import WalletPayloadKit

public struct CoreAppState: Equatable {
    public var onboarding: Onboarding.State? = .init()
    public var loggedIn: LoggedIn.State?
    public var deviceAuthorization: AuthorizeDeviceState?

    public var alertState: AlertState<CoreAppAction>?

    var isLoggedIn: Bool {
        onboarding == nil && loggedIn != nil
    }

    public init(
        onboarding: Onboarding.State? = .init(),
        loggedIn: LoggedIn.State? = nil,
        deviceAuthorization: AuthorizeDeviceState? = nil
    ) {
        self.onboarding = onboarding
        self.loggedIn = loggedIn
        self.deviceAuthorization = deviceAuthorization
    }
}

public enum ProceedToLoggedInError: Error, Equatable {
    case coincore(CoincoreError)
}

public indirect enum CoreAlertAction: Equatable {
    public struct Buttons: Equatable {
        let primary: ButtonState<CoreAppAction>
        let secondary: ButtonState<CoreAppAction>?
    }

    case show(title: String, message: String, buttons: Buttons?)
    case dismiss
    case openAppStore
}

public enum CoreAppAction: Equatable {
    case start
    case loggedIn(LoggedIn.Action)
    case onboarding(Onboarding.Action)
    case prepareForLoggedIn
    case proceedToLoggedIn(Result<Bool, ProceedToLoggedInError>)
    case appForegrounded
    case deeplink(DeeplinkOutcome)
    case requirePin
    case setupPin
    case alert(CoreAlertAction)
    case cancel(AnyHashable)

    // Wallet Authentication
    case wallet(WalletAction)
    case fetchWallet(password: String)
    case initializeWallet
    case walletInitialized

    // Device Authorization
    case authorizeDevice(AuthorizeDeviceAction)
    case loginRequestReceived(deeplink: URL)
    case checkIfConfirmationRequired(sessionId: String, base64Str: String)
    case proceedToDeviceAuthorization(LoginRequestInfo)
    case deviceAuthorizationFinished

    // Account Recovery
    case resetPassword(newPassword: String)

    // Nabu Account Operations
    case resetVerificationStatusIfNeeded(guid: String?, sharedKey: String?)

    // Mobile Auth Sync
    case mobileAuthSync(isLogin: Bool)

    case none
}

struct CoreAppEnvironment {
    var accountRecoveryService: AccountRecoveryServiceAPI
    var alertPresenter: AlertViewPresenterAPI
    var analyticsRecorder: AnalyticsEventRecorderAPI
    var app: AppProtocol
    var appStoreOpener: AppStoreOpening
    var appUpgradeState: () -> AnyPublisher<AppUpgradeState?, Never>
    var blockchainSettings: BlockchainSettingsAppAPI
    var buildVersionProvider: () -> String
    var coincore: CoincoreAPI
    var credentialsStore: CredentialsStoreAPI
    var deeplinkHandler: DeepLinkHandling
    var deeplinkRouter: DeepLinkRouting
    var delegatedCustodySubscriptionsService: DelegatedCustodySubscriptionsServiceAPI
    var deviceVerificationService: DeviceVerificationServiceAPI
    var erc20CryptoAssetService: ERC20CryptoAssetServiceAPI
    var exchangeRepository: ExchangeAccountRepositoryAPI
    var externalAppOpener: ExternalAppOpener
    var fiatCurrencySettingsService: FiatCurrencySettingsServiceAPI
    var forgetWalletService: ForgetWalletService
    var legacyGuidRepository: LegacyGuidRepositoryAPI
    var legacySharedKeyRepository: LegacySharedKeyRepositoryAPI
    var loadingViewPresenter: LoadingViewPresenting
    var mainQueue: AnySchedulerOf<DispatchQueue>
    var mobileAuthSyncService: MobileAuthSyncServiceAPI
    var nabuUserService: NabuUserServiceAPI
    var performanceTracing: PerformanceTracingServiceAPI
    var pushNotificationsRepository: PushNotificationsRepositoryAPI
    var reactiveWallet: ReactiveWalletAPI
    var recaptchaService: GoogleRecaptchaServiceAPI
    var remoteNotificationServiceContainer: RemoteNotificationServiceContaining
    var resetPasswordService: ResetPasswordServiceAPI
    var sharedContainer: SharedContainerUserDefaults
    var siftService: FeatureAuthenticationDomain.SiftServiceAPI
    var unifiedActivityService: UnifiedActivityPersistenceServiceAPI
    var walletPayloadService: WalletPayloadServiceAPI
    var walletService: WalletService
    var walletStateProvider: WalletStateProvider
}

struct MainAppReducer: Reducer {

    typealias State = CoreAppState
    typealias Action = CoreAppAction

    let environment: CoreAppEnvironment

    var body: some Reducer<State, Action> {
        MainAppReducerCore(environment: environment)
        .ifLet(\CoreAppState.onboarding, action: CasePath(CoreAppAction.onboarding)) {
            OnboardingReducer(
                app: environment.app,
                appSettings: environment.blockchainSettings,
                credentialsStore: environment.credentialsStore,
                alertPresenter: environment.alertPresenter,
                mainQueue: environment.mainQueue,
                deviceVerificationService: environment.deviceVerificationService,
                legacyGuidRepository: environment.legacyGuidRepository,
                legacySharedKeyRepository: environment.legacySharedKeyRepository,
                mobileAuthSyncService: environment.mobileAuthSyncService,
                pushNotificationsRepository: environment.pushNotificationsRepository,
                walletPayloadService: environment.walletPayloadService,
                externalAppOpener: environment.externalAppOpener,
                forgetWalletService: environment.forgetWalletService,
                recaptchaService: environment.recaptchaService,
                buildVersionProvider: environment.buildVersionProvider,
                appUpgradeState: environment.appUpgradeState
            )
        }
        .ifLet(\CoreAppState.loggedIn, action: CasePath(CoreAppAction.loggedIn)) {
            LoggedInReducer(
                analyticsRecorder: environment.analyticsRecorder,
                app: environment.app,
                appSettings: environment.blockchainSettings,
                deeplinkRouter: environment.deeplinkRouter,
                exchangeRepository: environment.exchangeRepository,
                fiatCurrencySettingsService: environment.fiatCurrencySettingsService,
                loadingViewPresenter: environment.loadingViewPresenter,
                mainQueue: environment.mainQueue,
                nabuUserService: environment.nabuUserService,
                performanceTracing: environment.performanceTracing,
                reactiveWallet: environment.reactiveWallet,
                remoteNotificationAuthorizer: environment.remoteNotificationServiceContainer.authorizer,
                remoteNotificationTokenSender: environment.remoteNotificationServiceContainer.tokenSender,
                unifiedActivityService: environment.unifiedActivityService
            )
        }
        .ifLet(\CoreAppState.deviceAuthorization, action: CasePath(CoreAppAction.authorizeDevice)) {
            AuthorizeDeviceReducer(
                mainQueue: environment.mainQueue,
                deviceVerificationService: environment.deviceVerificationService
            )
        }
    }
}

struct MainAppReducerCore: Reducer {

    typealias State = CoreAppState
    typealias Action = CoreAppAction

    let environment: CoreAppEnvironment

    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .start:
                syncPinKeyWithICloud(
                    blockchainSettings: environment.blockchainSettings,
                    legacyGuid: environment.legacyGuidRepository,
                    legacySharedKey: environment.legacySharedKeyRepository,
                    credentialsStore: environment.credentialsStore
                )
                return .none

            case .appForegrounded:
                let isLoggedIn = state.isLoggedIn
                return .run { send in
                    let isWalletInitialized = try await environment.walletStateProvider
                        .isWalletInitializedPublisher()
                        .await()
                    guard isWalletInitialized else {
                        guard isLoggedIn else {
                            await send(.cancel(WalletCancelations.ForegroundInitCheckId))
                            return
                        }
                        await send(.loggedIn(.stop))
                        await send(.requirePin)
                        return
                    }
                    await send(.cancel(WalletCancelations.ForegroundInitCheckId))
                }
                .cancellable(id: WalletCancelations.ForegroundInitCheckId, cancelInFlight: true)

            case .cancel(let id):
                return .cancel(id: id)

            case .deeplink(.handleLink(let content)) where content.context == .dynamicLinks:
                // for context this performs side-effect to values in the appSettings
                // it'll then be up to the `DeeplinkRouter` to capture any of these changes
                // and route if needed, the router is handled once we're in a logged-in state
                environment.deeplinkHandler.handle(deepLink: content.url.absoluteString)
                return .none

            case .deeplink(.handleLink(let content)) where content.context.usableOnlyDuringAuthentication:
                // currently we only support only one deeplink for login, so being naive here
                guard content.context == .blockchainLinks(.login) else {
                    return .none
                }
                // handle deeplink if we've entered verify device flow
                if let onboarding = state.onboarding,
                   let authState = onboarding.welcomeState,
                   let loginState = authState.emailLoginState,
                   loginState.verifyDeviceState != nil
                {
                    // Pass content to welcomeScreen to be handled
                    return Effect.send(.onboarding(.welcomeScreen(.deeplinkReceived(content.url))))
                } else {
                    return Effect.send(.loginRequestReceived(deeplink: content.url))
                }

            case .deeplink(.handleLink(let content)):
                // we first check if we're logged in, if not we need to defer the deeplink routing
                guard state.isLoggedIn else {
                    // continue if we're on the onboarding state
                    guard let onboarding = state.onboarding else {
                        return .none
                    }
                    // check if we're on the pinState and we need the user to enter their pin
                    if let pinState = onboarding.pinState,
                       pinState.requiresPinAuthentication,
                       !content.context.usableOnlyDuringAuthentication
                    {
                        // defer the deeplink until we handle the `.proceedToLoggedIn` action
                        state.onboarding?.deeplinkContent = content
                    }
                    return .none
                }
                // continue with the deeplink
                return Effect.send(.loggedIn(.deeplink(content)))

            case .deeplink(.informAppNeedsUpdate):
                let buttons: CoreAlertAction.Buttons = .init(
                    primary: .default(
                        TextState(verbatim: LocalizationConstants.DeepLink.updateNow),
                        action: .send(.alert(.openAppStore))
                    ),
                    secondary: .cancel(
                        TextState(verbatim: LocalizationConstants.cancel),
                        action: .send(.alert(.dismiss))
                    )
                )
                let alertAction = CoreAlertAction.show(
                    title: LocalizationConstants.DeepLink.deepLinkUpdateTitle,
                    message: LocalizationConstants.DeepLink.deepLinkUpdateMessage,
                    buttons: buttons
                )
                return Effect.send(.alert(alertAction))

            case .deeplink(.ignore):
                return .none

            case .requirePin:
                state.loggedIn = nil
                state.onboarding = Onboarding.State(pinState: .init())
                return .merge(
                    .cancel(id: WalletCancelations.ForegroundInitCheckId),
                    Effect.send(.onboarding(.start))
                )

            case .fetchWallet(let password):
                environment.loadingViewPresenter.showCircular()
                return Effect.send(.wallet(.fetch(password: password)))

            case .setupPin:
                environment.loadingViewPresenter.hide()
                state.onboarding?.pinState = .init()
                state.onboarding?.passwordRequiredState = nil
                return Effect.send(CoreAppAction.onboarding(.pin(.create)))

            case .initializeWallet:
                return .run { send in
                    try await environment.reactiveWallet
                        .waitUntilInitializedFirst
                        .await()
                    await send(CoreAppAction.walletInitialized)
                }
                .cancellable(id: WalletCancelations.InitializationId, cancelInFlight: false)

            case .walletInitialized:
                return Effect.send(.prepareForLoggedIn)

            case .loginRequestReceived(let deeplink):
                return .run { send in
                    do {
                        try await environment
                            .deviceVerificationService
                            .handleLoginRequestDeeplink(url: deeplink)
                            .await()
                    } catch {
                        guard let error = error as? WalletInfoError else {
                            return
                        }
                        switch error {
                            // when catched a deeplink with a different session token,
                            // or when there is no session token from the app,
                            // it means a login magic link generated from a different device is catched
                            // proceed to login request authorization in this case
                        case .missingSessionToken(let sessionId, let base64Str),
                                .sessionTokenMismatch(let sessionId, let base64Str):
                            await send(.checkIfConfirmationRequired(sessionId: sessionId, base64Str: base64Str))
                        case .failToDecodeBase64Component,
                                .failToDecodeToWalletInfo:
                            await send(.none)
                        }
                    }
                }

            case .onboarding(.welcomeScreen(.emailLogin(.verifyDevice(.checkIfConfirmationRequired(let sessionId, let base64Str))))),
                 .checkIfConfirmationRequired(let sessionId, let base64Str):
                return .run { send in
                    do {
                        try await environment
                            .deviceVerificationService
                            // trigger confirmation required error
                            .authorizeVerifyDevice(from: sessionId, payload: base64Str, confirmDevice: nil)
                            .await()
                    } catch {
                        guard let error = error as? AuthorizeVerifyDeviceError else {
                            return
                        }
                        switch error {
                        case .confirmationRequired(let timestamp, let details):
                            let info = LoginRequestInfo(
                                sessionId: sessionId,
                                base64Str: base64Str,
                                details: details,
                                timestamp: timestamp
                            )
                            await send(.proceedToDeviceAuthorization(info))
                        default:
                            await send(.none)
                        }
                    }
                }

            case .proceedToDeviceAuthorization(let loginRequestInfo):
                state.deviceAuthorization = .init(
                    loginRequestInfo: loginRequestInfo
                )
                return .none

            case .deviceAuthorizationFinished:
                state.deviceAuthorization = nil
                return .none

            case .prepareForLoggedIn:
                environment.erc20CryptoAssetService.setupCoincore()
                return .run { send in
                    try await environment.coincore
                        .initialize()
                        .await()
                    await send(CoreAppAction.proceedToLoggedIn(.success(true)))
                }
                .cancellable(id: WalletCancelations.AssetInitializationId, cancelInFlight: false)

            case .proceedToLoggedIn(.failure(let error)):
                environment.loadingViewPresenter.hide()
                state.onboarding?.displayAlert = .proceedToLoggedIn(error)
                return .merge(
                    .cancel(id: WalletCancelations.AssetInitializationId),
                    .cancel(id: WalletCancelations.InitializationId),
                    .cancel(id: WalletCancelations.UpgradeId)
                )

            case .proceedToLoggedIn(.success):
                environment.loadingViewPresenter.hide()
                // prepare the context for logged in state, if required
                var context: LoggedIn.Context = .none
                if let deeplinkContent = state.onboarding?.deeplinkContent {
                    context = .deeplink(deeplinkContent)
                }
                if let walletContext = state.onboarding?.walletCreationContext {
                    context = .wallet(walletContext)
                }
                state.loggedIn = LoggedIn.State()
                state.onboarding = nil
                return .merge(
                    .cancel(id: WalletCancelations.AssetInitializationId),
                    .cancel(id: WalletCancelations.InitializationId),
                    .cancel(id: WalletCancelations.UpgradeId),
                    Effect.send(CoreAppAction.loggedIn(.start(context))),
                    Effect.send(CoreAppAction.mobileAuthSync(isLogin: true))
                )

            case .onboarding(.informForWalletInitialization):
                return Effect.send(.initializeWallet)

            case .onboarding(.welcomeScreen(.emailLogin(.verifyDevice(.credentials(.seedPhrase(.resetPassword(.reset(let password)))))))),
                 .onboarding(.welcomeScreen(.restoreWallet(.resetPassword(.reset(let password))))):
                return Effect.send(.resetPassword(newPassword: password))

            case .onboarding(.passwordScreen(.authenticate(let password))):
                return Effect.send(
                    .fetchWallet(password: password)
                )

            case .onboarding(.pin(.handleAuthentication(let password))):
                environment.app.post(event: blockchain.ux.user.event.authenticated.pin)
                return Effect.send(.fetchWallet(password: password))

            case .onboarding(.pin(.pinCreated)):
                environment.loadingViewPresenter.showCircular()
                return Effect.send(
                    .initializeWallet
                )

            case .onboarding(.welcomeScreen(.requestedToDecryptWallet(let password))):
                return Effect.send(
                    .fetchWallet(password: password)
                )

            case .onboarding(.welcomeScreen(.requestedToRestoreWallet(let walletRecovery))):
                switch walletRecovery {
                case .metadataRecovery,
                     .importRecovery:
                    return .none
                case .resetAccountRecovery:
                    return .none
                }
            case .loggedIn(.deleteWallet):

                NotificationCenter.default.post(name: .logout, object: nil)
                environment.siftService.removeUserId()
                environment.sharedContainer.reset()
                environment.blockchainSettings.reset()

                // forget wallet
                environment.credentialsStore.erase()

                // update state
                state.loggedIn = nil
                state.onboarding = .init(
                    welcomeState: .init()
                )

                return .merge(
                    .publisher {
                        environment.forgetWalletService
                            .forget()
                            .catch { _ in Just(()) }
                            .map { .none }
                            .receive(on: environment.mainQueue)
                    },
                    .publisher {
                        environment
                            .pushNotificationsRepository
                            .revokeToken()
                            .catch { _ in Just(()) }
                            .map { .none }
                            .receive(on: environment.mainQueue)
                    },
                    .publisher {
                        environment
                            .mobileAuthSyncService
                            .updateMobileSetup(isMobileSetup: false)
                            .catch { _ in Just(()) }
                            .map { .none }
                            .receive(on: environment.mainQueue)
                    },
                    .publisher {
                        environment
                            .mobileAuthSyncService
                            .verifyCloudBackup(hasCloudBackup: false)
                            .catch { _ in Just(()) }
                            .map { .none }
                            .receive(on: environment.mainQueue)
                    }
                )
            case .onboarding(.welcomeScreen(.informWalletFetched(let context))):
                return Effect.send(.wallet(.walletFetched(.success(context))))
            case .onboarding(.pin(.logout)),
                 .loggedIn(.logout):
                // reset

                NotificationCenter.default.post(name: .logout, object: nil)
                environment.siftService.removeUserId()
                environment.sharedContainer.reset()
                environment.blockchainSettings.reset()

                // update state
                state.loggedIn = nil
                state.onboarding = .init(
                    pinState: nil,
                    passwordRequiredState: .init(
                        walletIdentifier: environment.legacyGuidRepository.directGuid ?? ""
                    )
                )
                // show password screen
                return Effect.send(.onboarding(.passwordScreen(.start)))

            case .loggedIn(.exitToPinScreen):
                state.loggedIn = nil
                state.onboarding = .init(
                    pinState: .init(creating: false, authenticate: true)
                )
                return Effect.send(.loggedIn(.start(.none)))

            case .loggedIn(.wallet(.authenticateForBiometrics(let password))):
                return Effect.send(.fetchWallet(password: password))

            case .resetPassword(let newPassword):
                return .run { send in
                    do {
                        try await environment
                            .resetPasswordService
                            .setNewPassword(newPassword: newPassword)
                            .await()

                        environment.analyticsRecorder.record(
                            event: AnalyticsEvents.New.AccountRecoveryCoreFlow
                                .accountPasswordReset(hasRecoveryPhrase: true)
                        )
                        // proceed to setup PIN after reset password if needed
                        guard environment.blockchainSettings.isPinSet else {
                            await send(.setupPin)
                            return
                        }
                    } catch {
                        environment.analyticsRecorder.record(
                            event: AnalyticsEvents.New.AccountRecoveryCoreFlow.accountRecoveryFailed
                        )
                    }
                }

            case .resetVerificationStatusIfNeeded(let guidOrNil, let sharedKeyOrNil):
                guard state.onboarding?.walletRecoveryContext != nil,
                      let guid = guidOrNil,
                      let sharedKey = sharedKeyOrNil
                else {
                    return .none
                }
                return .publisher {
                    environment
                        .accountRecoveryService
                        .resetVerificationStatus(guid: guid, sharedKey: sharedKey)
                        .catch { _ in
                            environment.analyticsRecorder.record(
                                event: AnalyticsEvents.New.AccountRecoveryCoreFlow.accountRecoveryFailed
                            )
                            return Just(())
                        }
                        .map { .none }
                        .receive(on: environment.mainQueue)
                }

            case .mobileAuthSync(let isLogin):
                return .merge(
                    .publisher {
                        environment
                            .mobileAuthSyncService
                            .updateMobileSetup(isMobileSetup: isLogin)
                            .catch { _ in Just(()) }
                            .map { .none }
                            .receive(on: environment.mainQueue)
                    },
                    .publisher {
                        environment
                            .mobileAuthSyncService
                            .verifyCloudBackup(hasCloudBackup: isLogin)
                            .catch { _ in Just(()) }
                            .map { .none }
                            .receive(on: environment.mainQueue)
                    }
                )

            case .onboarding,
                 .loggedIn,
                 .authorizeDevice,
                 .none:
                return .none
            default:
                return .none
            }
        }
        WalletReducer(environment: environment)
        AlertReducer(environment: environment)
    }
}

// MARK: - Alert Reducer

struct AlertReducer: Reducer {

    typealias State = CoreAppState
    typealias Action = CoreAppAction

    let environment: CoreAppEnvironment

    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .alert(.show(let title, let message, let buttons)):
                let defaultButton = ButtonState<CoreAppAction>.default(
                    TextState(verbatim: LocalizationConstants.ErrorAlert.button),
                    action: .send(.alert(.dismiss))
                )
                let buttons = buttons ?? CoreAlertAction.Buttons(
                    primary: defaultButton,
                    secondary: nil
                )
                if let secondary = buttons.secondary {
                    state.alertState = AlertState(
                        title: TextState(verbatim: title),
                        message: TextState(verbatim: message),
                        primaryButton: buttons.primary,
                        secondaryButton: secondary
                    )
                } else {
                    state.alertState = AlertState(
                        title: TextState(verbatim: title),
                        message: TextState(verbatim: message),
                        dismissButton: buttons.primary
                    )
                }
                return .none
            case .alert(.dismiss):
                state.alertState = nil
                return .none

            case .alert(.openAppStore):
                state.alertState = nil
                environment.appStoreOpener.openAppStore()
                return .none
            default:
                return .none
            }
        }
    }
}

// MARK: Private Methods

/// - Note:
/// In order to login to wallet, we need to know:
/// - GUID                 - To look up the wallet
/// - SharedKey            - To be able to read/write to the wallet db record (payload, settings, etc)
/// - EncryptedPinPassword - To decrypt the wallet
/// - PinKey               - Used in conjunction with the user's PIN to retrieve decryption key to the -  EncryptedPinPassword (EncryptedWalletPassword)
/// - PIN                  - Provided by the user or retrieved from secure enclave if Face/TouchID is enabled
///
/// In this method, we backup/restore the pinKey - which is essentially the identifier of the PIN.
/// Upon successful PIN authentication, we will backup/restore the remaining wallet details: guid, sharedKey, encryptedPinPassword.
///
/// The backup/restore of guid and sharedKey requires an encryption/decryption step when backing up and restoring respectively.
///
/// The key used to encrypt/decrypt the guid and sharedKey is provided in the response to a successful PIN auth attempt.
func syncPinKeyWithICloud(
    blockchainSettings: BlockchainSettingsAppAPI,
    legacyGuid: LegacyGuidRepositoryAPI,
    legacySharedKey: LegacySharedKeyRepositoryAPI,
    credentialsStore: CredentialsStoreAPI
) {
    guard blockchainSettings.pinKey == nil,
          blockchainSettings.encryptedPinPassword == nil,
          legacyGuid.directGuid == nil,
          legacySharedKey.directSharedKey == nil
    else {
        // Wallet is Paired, we do not need to restore.
        // We will back up after pin authentication
        return
    }

    credentialsStore.synchronize()

    // Attempt to restore the pinKey from iCloud
    if let pinData = credentialsStore.pinData() {
        blockchainSettings.set(pinKey: pinData.pinKey)
        blockchainSettings.set(encryptedPinPassword: pinData.encryptedPinPassword)
    }
}

func clearPinIfNeeded(for passwordPartHash: String?, appSettings: AppSettingsAuthenticating) {
    // Because we are not storing the password on the device. We record the first few letters of the hashed password.
    // With the hash prefix we can then figure out if the password changed. If so, clear the pin
    // so that the user can reset it
    guard let passwordPartHash,
          let savedPasswordPartHash = appSettings.passwordPartHash
    else {
        return
    }

    guard passwordPartHash != savedPasswordPartHash else {
        return
    }

    appSettings.clearPin()
}
