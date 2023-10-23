// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import AnalyticsKit
import BlockchainNamespace
import Combine
import ComposableArchitecture
import FeatureAuthenticationDomain
import FeatureSettingsDomain
import Localization
import ObservabilityKit
import PlatformKit
import PlatformUIKit
import RemoteNotificationsKit
import RxSwift
import ToolKit
import UnifiedActivityDomain
import WalletPayloadKit

struct LoggedInIdentifier: Hashable {}

public enum LoggedIn {
    /// Transient context to be used as part of start method
    public enum Context: Equatable {
        case wallet(WalletCreationContext)
        case deeplink(URIContent)
        case none
    }

    public enum Action: Equatable {
        case none
        case start(LoggedIn.Context)
        case stop
        case logout
        case deleteWallet
        case deeplink(URIContent)
        case deeplinkHandled
        // wallet related actions
        case wallet(WalletAction)
        case handleNewWalletCreation
        case handleExistingWalletSignIn
        case showPostSignUpOnboardingFlow
        case didShowPostSignUpOnboardingFlow
        case showPostSignInOnboardingFlow
        case didShowPostSignInOnboardingFlow
        case exitToPinScreen
    }

    public struct State: Equatable {
        public var displaySendCryptoScreen: Bool = false
        public var displayPostSignUpOnboardingFlow: Bool = false
        public var displayPostSignInOnboardingFlow: Bool = false
    }

    public enum WalletAction: Equatable {
        case authenticateForBiometrics(password: String)
    }
}

struct LoggedInReducer: Reducer {

    typealias State = LoggedIn.State
    typealias Action = LoggedIn.Action

    var analyticsRecorder: AnalyticsEventRecorderAPI
    var app: AppProtocol
    var appSettings: BlockchainSettingsAppAPI
    var deeplinkRouter: DeepLinkRouting
    var exchangeRepository: ExchangeAccountRepositoryAPI
    var fiatCurrencySettingsService: FiatCurrencySettingsServiceAPI
    var loadingViewPresenter: LoadingViewPresenting
    var mainQueue: AnySchedulerOf<DispatchQueue>
    var nabuUserService: NabuUserServiceAPI
    var performanceTracing: PerformanceTracingServiceAPI
    var reactiveWallet: ReactiveWalletAPI
    var remoteNotificationAuthorizer: RemoteNotificationAuthorizationRequesting
    var remoteNotificationTokenSender: RemoteNotificationTokenSending
    var unifiedActivityService: UnifiedActivityPersistenceServiceAPI

    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .start(let context):
                unifiedActivityService.connect()
                NotificationCenter.default.post(name: .login, object: nil)
                return .merge(
                    .publisher {
                        exchangeRepository
                            .syncDepositAddressesIfLinked()
                            .receive(on: mainQueue)
                            .map { .none }
                            .catch { _ in .none }
                    },
                    .publisher {
                        remoteNotificationTokenSender
                            .sendTokenIfNeeded()
                            .receive(on: mainQueue)
                            .map { .none }
                            .catch { _ in .none }
                    },
                    .publisher {
                        remoteNotificationAuthorizer
                            .requestAuthorizationIfNeeded()
                            .receive(on: mainQueue)
                            .map { .none }
                            .catch { _ in .none }
                    },
                    handleStartup(
                        context: context
                    )
                )
            case .deeplink(let content):
                let context = content.context
                guard context == .executeDeeplinkRouting else {
                    guard context == .sendCrypto else {
                        return Effect.send(.deeplinkHandled)
                    }
                    state.displaySendCryptoScreen = true
                    return Effect.send(.deeplinkHandled)
                }
                // perform legacy routing
                deeplinkRouter.routeIfNeeded()
                return .none
            case .deeplinkHandled:
                // clear up state
                state.displaySendCryptoScreen = false
                return .none
            case .handleNewWalletCreation:
                app.post(event: blockchain.user.wallet.created)
                return Effect.send(.showPostSignUpOnboardingFlow)
            case .handleExistingWalletSignIn:
                return Effect.send(.showPostSignInOnboardingFlow)
            case .showPostSignUpOnboardingFlow:
                // display new onboarding flow
                state.displayPostSignUpOnboardingFlow = true
                app.post(event: blockchain.ux.onboarding.intro.event.show.sign.up)
                return .none
            case .didShowPostSignUpOnboardingFlow:
                state.displayPostSignUpOnboardingFlow = false
                return .none
            case .showPostSignInOnboardingFlow:
                state.displayPostSignInOnboardingFlow = true
                app.post(event: blockchain.ux.onboarding.intro.event.show.sign.in)
                return .none
            case .didShowPostSignInOnboardingFlow:
                state.displayPostSignInOnboardingFlow = false
                return .none
            case .logout:
                state = LoggedIn.State()
                return .cancel(id: LoggedInIdentifier())
            case .deleteWallet:
                return Effect.send(.logout)
            case .stop:
                // We need to cancel any running operations if we require pin entry.
                // Although this is the same as logout and .wallet(.authenticateForBiometrics)
                // I wanted to have a distinct action for this.
                return .cancel(id: LoggedInIdentifier())
            case .wallet(.authenticateForBiometrics):
                return .cancel(id: LoggedInIdentifier())
            case .wallet:
                return .none
            case .none:
                return .none
            case .exitToPinScreen:
                state = LoggedIn.State()
                return .cancel(id: LoggedInIdentifier())
            }
        }
        NamespaceReducer(app: app)
    }
}

// MARK: Private

/// Handle the context of a logged in state, eg wallet creation, deeplink, etc
/// - Parameter context: A `LoggedIn.Context` to be taken into account after logging in
/// - Returns: An `Effect<LoggedIn.Action>` based on the context
private func handleStartup(
    context: LoggedIn.Context
) -> Effect<LoggedIn.Action> {
    switch context {
    case .wallet(let walletContext) where walletContext.isNew:
        return Effect.send(.handleNewWalletCreation)
    case .wallet:
        // ignore existing/recovery wallet context
        return .none
    case .deeplink(let deeplinkContent):
        return Effect.send(.deeplink(deeplinkContent))
    case .none:
        return Effect.send(.handleExistingWalletSignIn)
    }
}

struct NamespaceReducer: Reducer {

    typealias State = LoggedIn.State
    typealias Action = LoggedIn.Action

    var app: AppProtocol

    var body: some Reducer<State, Action> {
        Reduce { _, action in
            switch action {
            case .logout:
                app.signOut()
                return .none
            default:
                return .none
            }
        }
    }
}
