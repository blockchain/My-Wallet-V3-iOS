// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainNamespace
import Combine
import ComposableArchitecture
import DIKit
import FeatureAppDomain
import FeatureAppUpgradeDomain
import FeatureAppUpgradeUI
import FeatureOpenBankingDomain
import FeatureSettingsDomain
import ToolKit
import UIKit
import WalletPayloadKit

// swiftformat:disable indent

enum AppCancellations {
    struct DeeplinkId: Hashable {}
    struct WalletPersistenceId: Hashable {}
}

public struct AppState: Equatable {
    public var appSettings: AppDelegateState = .init()
    public var coreState: CoreAppState = .init()

    public init(
        appSettings: AppDelegateState = .init(),
        coreState: CoreAppState = .init()
    ) {
        self.appSettings = appSettings
        self.coreState = coreState
    }
}

public enum AppAction: Equatable {
    case appDelegate(AppDelegateAction)
    case core(CoreAppAction)
    case walletPersistence(WalletPersistenceAction)
    case none
}

public enum WalletPersistenceAction: Equatable {
    case begin
    case cancel
    case persisted(Result<EmptyValue, WalletRepoPersistenceError>)
}

public let appReducer = Reducer<AppState, AppAction, AppEnvironment>.combine(
    appDelegateReducer
        .pullback(
            state: \.appSettings,
            action: /AppAction.appDelegate,
            environment: {
                AppDelegateEnvironment(
                    app: $0.app,
                    cacheSuite: $0.cacheSuite,
                    remoteNotificationBackgroundReceiver: $0.remoteNotificationServiceContainer.backgroundReceiver,
                    remoteNotificationAuthorizer: $0.remoteNotificationServiceContainer.authorizer,
                    remoteNotificationTokenReceiver: $0.remoteNotificationServiceContainer.tokenReceiver,
                    certificatePinner: $0.certificatePinner,
                    siftService: $0.siftService,
                    blurEffectHandler: $0.blurEffectHandler,
                    backgroundAppHandler: $0.backgroundAppHandler,
                    assetsRemoteService: $0.assetsRemoteService,
                    featureFlagService: $0.featureFlagsService,
                    observabilityService: $0.observabilityService,
                    mainQueue: $0.mainQueue
                )
            }
        ),
    mainAppReducer
        .pullback(
            state: \AppState.coreState,
            action: /AppAction.core,
            environment: { env in
                CoreAppEnvironment(
                    accountRecoveryService: env.accountRecoveryService,
                    alertPresenter: env.alertViewPresenter,
                    analyticsRecorder: env.analyticsRecorder,
                    app: env.app,
                    appStoreOpener: env.appStoreOpener,
                    appUpgradeState: {
                        let service = AppUpgradeStateService(
                            app: env.app,
                            deviceInfo: env.deviceInfo
                        )
                        return service
                            .state
                            .receive(on: env.mainQueue)
                            .eraseToAnyPublisher()
                    },
                    blockchainSettings: env.blockchainSettings,
                    buildVersionProvider: env.buildVersionProvider,
                    coincore: env.coincore,
                    credentialsStore: env.credentialsStore,
                    deeplinkHandler: env.deeplinkHandler,
                    deeplinkRouter: env.deeplinkRouter,
                    delegatedCustodySubscriptionsService: env.delegatedCustodySubscriptionsService,
                    deviceVerificationService: env.deviceVerificationService,
                    erc20CryptoAssetService: env.erc20CryptoAssetService,
                    exchangeRepository: env.exchangeRepository,
                    externalAppOpener: env.externalAppOpener,
                    featureFlagsService: env.featureFlagsService,
                    fiatCurrencySettingsService: env.fiatCurrencySettingsService,
                    forgetWalletService: env.forgetWalletService,
                    legacyGuidRepository: env.legacyGuidRepository,
                    legacySharedKeyRepository: env.legacySharedKeyRepository,
                    loadingViewPresenter: env.loadingViewPresenter,
                    mainQueue: env.mainQueue,
                    mobileAuthSyncService: env.mobileAuthSyncService,
                    nabuUserService: env.nabuUserService,
                    observabilityService: env.observabilityService,
                    performanceTracing: env.performanceTracing,
                    pushNotificationsRepository: env.pushNotificationsRepository,
                    reactiveWallet: env.reactiveWallet,
                    recaptchaService: env.recaptchaService,
                    remoteNotificationServiceContainer: env.remoteNotificationServiceContainer,
                    resetPasswordService: env.resetPasswordService,
                    sharedContainer: env.sharedContainer,
                    siftService: env.siftService,
                    unifiedActivityService: env.unifiedActivityService,
                    walletPayloadService: env.walletPayloadService,
                    walletService: env.walletService,
                    walletStateProvider: env.walletStateProvider
                )
            }
        ),
    appReducerCore
)

let appReducerCore = Reducer<AppState, AppAction, AppEnvironment> { state, action, environment in
    switch action {
    case .appDelegate(.didFinishLaunching):
        return .init(value: .core(.start))
    case .appDelegate(.didEnterBackground):
        return .none
    case .appDelegate(.willEnterForeground):
        return Effect(value: .core(.appForegrounded))
    case .appDelegate(.handleDelayedEnterBackground):
        if environment.openBanking.isAuthorising {
            return .none
        }
        if environment.cardService.isEnteringDetails {
            return .none
        }

        if environment.app.state.yes(
            if: blockchain.ux.payment.method.plaid.is.linking
        ) {
            return .none
        }

        if environment.app.state.yes(
            if: blockchain.ux.pin.is.disabled
        ) {
            return .none
        }

        if environment.app.state.contains(
            blockchain.ux.transaction.id
        ) {
            return .none
        }

        return .merge(
            .fireAndForget {
                environment.walletStateProvider.releaseState()
            },
            .fireAndForget {
                environment.urlSession.reset {
                    Logger.shared.debug("URLSession reset completed.")
                }
            }
        )
    case .appDelegate(.userActivity(let activity)):
        state.appSettings.userActivityHandled = environment.deeplinkAppHandler.canHandle(
            deeplink: .userActivity(activity)
        )
        return environment.deeplinkAppHandler
            .handle(deeplink: .userActivity(activity))
            .receive(on: environment.mainQueue)
            .catchToEffect()
            .cancellable(id: AppCancellations.DeeplinkId())
            .map { result in
                guard let data = result.success else {
                    return AppAction.core(.none)
                }
                return AppAction.core(.deeplink(data))
            }
    case .appDelegate(.open(let url)):
        state.appSettings.urlHandled = environment.deeplinkAppHandler.canHandle(deeplink: .url(url))
        return environment.deeplinkAppHandler
            .handle(deeplink: .url(url))
            .receive(on: environment.mainQueue)
            .catchToEffect()
            .cancellable(id: AppCancellations.DeeplinkId())
            .map { result in
                guard let data = result.success else {
                    return AppAction.core(.none)
                }
                return AppAction.core(.deeplink(data))
            }
    case .core(.onboarding(.forgetWallet)):
        return .none
    case .core(.start):
        return .merge(
            Effect(value: .walletPersistence(.begin)),
            Effect(value: .core(.onboarding(.start)))
        )
    case .walletPersistence(.begin):
        let crashlyticsRecorder = environment.crashlyticsRecorder
        return environment.walletRepoPersistence
            .beginPersisting()
            .receive(on: environment.mainQueue)
            .catchToEffect()
            .cancellable(
                id: AppCancellations.WalletPersistenceId(),
                cancelInFlight: true
            )
            .map { AppAction.walletPersistence(.persisted($0.map { _ in EmptyValue.noValue })) }
    case .walletPersistence(.persisted(.failure(let error))):
        // record the error if we encounter one and restart the persistence
        environment.crashlyticsRecorder.error(error)
        return .concatenate(
            .cancel(id: AppCancellations.WalletPersistenceId()),
            Effect(value: .walletPersistence(.begin))
        )
    case .walletPersistence(.persisted(.success)):
        return .none
    case .none:
        return .none
    default:
        return .none
    }
}
