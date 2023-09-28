// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainNamespace
import Combine
import ComposableArchitecture
import FeatureAppDomain
import FeatureAppUpgradeDomain
import FeatureAppUpgradeUI
import FeatureAuthenticationDomain
import FeatureAuthenticationUI
import FeatureSettingsDomain
import PlatformKit
import PlatformUIKit
import ToolKit
import WalletPayloadKit

public enum Onboarding {
    public enum Alert: Equatable {
        case proceedToLoggedIn(ProceedToLoggedInError)
        case walletCreation(WalletCreationServiceError)
        case walletRecovery(WalletRecoveryError)
    }

    public enum Action: Equatable {
        case start
        case showAppUpgrade(AppUpgradeState)
        case proceedToFlow
        case pin(PinCore.Action)
        case appUpgrade(AppUpgradeAction)
        case passwordScreen(PasswordRequiredAction)
        case welcomeScreen(WelcomeAction)
        /// Used to change state on sub-reducers
        case handleWalletDecryptionError
        case handleMetadataRecoveryAfterAuthentication
        case informSecondPasswordDetected
        case informForWalletInitialization
        case forgetWallet
    }

    public struct State: Equatable {
        public var pinState: PinCore.State?
        public var appUpgradeState: AppUpgradeState?
        public var passwordRequiredState: PasswordRequiredState?
        public var welcomeState: WelcomeState?
        public var displayAlert: Alert?
        public var deeplinkContent: URIContent?
        public var walletCreationContext: WalletCreationContext?
        public var walletRecoveryContext: WalletRecoveryContext?

        public init(
            pinState: PinCore.State? = nil,
            appUpgradeState: AppUpgradeState? = nil,
            passwordRequiredState: PasswordRequiredState? = nil,
            welcomeState: WelcomeState? = nil,
            displayAlert: Alert? = nil,
            deeplinkContent: URIContent? = nil,
            walletCreationContext: WalletCreationContext? = nil
        ) {
            self.pinState = pinState
            self.appUpgradeState = appUpgradeState
            self.passwordRequiredState = passwordRequiredState
            self.welcomeState = welcomeState
            self.displayAlert = displayAlert
            self.deeplinkContent = deeplinkContent
            self.walletCreationContext = walletCreationContext
        }
    }
}

/// The reducer responsible for handing Pin screen and Login/Onboarding screen related action and state.
struct OnboardingReducer: ReducerProtocol {

    typealias State = Onboarding.State
    typealias Action = Onboarding.Action

    let app: AppProtocol
    var appSettings: BlockchainSettingsAppAPI
    var credentialsStore: CredentialsStoreAPI
    var alertPresenter: AlertViewPresenterAPI
    var mainQueue: AnySchedulerOf<DispatchQueue>
    let deviceVerificationService: DeviceVerificationServiceAPI
    var legacyGuidRepository: LegacyGuidRepositoryAPI
    var legacySharedKeyRepository: LegacySharedKeyRepositoryAPI
    let mobileAuthSyncService: MobileAuthSyncServiceAPI
    let pushNotificationsRepository: PushNotificationsRepositoryAPI
    let walletPayloadService: WalletPayloadServiceAPI
    let externalAppOpener: ExternalAppOpener
    let forgetWalletService: ForgetWalletService
    let recaptchaService: GoogleRecaptchaServiceAPI
    var buildVersionProvider: () -> String
    var appUpgradeState: () -> AnyPublisher<AppUpgradeState?, Never>

    var body: some ReducerProtocol<State, Action> {
        Reduce { state, action in
            switch action {
            case .showAppUpgrade(let appUpgradeState):
                state.appUpgradeState = appUpgradeState
                return .none
            case .appUpgrade(AppUpgradeAction.skip):
                return EffectTask(value: .proceedToFlow)
            case .start:
                return .merge(
                    .fireAndForget {
                        recaptchaService.load()
                    },
                    appUpgradeState()
                        .eraseToEffect()
                        .map { state in
                            guard let state else {
                                return .proceedToFlow
                            }
                            return .showAppUpgrade(state)
                        }
                )
            case .proceedToFlow:
                return decideFlow(
                    state: &state,
                    legacyGuidRepository: legacyGuidRepository,
                    legacySharedKeyRepository: legacySharedKeyRepository,
                    settingsAuthenticating: appSettings
                )
            case .pin:
                return .none

            case .welcomeScreen(.route(nil)):
                // don't clear the state if the state is .new when dismissing the modal by setting the screen flow back to welcome screen
                if state.walletCreationContext == .existing || state.walletCreationContext == .recovery {
                    state.walletCreationContext = nil
                }
                return .none

            case .welcomeScreen(WelcomeAction.navigate(to: WelcomeRoute.createWallet)),
                 .welcomeScreen(WelcomeAction.enter(into: WelcomeRoute.createWallet)):
                state.walletCreationContext = .new
                return .none

            case .welcomeScreen(WelcomeAction.enter(into: WelcomeRoute.emailLogin)):
                state.walletCreationContext = .existing
                return .none

            case .welcomeScreen(WelcomeAction.enter(into: WelcomeRoute.restoreWallet)):
                state.walletCreationContext = .recovery
                return .none
            case .welcomeScreen(.requestedToRestoreWallet(let walletRecovery)):
                switch walletRecovery {
                case .metadataRecovery(let seedPhrase):
                    state.walletRecoveryContext = .metadataRecovery
                    return .none
                case .importRecovery:
                    state.walletRecoveryContext = .importRecovery
                    return .none
                case .resetAccountRecovery(let email, let newPassword, let nabuInfo):
                    return .none
                }
            case .welcomeScreen(.informForWalletInitialization):
                return EffectTask(value: .informForWalletInitialization)
            case .welcomeScreen:
                return .none
            case .passwordScreen(.forgetWallet),
                 .forgetWallet:
                state.passwordRequiredState = nil
                state.pinState = nil
                state.welcomeState = .init()

                return .merge(
                    .fireAndForget {
                        appSettings.clear()
                        credentialsStore.erase()
                    },
                    forgetWalletService.forget().fireAndForget(),
                    EffectTask(value: .welcomeScreen(.start))
                )
            case .passwordScreen:
                return .none
            case .informSecondPasswordDetected:
                guard state.welcomeState != nil else {
                    return .none
                }
                return EffectTask(value: .welcomeScreen(.informSecondPasswordDetected))

            case .informForWalletInitialization:
                return .none
            case .handleWalletDecryptionError:
                if state.welcomeState?.manualCredentialsState != nil {
                    return EffectTask(
                        value: .welcomeScreen(
                            .manualPairing(
                                .password(
                                    .showIncorrectPasswordError(true)
                                )
                            )
                        )
                    )
                }
                return EffectTask(
                    value: .welcomeScreen(
                        .emailLogin(
                            .verifyDevice(
                                .credentials(
                                    .password(
                                        .showIncorrectPasswordError(true)
                                    )
                                )
                            )
                        )
                    )
                )
            case .handleMetadataRecoveryAfterAuthentication:
                // if it is from the restore wallet screen
                if state.welcomeState?.restoreWalletState != nil {
                    return .merge(
                        EffectTask(value: .welcomeScreen(.restoreWallet(.setResetPasswordScreenVisible(true))))
                    )
                    // if it is from the trouble logging in screen
                } else if state.welcomeState?.emailLoginState != nil {
                    return .merge(
                        EffectTask(
                            value: .welcomeScreen(
                                .emailLogin(
                                    .verifyDevice(
                                        .credentials(
                                            .seedPhrase(
                                                .setResetPasswordScreenVisible(true))
                                        )
                                    )
                                )
                            )
                        )
                    )
                }
                return .none
            }
        }
        .ifLet(\Onboarding.State.welcomeState, action: /Onboarding.Action.welcomeScreen) {
            WelcomeReducer(
                app: app,
                mainQueue: mainQueue,
                deviceVerificationService: deviceVerificationService,
                recaptchaService: recaptchaService,
                buildVersionProvider: buildVersionProvider
            )
        }
        .ifLet(\Onboarding.State.pinState, action: /Onboarding.Action.pin) {
            PinReducer(alertPresenter: alertPresenter)
        }
        .ifLet(\Onboarding.State.passwordRequiredState, action: /Onboarding.Action.passwordScreen) {
            PasswordRequiredReducer(
                mainQueue: mainQueue,
                externalAppOpener: externalAppOpener,
                walletPayloadService: walletPayloadService,
                pushNotificationsRepository: pushNotificationsRepository,
                mobileAuthSyncService: mobileAuthSyncService,
                forgetWalletService: forgetWalletService
            )
        }
        .ifLet(\Onboarding.State.appUpgradeState, action: /Onboarding.Action.appUpgrade) {
            AppUpgradeReducer()
        }
    }
}

// MARK: - Internal Methods

func decideFlow(
    state: inout Onboarding.State,
    legacyGuidRepository: LegacyGuidRepositoryAPI,
    legacySharedKeyRepository: LegacySharedKeyRepositoryAPI,
    settingsAuthenticating: AppSettingsAuthenticating
) -> EffectTask<Onboarding.Action> {
    state.appUpgradeState = nil
    if legacyGuidRepository.directGuid != nil, legacySharedKeyRepository.directSharedKey != nil {
        // Original flow
        if settingsAuthenticating.isPinSet {
            state.pinState = .init()
            state.passwordRequiredState = nil
            return EffectTask(value: .pin(.authenticate))
        } else {
            state.pinState = nil
            state.passwordRequiredState = .init(
                walletIdentifier: legacyGuidRepository.directGuid ?? ""
            )
            return EffectTask(value: .passwordScreen(.start))
        }
    } else if settingsAuthenticating.pinKey != nil, settingsAuthenticating.encryptedPinPassword != nil {
        // iCloud restoration flow
        if settingsAuthenticating.isPinSet {
            state.pinState = .init()
            state.passwordRequiredState = nil
            return EffectTask(value: .pin(.authenticate))
        } else {
            state.pinState = nil
            state.passwordRequiredState = .init(
                walletIdentifier: legacyGuidRepository.directGuid ?? ""
            )
            return EffectTask(value: .passwordScreen(.start))
        }
    } else {
        state.pinState = nil
        state.passwordRequiredState = nil
        state.welcomeState = .init()
        return EffectTask(value: .welcomeScreen(.start))
    }
}
