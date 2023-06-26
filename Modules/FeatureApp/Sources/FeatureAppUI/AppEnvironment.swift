// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import AnalyticsKit
import BlockchainNamespace
import ComposableArchitecture
import DelegatedSelfCustodyDomain
import ERC20Kit
import FeatureAppDomain
import FeatureAttributionDomain
import FeatureAuthenticationDomain
import FeatureAuthenticationUI
import FeatureCardPaymentDomain
import FeatureDebugUI
import FeatureOpenBankingDomain
import FeatureSettingsDomain
import MoneyKit
import NetworkKit
import ObservabilityKit
import PlatformKit
import PlatformUIKit
import RemoteNotificationsKit
import ToolKit
import UnifiedActivityDomain
import WalletPayloadKit

public struct AppEnvironment {
    var accountRecoveryService: AccountRecoveryServiceAPI
    var alertViewPresenter: AlertViewPresenterAPI
    var analyticsRecorder: AnalyticsEventRecorderAPI
    var app: AppProtocol
    var appStoreOpener: AppStoreOpening
    var assetsRemoteService: AssetsRemoteServiceAPI
    var backgroundAppHandler: BackgroundAppHandlerAPI
    var blockchainSettings: BlockchainSettingsAppAPI
    var blurEffectHandler: BlurVisualEffectHandlerAPI
    var buildVersionProvider: () -> String
    var cacheSuite: CacheSuite
    var cardService: CardServiceAPI
    var certificatePinner: CertificatePinnerAPI
    var coincore: CoincoreAPI
    var crashlyticsRecorder: Recording
    var credentialsStore: CredentialsStoreAPI
    var deeplinkAppHandler: AppDeeplinkHandlerAPI
    var deeplinkHandler: DeepLinkHandling
    var deeplinkRouter: DeepLinkRouting
    var delegatedCustodySubscriptionsService: DelegatedCustodySubscriptionsServiceAPI
    var deviceInfo: DeviceInfo
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
    var openBanking: OpenBanking
    var performanceTracing: PerformanceTracingServiceAPI
    var pushNotificationsRepository: PushNotificationsRepositoryAPI
    var reactiveWallet: ReactiveWalletAPI
    var recaptchaService: GoogleRecaptchaServiceAPI
    var remoteNotificationServiceContainer: RemoteNotificationServiceContaining
    var resetPasswordService: ResetPasswordServiceAPI
    var sharedContainer: SharedContainerUserDefaults
    var siftService: FeatureAuthenticationDomain.SiftServiceAPI
    var unifiedActivityService: UnifiedActivityPersistenceServiceAPI
    var urlSession: URLSession
    var walletPayloadService: WalletPayloadServiceAPI
    var walletRepoPersistence: WalletRepoPersistenceAPI
    var walletService: WalletService
    var walletStateProvider: WalletStateProvider

    public init(
        accountRecoveryService: AccountRecoveryServiceAPI,
        alertViewPresenter: AlertViewPresenterAPI,
        analyticsRecorder: AnalyticsEventRecorderAPI,
        app: AppProtocol,
        appStoreOpener: AppStoreOpening,
        assetsRemoteService: AssetsRemoteServiceAPI,
        backgroundAppHandler: BackgroundAppHandlerAPI,
        blockchainSettings: BlockchainSettingsAppAPI,
        blurEffectHandler: BlurVisualEffectHandlerAPI,
        buildVersionProvider: @escaping () -> String,
        cacheSuite: CacheSuite,
        cardService: CardServiceAPI,
        certificatePinner: CertificatePinnerAPI,
        coincore: CoincoreAPI,
        crashlyticsRecorder: Recording,
        credentialsStore: CredentialsStoreAPI,
        deeplinkAppHandler: AppDeeplinkHandlerAPI,
        deeplinkHandler: DeepLinkHandling,
        deeplinkRouter: DeepLinkRouting,
        delegatedCustodySubscriptionsService: DelegatedCustodySubscriptionsServiceAPI,
        deviceInfo: DeviceInfo,
        deviceVerificationService: DeviceVerificationServiceAPI,
        erc20CryptoAssetService: ERC20CryptoAssetServiceAPI,
        exchangeRepository: ExchangeAccountRepositoryAPI,
        externalAppOpener: ExternalAppOpener,
        fiatCurrencySettingsService: FiatCurrencySettingsServiceAPI,
        forgetWalletService: ForgetWalletService,
        legacyGuidRepository: LegacyGuidRepositoryAPI,
        legacySharedKeyRepository: LegacySharedKeyRepositoryAPI,
        loadingViewPresenter: LoadingViewPresenting,
        mainQueue: AnySchedulerOf<DispatchQueue>,
        mobileAuthSyncService: MobileAuthSyncServiceAPI,
        nabuUserService: NabuUserServiceAPI,
        openBanking: OpenBanking,
        performanceTracing: PerformanceTracingServiceAPI,
        pushNotificationsRepository: PushNotificationsRepositoryAPI,
        reactiveWallet: ReactiveWalletAPI,
        recaptchaService: GoogleRecaptchaServiceAPI,
        remoteNotificationServiceContainer: RemoteNotificationServiceContaining,
        resetPasswordService: ResetPasswordServiceAPI,
        sharedContainer: SharedContainerUserDefaults,
        siftService: FeatureAuthenticationDomain.SiftServiceAPI,
        unifiedActivityService: UnifiedActivityPersistenceServiceAPI,
        urlSession: URLSession,
        walletPayloadService: WalletPayloadServiceAPI,
        walletRepoPersistence: WalletRepoPersistenceAPI,
        walletService: WalletService,
        walletStateProvider: WalletStateProvider
    ) {
        self.accountRecoveryService = accountRecoveryService
        self.alertViewPresenter = alertViewPresenter
        self.analyticsRecorder = analyticsRecorder
        self.app = app
        self.appStoreOpener = appStoreOpener
        self.assetsRemoteService = assetsRemoteService
        self.backgroundAppHandler = backgroundAppHandler
        self.blockchainSettings = blockchainSettings
        self.blurEffectHandler = blurEffectHandler
        self.buildVersionProvider = buildVersionProvider
        self.cacheSuite = cacheSuite
        self.cardService = cardService
        self.certificatePinner = certificatePinner
        self.coincore = coincore
        self.crashlyticsRecorder = crashlyticsRecorder
        self.credentialsStore = credentialsStore
        self.deeplinkAppHandler = deeplinkAppHandler
        self.deeplinkHandler = deeplinkHandler
        self.deeplinkRouter = deeplinkRouter
        self.delegatedCustodySubscriptionsService = delegatedCustodySubscriptionsService
        self.deviceInfo = deviceInfo
        self.deviceVerificationService = deviceVerificationService
        self.erc20CryptoAssetService = erc20CryptoAssetService
        self.exchangeRepository = exchangeRepository
        self.externalAppOpener = externalAppOpener
        self.fiatCurrencySettingsService = fiatCurrencySettingsService
        self.forgetWalletService = forgetWalletService
        self.legacyGuidRepository = legacyGuidRepository
        self.legacySharedKeyRepository = legacySharedKeyRepository
        self.loadingViewPresenter = loadingViewPresenter
        self.mainQueue = mainQueue
        self.mobileAuthSyncService = mobileAuthSyncService
        self.nabuUserService = nabuUserService
        self.openBanking = openBanking
        self.performanceTracing = performanceTracing
        self.pushNotificationsRepository = pushNotificationsRepository
        self.reactiveWallet = reactiveWallet
        self.recaptchaService = recaptchaService
        self.remoteNotificationServiceContainer = remoteNotificationServiceContainer
        self.resetPasswordService = resetPasswordService
        self.sharedContainer = sharedContainer
        self.siftService = siftService
        self.unifiedActivityService = unifiedActivityService
        self.urlSession = urlSession
        self.walletPayloadService = walletPayloadService
        self.walletRepoPersistence = walletRepoPersistence
        self.walletService = walletService
        self.walletStateProvider = walletStateProvider
    }
}
