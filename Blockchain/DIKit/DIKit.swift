// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import AnalyticsKit
import BitcoinCashKit
import BitcoinChainKit
import BitcoinKit
import BlockchainNamespace
import Combine
import DIKit
import ERC20Kit
import EthereumKit
import FeatureAppDomain
import FeatureAppUI
import FeatureAttributionData
import FeatureAttributionDomain
import FeatureAuthenticationData
import FeatureAuthenticationDomain
import FeatureBackupRecoveryPhraseData
import FeatureBackupRecoveryPhraseDomain
import FeatureBackupRecoveryPhraseUI
import FeatureCoinData
import FeatureCoinDomain
import FeatureCryptoDomainData
import FeatureCryptoDomainDomain
import FeatureDashboardData
import FeatureDashboardDomain
import FeatureDebugUI
import FeatureKYCDomain
import FeatureKYCUI
import FeatureNFTData
import FeatureNFTDomain
import FeatureNotificationPreferencesData
import FeatureNotificationPreferencesDomain
import FeatureOnboardingUI
import FeatureOpenBankingData
import FeatureOpenBankingDomain
import FeatureOpenBankingUI
import FeaturePlaidData
import FeaturePlaidDomain
import FeaturePlaidUI
import FeatureProductsData
import FeatureProductsDomain
import FeatureReferralData
import FeatureReferralDomain
import FeatureSettingsDomain
import FeatureTopMoversCryptoDomain
import FeatureTransactionDomain
import FeatureTransactionUI
import FeatureUserDeletionData
import FeatureUserDeletionDomain
import FeatureUserTagSyncData
import FeatureUserTagSyncDomain
import FeatureWalletConnectDomain
import FirebaseDynamicLinks
import FirebaseMessaging
import FirebaseRemoteConfig
import MoneyKit
import NetworkKit
import ObservabilityKit
import PermissionsKit
import PlatformDataKit
import PlatformKit
import PlatformUIKit
import RecaptchaEnterprise
import RemoteNotificationsKit
import RxToolKit
import StellarKit
import ToolKit
import UIKit
import WalletPayloadKit

import FeatureVGSData
import VGSCollectSDK

// MARK: - Settings Dependencies

extension UIApplication: PlatformKit.AppStoreOpening {}

// MARK: - Blockchain Module

extension DependencyContainer {

    static var blockchainApp = module {

        factory { NavigationRouter() as NavigationRouterAPI }

        factory { DeepLinkHandler() as DeepLinkHandling }

        factory { DeepLinkRouter() as DeepLinkRouting }

        factory { UIDevice.current as DeviceInfo }

        factory { PerformanceTracing.live as PerformanceTracingServiceAPI }

        single { () -> LogMessageServiceAPI in
            let loggers = LogMessageTracing.provideLoggers()
            return LogMessageTracing.live(
                loggers: loggers
            )
        }

        factory { CrashlyticsRecorder() as MessageRecording }

        factory { CrashlyticsRecorder() as ErrorRecording }

        factory(tag: "CrashlyticsRecorder") { CrashlyticsRecorder() as Recording }

        factory { ExchangeClient() as ExchangeClientAPI }

        factory { SiftService() }

        factory { () -> FeatureAuthenticationDomain.SiftServiceAPI in
            let service: SiftService = DIKit.resolve()
            return service as FeatureAuthenticationDomain.SiftServiceAPI
        }

        factory { () -> PlatformKit.SiftServiceAPI in
            let service: SiftService = DIKit.resolve()
            return service as PlatformKit.SiftServiceAPI
        }

        single { () -> AppDeeplinkHandlerAPI in
            let appSettings: BlockchainSettingsAppAPI = DIKit.resolve()
            let isPinSet: () -> Bool = { appSettings.isPinSet }
            let deeplinkHandler = CoreDeeplinkHandler(
                markBitpayUrl: { BitpayService.shared.content = $0 },
                isBitPayURL: BitPayLinkRouter.isBitPayURL,
                isPinSet: isPinSet
            )
            let blockchainHandler = BlockchainLinksHandler(
                validHosts: BlockchainLinks.validLinks,
                validRoutes: BlockchainLinks.validRoutes
            )
            return AppDeeplinkHandler(
                deeplinkHandler: deeplinkHandler,
                blockchainHandler: blockchainHandler,
                firebaseHandler: FirebaseDeeplinkHandler(dynamicLinks: DynamicLinks.dynamicLinks())
            )
        }

        factory { UIApplication.shared as AppStoreOpening }

        // MARK: - AppCoordinator

        single { LoggedInDependencyBridge() as LoggedInDependencyBridgeAPI }

        factory { () -> TabSwapping in
            let bridge: LoggedInDependencyBridgeAPI = DIKit.resolve()
            return bridge.resolveTabSwapping() as TabSwapping
        }

        factory { () -> AppCoordinating in
            let bridge: LoggedInDependencyBridgeAPI = DIKit.resolve()
            return bridge.resolveAppCoordinating() as AppCoordinating
        }

        factory { () -> BackupFlowStarterAPI in
            let bridge: LoggedInDependencyBridgeAPI = DIKit.resolve()
            return bridge.resolveBackupFlowStarter() as BackupFlowStarterAPI
        }

        factory { () -> CashIdentityVerificationAnnouncementRouting in
            let bridge: LoggedInDependencyBridgeAPI = DIKit.resolve()
            return bridge.resolveCashIdentityVerificationAnnouncementRouting()
            as CashIdentityVerificationAnnouncementRouting
        }

        factory { () -> SettingsStarterAPI in
            let bridge: LoggedInDependencyBridgeAPI = DIKit.resolve()
            return bridge.resolveSettingsStarter() as SettingsStarterAPI
        }

        factory { () -> DrawerRouting in
            let bridge: LoggedInDependencyBridgeAPI = DIKit.resolve()
            return bridge.resolveDrawerRouting() as DrawerRouting
        }

        factory { () -> QRCodeScannerRouting in
            let bridge: LoggedInDependencyBridgeAPI = DIKit.resolve()
            return bridge.resolveQRCodeScannerRouting() as QRCodeScannerRouting
        }

        // MARK: - BlockchainSettingsAppAPI

        factory { () -> AppSettingsAuthenticating in
            let app: BlockchainSettingsAppAPI = DIKit.resolve()
            return app as AppSettingsAuthenticating
        }

        factory { () -> AppSettingsSecureChannel in
            let app: BlockchainSettingsAppAPI = DIKit.resolve()
            return app as AppSettingsSecureChannel
        }

        factory { () -> RecoveryPhraseVerifyingServiceAPI in
            let backupService: VerifyMnemonicBackupServiceAPI = DIKit.resolve()
            let mnemonicComponentsProviding: MnemonicComponentsProviding = DIKit.resolve()
            return RecoveryPhraseVerifyingService(
                verifyMnemonicBackupService: backupService,
                mnemonicComponentsProviding: mnemonicComponentsProviding
            )
        }

        factory { () -> PermissionSettingsAPI in
            let app: BlockchainSettingsAppAPI = DIKit.resolve()
            return app
        }

        // MARK: - UserInformationServiceProvider

        // user state can be observed by multiple objects and the state is made up of multiple components
        // so, better have a single instance of this object.
        single { () -> UserAdapterAPI in
            UserAdapter(
                kycTiersService: DIKit.resolve(),
                paymentMethodsService: DIKit.resolve(),
                productsService: DIKit.resolve(),
                ordersService: DIKit.resolve()
            )
        }

        factory { () -> SettingsServiceAPI in
            let completeSettingsService: CompleteSettingsServiceAPI = DIKit.resolve()
            return completeSettingsService
        }

        factory { () -> SettingsServiceCombineAPI in
            let settings: SettingsServiceAPI = DIKit.resolve()
            return settings as SettingsServiceCombineAPI
        }

        factory { () -> FiatCurrencyServiceAPI in
            let completeSettingsService: CompleteSettingsServiceAPI = DIKit.resolve()
            return completeSettingsService
        }

        factory { () -> SupportedFiatCurrenciesServiceAPI in
            let completeSettingsService: CompleteSettingsServiceAPI = DIKit.resolve()
            return completeSettingsService
        }

        factory { () -> MobileSettingsServiceAPI in
            let completeSettingsService: CompleteSettingsServiceAPI = DIKit.resolve()
            return completeSettingsService
        }

        // MARK: - BlockchainDataRepository

        factory { BlockchainDataRepository() as DataRepositoryAPI }

        factory { () -> WalletMnemonicProvider in
            let mnemonicAccess: MnemonicAccessAPI = DIKit.resolve()
            return {
                mnemonicAccess.mnemonic
                    .eraseError()
                    .map(BitcoinChainKit.Mnemonic.init)
                    .eraseToAnyPublisher()
            }
        }

        // MARK: Remote Notifications

        factory { ExternalNotificationServiceProvider() as ExternalNotificationProviding }

        factory { () -> RemoteNotificationEmitting in
            let relay: RemoteNotificationRelay = DIKit.resolve()
            return relay as RemoteNotificationEmitting
        }

        factory { () -> RemoteNotificationBackgroundReceiving in
            let relay: RemoteNotificationRelay = DIKit.resolve()
            return relay as RemoteNotificationBackgroundReceiving
        }

        single {
            RemoteNotificationRelay(
                app: DIKit.resolve(),
                cacheSuite: DIKit.resolve(),
                userNotificationCenter: UNUserNotificationCenter.current(),
                messagingService: Messaging.messaging(),
                secureChannelNotificationRelay: DIKit.resolve()
            )
        }

        // MARK: Helpers

        factory { UIApplication.shared as ExternalAppOpener }
        factory { UIApplication.shared as URLOpener }
        factory { UIApplication.shared as OpenURLProtocol }

        // MARK: KYC Module

        factory { () -> FeatureKYCDomain.EmailVerificationAPI in
            EmailVerificationAdapter(settingsService: DIKit.resolve())
        }

        // MARK: Onboarding Module

        // this must be kept in memory because of how PlatformUIKit.Router works, otherwise the flow crashes.
        single { () -> FeatureOnboardingUI.OnboardingRouterAPI in
            FeatureOnboardingUI.OnboardingRouter()
        }

        factory { () -> FeatureOnboardingUI.KYCRouterAPI in
            KYCAdapter()
        }

        // MARK: FeatureAuthentication Module

        single { GoogleRecaptchaService(siteKey: AuthenticationKeys.googleRecaptchaSiteKey) as GoogleRecaptchaServiceAPI }

        // MARK: Analytics

        single { () -> AnalyticsKit.GuidRepositoryAPI in
            AnalyticsKitGuidRepository(
                keychainItemWrapper: DIKit.resolve()
            )
        }

        single { () -> AnalyticsEventRecorderAPI in
            let firebaseAnalyticsServiceProvider = FirebaseAnalyticsServiceProvider()
            let userAgent = UserAgentProvider().userAgent ?? ""
            let nabuAnalyticsServiceProvider = NabuAnalyticsProvider(
                platform: .wallet,
                basePath: BlockchainAPI.shared.apiUrl,
                userAgent: userAgent,
                tokenProvider: DIKit.resolve(),
                guidProvider: DIKit.resolve(),
                traitRepository: DIKit.resolve()
            )
            return AnalyticsEventRecorder(analyticsServiceProviders: [
                firebaseAnalyticsServiceProvider,
                nabuAnalyticsServiceProvider
            ])
        }

        single {
            AppAnalyticsTraitRepository(app: DIKit.resolve())
        }

        single { () -> TraitRepositoryAPI in
            let analytics: AppAnalyticsTraitRepository = DIKit.resolve()
            return analytics as TraitRepositoryAPI
        }

        // MARK: Open Banking

        single { () -> OpenBanking in
            let builder: NetworkKit.RequestBuilder = DIKit.resolve(tag: DIKitContext.retail)
            let adapter: NetworkKit.NetworkAdapterAPI = DIKit.resolve(tag: DIKitContext.retail)
            let client = OpenBankingClient(
                app: DIKit.resolve(),
                requestBuilder: builder,
                network: adapter.network
            )
            return OpenBanking(app: DIKit.resolve(), banking: client)
        }

        // MARK: FeaturePlaid

        factory { () -> PlaidRepositoryAPI in
            let adapter: NetworkKit.NetworkAdapterAPI = DIKit.resolve(tag: DIKitContext.retail)
            let builder: NetworkKit.RequestBuilder = DIKit.resolve(tag: DIKitContext.retail)
            let client = PlaidClient(
                networkAdapter: adapter,
                requestBuilder: builder
            )
            return PlaidRepository(client: client)
        }

        factory { () -> VGSClientAPI in
            let adapter: NetworkKit.NetworkAdapterAPI = DIKit.resolve(tag: DIKitContext.retail)
            let builder: NetworkKit.RequestBuilder = DIKit.resolve(tag: DIKitContext.retail)
            return VGSClient(
                networkAdapter: adapter,
                requestBuilder: builder
            )
        }

        // MARK: Coin View

        single { () -> HistoricalPriceClientAPI in
            let requestBuilder: NetworkKit.RequestBuilder = DIKit.resolve()
            let networkAdapter: NetworkKit.NetworkAdapterAPI = DIKit.resolve()
            return HistoricalPriceClient(
                request: requestBuilder,
                network: networkAdapter
            )
        }

        single { () -> HistoricalPriceRepositoryAPI in
            HistoricalPriceRepository(DIKit.resolve(), prices: DIKit.resolve())
        }

        single { () -> RatesClientAPI in
            let requestBuilder: NetworkKit.RequestBuilder = DIKit.resolve(tag: DIKitContext.retail)
            let networkAdapter: NetworkKit.NetworkAdapterAPI = DIKit.resolve(tag: DIKitContext.retail)
            return RatesClient(
                networkAdapter: networkAdapter,
                requestBuilder: requestBuilder
            )
        }

        single { () -> RatesRepositoryAPI in
            RatesRepository(DIKit.resolve())
        }

        single { () -> WatchlistRepositoryAPI in
            WatchlistRepository(
                WatchlistClient(
                    networkAdapter: DIKit.resolve(tag: DIKitContext.retail),
                    requestBuilder: DIKit.resolve(tag: DIKitContext.retail)
                )
            )
        }

        // MARK: Feature Product

        single { () -> ProductsRepositoryAPI in
            ProductsRepository(
                client: ProductsAPIClient(
                    networkAdapter: DIKit.resolve(tag: DIKitContext.retail),
                    requestBuilder: DIKit.resolve(tag: DIKitContext.retail)
                )
            )
        }

        factory { () -> FeatureProductsDomain.ProductsServiceAPI in
            ProductsService(
                repository: DIKit.resolve()
            )
        }

        // MARK: Feature NFT

        factory { () -> FeatureNFTDomain.AssetProviderServiceAPI in
            let repository: EthereumWalletAccountRepositoryAPI = DIKit.resolve()
            let publisher = repository
                .defaultAccount
                .map(\.publicKey)
                .eraseError()
            return AssetProviderService(
                repository: AssetProviderRepository(
                    client: FeatureNFTData.APIClient(
                        retailNetworkAdapter: DIKit.resolve(tag: DIKitContext.retail),
                        defaultNetworkAdapter: DIKit.resolve(),
                        retailRequestBuilder: DIKit.resolve(tag: DIKitContext.retail),
                        defaultRequestBuilder: DIKit.resolve()
                    )
                ),
                ethereumWalletAddressPublisher: publisher
            )
        }

        factory { () -> FeatureNFTDomain.ViewWaitlistRegistrationRepositoryAPI in
            let emailService: EmailSettingsServiceAPI = DIKit.resolve()
            let publisher = emailService
                .emailPublisher
                .eraseError()
            return ViewWaitlistRegistrationRepository(
                client: FeatureNFTData.APIClient(
                    retailNetworkAdapter: DIKit.resolve(tag: DIKitContext.retail),
                    defaultNetworkAdapter: DIKit.resolve(),
                    retailRequestBuilder: DIKit.resolve(tag: DIKitContext.retail),
                    defaultRequestBuilder: DIKit.resolve()
                ),
                emailAddressPublisher: publisher
            )
        }

        // MARK: Feature Crypto Domain

        factory { () -> SearchDomainRepositoryAPI in
            let builder: NetworkKit.RequestBuilder = DIKit.resolve()
            let adapter: NetworkKit.NetworkAdapterAPI = DIKit.resolve()
            let client = SearchDomainClient(networkAdapter: adapter, requestBuilder: builder)
            return SearchDomainRepository(apiClient: client)
        }

        factory { () -> OrderDomainRepositoryAPI in
            let builder: NetworkKit.RequestBuilder = DIKit.resolve(tag: DIKitContext.retail)
            let adapter: NetworkKit.NetworkAdapterAPI = DIKit.resolve(tag: DIKitContext.retail)
            let client = OrderDomainClient(networkAdapter: adapter, requestBuilder: builder)
            return OrderDomainRepository(apiClient: client)
        }

        factory { () -> ClaimEligibilityRepositoryAPI in
            let builder: NetworkKit.RequestBuilder = DIKit.resolve(tag: DIKitContext.retail)
            let adapter: NetworkKit.NetworkAdapterAPI = DIKit.resolve(tag: DIKitContext.retail)
            let client = ClaimEligibilityClient(networkAdapter: adapter, requestBuilder: builder)
            return ClaimEligibilityRepository(apiClient: client)
        }

        // MARK: Feature Notification Preferences

        factory { () -> NotificationPreferencesRepositoryAPI in
            let builder: NetworkKit.RequestBuilder = DIKit.resolve(tag: DIKitContext.retail)
            let adapter: NetworkKit.NetworkAdapterAPI = DIKit.resolve(tag: DIKitContext.retail)
            let client = NotificationPreferencesClient(networkAdapter: adapter, requestBuilder: builder)
            return NotificationPreferencesRepository(client: client)
        }

        // MARK: Feature Referrals

        factory { () -> ReferralRepositoryAPI in
            let builder: NetworkKit.RequestBuilder = DIKit.resolve(tag: DIKitContext.retail)
            let adapter: NetworkKit.NetworkAdapterAPI = DIKit.resolve(tag: DIKitContext.retail)
            let client = ReferralClientClient(networkAdapter: adapter, requestBuilder: builder)
            return ReferralRepository(client: client)
        }

        factory { () -> ReferralServiceAPI in
            ReferralService(
                app: DIKit.resolve(),
                repository: DIKit.resolve()
            )
        }

        // MARK: Feature Attribution

        single { () -> AttributionServiceAPI in
            let errorRecorder = CrashlyticsRecorder()
            let skAdNetworkService = SkAdNetworkService(errorRecorder: errorRecorder)
            let builder: NetworkKit.RequestBuilder = DIKit.resolve(tag: DIKitContext.websocket)
            let adapter: NetworkKit.NetworkAdapterAPI = DIKit.resolve(tag: DIKitContext.retail)
            let attributionClient = AttributionClient(
                networkAdapter: adapter,
                requestBuilder: builder
            )
            let attributionRepository = AttributionRepository(with: attributionClient)

            return AttributionService(
                app: DIKit.resolve(),
                skAdNetworkService: skAdNetworkService,
                attributionRepository: attributionRepository
            ) as AttributionServiceAPI
        }

        // MARK: User Deletion

        factory { () -> UserDeletionRepositoryAPI in
            let builder: NetworkKit.RequestBuilder = DIKit.resolve(tag: DIKitContext.retail)
            let adapter: NetworkKit.NetworkAdapterAPI = DIKit.resolve(tag: DIKitContext.retail)
            let client = UserDeletionClient(networkAdapter: adapter, requestBuilder: builder)
            return UserDeletionRepository(client: client)
        }

        // MARK: Native Wallet Debugging

        single {
            NativeWalletLogger() as NativeWalletLoggerAPI
        }

        // MARK: Pulse Network Debugging

        single {
            PulseNetworkDebugLogger() as NetworkDebugLogger
        }

        single {
            PulseNetworkDebugScreenProvider() as NetworkDebugScreenProvider
        }

        single { app }

        single { () -> RequestBuilderQueryParameters in
            let app: AppProtocol = DIKit.resolve()
            return RequestBuilderQueryParameters(
                app.publisher(
                    for: BlockchainNamespace.blockchain.app.configuration.localized.error.override,
                    as: String.self
                )
                .map { result -> [URLQueryItem]? in
                    try? [URLQueryItem(name: "localisedError", value: result.get().nilIfEmpty)]
                }
                    .replaceError(with: [])
            )
        }

        factory(tag: NetworkKit.HTTPHeaderTag) { () -> () -> HTTPHeaders in
            let app: AppProtocol = DIKit.resolve()
            return {
                app.state.result(for: blockchain.api.nabu.gateway.generate.session.headers)
                    .decode(HTTPHeaders.self)
                    .value
                    .or([:])
            }
        }

        factory { () -> LegacySharedKeyRepositoryAPI in
            LegacySharedKeyRepository(
                keychainItemWrapper: DIKit.resolve()
            )
        }

        factory { () -> LegacyGuidRepositoryAPI in
            LegacyGuidRepository(
                keychainItemWrapper: DIKit.resolve()
            )
        }

        factory { LegacyForgetWallet() as LegacyForgetWalletAPI }

        // MARK: Feature Backup Seed Phrase

        factory { RecoveryPhraseExposureAlertClient() as RecoveryPhraseExposureAlertClientAPI }

        factory { RecoveryPhraseBackupClient() as RecoveryPhraseBackupClientAPI }

        // MARK: - Repositories

        factory { RecoveryPhraseRepository() as RecoveryPhraseRepositoryAPI }

        factory { () -> RecoveryPhraseStatusProviding in
            RecoveryPhraseStatusProvider(mnemonicVerificationStatusProvider: DIKit.resolve())
        }

        factory { () -> CloudBackupConfiguring in
            CloudBackupService(defaults: DIKit.resolve())
        }

        factory { () -> RecoveryPhraseBackupRouterAPI in
            RecoveryPhraseBackupRouter(
                topViewController: DIKit.resolve(),
                recoveryStatusProviding: DIKit.resolve()
            ) as RecoveryPhraseBackupRouterAPI
        }

        factory { () -> UserTagServiceAPI in
            let requestBuilder: NetworkKit.RequestBuilder = DIKit.resolve(tag: DIKitContext.retail)
            let networkAdapter: NetworkKit.NetworkAdapterAPI = DIKit.resolve(tag: DIKitContext.retail)

            return UserTagService(with: UserTagClient(
                networkAdapter: networkAdapter,
                requestBuilder: requestBuilder
            )
            ) as UserTagServiceAPI
        }

        factory { () -> TopMoversServiceAPI in
            TopMoversService(
                app: DIKit.resolve()
            ) as TopMoversServiceAPI
        }
    }
}

struct LegacySharedKeyRepository: LegacySharedKeyRepositoryAPI {

    private let keychainItemWrapper: KeychainItemWrapping

    init(keychainItemWrapper: KeychainItemWrapping) {
        self.keychainItemWrapper = keychainItemWrapper
    }

    var sharedKey: AnyPublisher<String?, Never> {
        Deferred { [keychainItemWrapper] in
            Future { promise in
                promise(.success(keychainItemWrapper.sharedKey()))
            }
        }
        .eraseToAnyPublisher()
    }

    var directSharedKey: String? {
        keychainItemWrapper.sharedKey()
    }

    func set(sharedKey: String?) -> AnyPublisher<Void, Never> {
        Deferred { [keychainItemWrapper] in
            Future { promise in
                promise(.success(keychainItemWrapper.setSharedKey(sharedKey)))
            }
        }
        .eraseToAnyPublisher()
    }

    func directSet(sharedKey: String?) {
        keychainItemWrapper.setSharedKey(sharedKey)
    }
}

struct AnalyticsKitGuidRepository: AnalyticsKit.GuidRepositoryAPI {

    private let keychainItemWrapper: KeychainItemWrapping

    init(keychainItemWrapper: KeychainItemWrapping) {
        self.keychainItemWrapper = keychainItemWrapper
    }

    var guid: String? {
        keychainItemWrapper.guid()
    }
}

struct LegacyGuidRepository: LegacyGuidRepositoryAPI {

    private let keychainItemWrapper: KeychainItemWrapping

    init(keychainItemWrapper: KeychainItemWrapping) {
        self.keychainItemWrapper = keychainItemWrapper
    }

    var guid: AnyPublisher<String?, Never> {
        Deferred { [keychainItemWrapper] in
            Future { promise in
                promise(.success(keychainItemWrapper.guid()))
            }
        }
        .eraseToAnyPublisher()
    }

    var directGuid: String? {
        keychainItemWrapper.guid()
    }

    func set(guid: String?) -> AnyPublisher<Void, Never> {
        Deferred { [keychainItemWrapper] in
            Future { promise in
                promise(.success(keychainItemWrapper.setGuid(guid)))
            }
        }
        .eraseToAnyPublisher()
    }

    func directSet(guid: String?) {
        keychainItemWrapper.setGuid(guid)
    }
}

struct LegacyForgetWallet: LegacyForgetWalletAPI {

    private let appSettingsAuthenticating: AppSettingsAuthenticating = DIKit.resolve()
    private let legacySharedKeyRepository: LegacySharedKeyRepositoryAPI = DIKit.resolve()
    private let legacyGuidRepository: LegacyGuidRepositoryAPI = DIKit.resolve()

    func forgetWallet() {
        appSettingsAuthenticating.clearPin()

        // Clear all cookies (important one is the server session id SID)
        HTTPCookieStorage.shared.deleteAllCookies()

        legacyGuidRepository.directSet(guid: nil)
        legacySharedKeyRepository.directSet(sharedKey: nil)

        appSettingsAuthenticating.set(biometryEnabled: false)
    }
}

extension UIApplication: OpenURLProtocol {}
