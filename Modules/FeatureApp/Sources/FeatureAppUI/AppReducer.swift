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

public struct AppReducer: Reducer {

    public typealias State = AppState
    public typealias Action = AppAction

    public let environment: AppEnvironment

    public init(
        environment: AppEnvironment
    ) {
        self.environment = environment
    }

    public var body: some Reducer<State, Action> {
        Scope(state: \.appSettings, action: /AppAction.appDelegate) {
            AppDelegateReducer(
                environment: AppDelegateEnvironment(
                    app: environment.app,
                    cacheSuite: environment.cacheSuite,
                    remoteNotificationBackgroundReceiver: environment.remoteNotificationServiceContainer.backgroundReceiver,
                    remoteNotificationAuthorizer: environment.remoteNotificationServiceContainer.authorizer,
                    remoteNotificationTokenReceiver: environment.remoteNotificationServiceContainer.tokenReceiver,
                    certificatePinner: environment.certificatePinner,
                    siftService: environment.siftService,
                    blurEffectHandler: environment.blurEffectHandler,
                    backgroundAppHandler: environment.backgroundAppHandler,
                    assetsRemoteService: environment.assetsRemoteService,
                    mainQueue: environment.mainQueue,
                    crashlyticsRecorder: environment.crashlyticsRecorder
                )
            )
        }
        Scope(state: \AppState.coreState, action: /AppAction.core) {
            MainAppReducer(
                environment: CoreAppEnvironment(
                    accountRecoveryService: environment.accountRecoveryService,
                    alertPresenter: environment.alertViewPresenter,
                    analyticsRecorder: environment.analyticsRecorder,
                    app: environment.app,
                    appStoreOpener: environment.appStoreOpener,
                    appUpgradeState: {
                        let service = AppUpgradeStateService(
                            app: environment.app,
                            deviceInfo: environment.deviceInfo
                        )
                        return service
                            .state
                            .receive(on: environment.mainQueue)
                            .eraseToAnyPublisher()
                    },
                    blockchainSettings: environment.blockchainSettings,
                    buildVersionProvider: environment.buildVersionProvider,
                    coincore: environment.coincore,
                    credentialsStore: environment.credentialsStore,
                    deeplinkHandler: environment.deeplinkHandler,
                    deeplinkRouter: environment.deeplinkRouter,
                    delegatedCustodySubscriptionsService: environment.delegatedCustodySubscriptionsService,
                    deviceVerificationService: environment.deviceVerificationService,
                    erc20CryptoAssetService: environment.erc20CryptoAssetService,
                    exchangeRepository: environment.exchangeRepository,
                    externalAppOpener: environment.externalAppOpener,
                    fiatCurrencySettingsService: environment.fiatCurrencySettingsService,
                    forgetWalletService: environment.forgetWalletService,
                    legacyGuidRepository: environment.legacyGuidRepository,
                    legacySharedKeyRepository: environment.legacySharedKeyRepository,
                    loadingViewPresenter: environment.loadingViewPresenter,
                    mainQueue: environment.mainQueue,
                    mobileAuthSyncService: environment.mobileAuthSyncService,
                    nabuUserService: environment.nabuUserService,
                    performanceTracing: environment.performanceTracing,
                    pushNotificationsRepository: environment.pushNotificationsRepository,
                    reactiveWallet: environment.reactiveWallet,
                    recaptchaService: environment.recaptchaService,
                    remoteNotificationServiceContainer: environment.remoteNotificationServiceContainer,
                    resetPasswordService: environment.resetPasswordService,
                    sharedContainer: environment.sharedContainer,
                    siftService: environment.siftService,
                    unifiedActivityService: environment.unifiedActivityService,
                    walletPayloadService: environment.walletPayloadService,
                    walletService: environment.walletService,
                    walletStateProvider: environment.walletStateProvider
                )
            )
        }
        AppReducerCore(environment: environment)
    }
}

struct AppReducerCore: Reducer {

    typealias State = AppState
    typealias Action = AppAction

    let environment: AppEnvironment

    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .appDelegate(.didFinishLaunching):
                return .send(.core(.start))
            case .appDelegate(.didEnterBackground):
                return .none
            case .appDelegate(.willEnterForeground):
                return Effect.send(.core(.appForegrounded))
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
                    .run { _ in
                        environment.walletStateProvider.releaseState()
                    },
                    .run { _ in
                        await environment.urlSession.reset()
                        Logger.shared.debug("URLSession reset completed.")
                    }
                )
            case .appDelegate(.userActivity(let activity)):
                state.appSettings.userActivityHandled = environment.deeplinkAppHandler.canHandle(
                    deeplink: .userActivity(activity)
                )
                let context = DeeplinkContext.userActivity(activity)
                return .publisher {
                    environment.deeplinkAppHandler
                        .handle(deeplink: context)
                        .receive(on: environment.mainQueue)
                        .map { .core(.deeplink($0)) }
                        .catch { _ in .core(.none) }
                }
                .cancellable(id: AppCancellations.DeeplinkId())
            case .appDelegate(.open(let url)):
                state.appSettings.urlHandled = environment.deeplinkAppHandler.canHandle(deeplink: .url(url))
                return .publisher {
                    environment.deeplinkAppHandler
                        .handle(deeplink: .url(url))
                        .receive(on: environment.mainQueue)
                        .map { .core(.deeplink($0)) }
                        .catch { _ in .core(.none) }
                }
                .cancellable(id: AppCancellations.DeeplinkId())
            case .core(.onboarding(.forgetWallet)):
                return .none
            case .core(.start):
                return .merge(
                    Effect.send(.walletPersistence(.begin)),
                    Effect.send(.core(.onboarding(.start)))
                )
            case .walletPersistence(.begin):
                return .publisher {
                    environment.walletRepoPersistence
                        .beginPersisting()
                        .map { Action.walletPersistence(.persisted(.success(EmptyValue.noValue))) }
                        .catch { Action.walletPersistence(.persisted(.failure($0))) }
                        .receive(on: environment.mainQueue)
                }
                .cancellable(
                    id: AppCancellations.WalletPersistenceId(),
                    cancelInFlight: true
                )
            case .walletPersistence(.persisted(.failure(let error))):
                // record the error if we encounter one and restart the persistence
                environment.crashlyticsRecorder.error(error)
                return .concatenate(
                    .cancel(id: AppCancellations.WalletPersistenceId()),
                    Effect.send(.walletPersistence(.begin))
                )
            case .walletPersistence(.persisted(.success)):
                return .none
            case .none:
                return .none
            default:
                return .none
            }
        }
    }
}
