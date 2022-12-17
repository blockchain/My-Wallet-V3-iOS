// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainNamespace
import Combine
import DIKit
import ERC20Kit
import FeatureAppDomain
import FeatureAuthenticationDomain
import FeatureCryptoDomainDomain
import FeatureProductsDomain
import MoneyKit
import PlatformKit
import PlatformUIKit
import RxSwift
import RxToolKit
import ToolKit
import WalletPayloadKit

/// The announcement interactor cross all the preliminary data
/// that is required to display announcements to the user
final class AnnouncementInteractor: AnnouncementInteracting {

    // MARK: - Services

    /// Returns announcement preliminary data, according to which the relevant
    /// announcement will be displayed
    var preliminaryData: AnyPublisher<AnnouncementPreliminaryData, Error> {
        let assetRename = featureFetcher
            .fetch(for: .assetRenameAnnouncement, as: AssetRenameAnnouncementFeature.self)
            .eraseError()
            .flatMap { [enabledCurrenciesService, coincore] data
                -> AnyPublisher<AnnouncementPreliminaryData.AssetRename?, Error> in
                guard let cryptoCurrency = CryptoCurrency(
                    code: data.networkTicker,
                    enabledCurrenciesService: enabledCurrenciesService
                ) else {
                    return .just(nil)
                }
                return coincore[cryptoCurrency]
                    .accountGroup(filter: .allExcludingExchange)
                    .compactMap { $0 }
                    .flatMap(\.balance)
                    .map { balance in
                        AnnouncementPreliminaryData.AssetRename(
                            asset: cryptoCurrency,
                            oldTicker: data.oldTicker,
                            balance: balance
                        )
                    }
                    .eraseError()
                    .eraseToAnyPublisher()
            }
            .replaceError(with: nil)
            .eraseError()
            .eraseToAnyPublisher()

        let isSimpleBuyAvailable = supportedPairsInteractor.pairs
            .map { !$0.pairs.isEmpty }
            .take(1)
            .asSingle()
            .asPublisher()
            .replaceError(with: false)
            .eraseError()
            .eraseToAnyPublisher()

        let nabuUser = userService.user
            .eraseError()
            .eraseToAnyPublisher()
        let tiers = tiersService.tiers
            .eraseError()
            .eraseToAnyPublisher()
        let sddEligibility = tiersService.checkSimplifiedDueDiligenceEligibility()
            .eraseError()
            .eraseToAnyPublisher()
        let countries = infoService.countries

        let hasAnyWalletBalance = coincore
            .allAccounts(filter: .allExcludingExchange)
            .map(\.accounts)
            .eraseError()
            .flatMap { accounts -> AnyPublisher<Bool, Error> in
                accounts
                    .map { $0.isFunded.replaceError(with: false) }
                    .zip()
                    .map { values in
                        values.contains(true)
                    }
                    .eraseError()
            }
            .eraseToAnyPublisher()

        let authenticatorType = repository.authenticatorType
            .eraseError()
            .eraseToAnyPublisher()
        let newAsset = featureFetcher
            .fetch(for: .newAssetAnnouncement, as: String.self)
            .map { [enabledCurrenciesService] code -> CryptoCurrency? in
                CryptoCurrency(
                    code: code,
                    enabledCurrenciesService: enabledCurrenciesService
                )
            }
            .replaceError(with: nil)
            .eraseError()
            .eraseToAnyPublisher()

        let claimFreeDomainEligible = featureFetcher
            .fetch(for: .blockchainDomains, as: Bool.self)
            .flatMap { [claimEligibilityRepository] isEnabled in
                isEnabled ? claimEligibilityRepository.checkClaimEligibility() : .just(false)
            }
            .eraseError()
            .eraseToAnyPublisher()

        let majorProductBlocked = productsService
            .fetchProducts()
            .map { products in
                products
                    .first(where: {
                        $0.reasonNotEligible?.reason == .eu5Sanction
                        || $0.reasonNotEligible?.reason == .eu8Sanction
                    })?
                    .reasonNotEligible
            }
            .eraseError()
            .eraseToAnyPublisher()

        let cowboysAnnouncementsIsEnabled = app.publisher(
            for: blockchain.ux.onboarding.promotion.cowboys.announcements.is.enabled,
            as: Bool.self
        )
        .prefix(1)
        .map { $0.value ?? false }
        let userIsCowboysFan = app.publisher(
            for: blockchain.user.is.cowboy.fan,
            as: Bool.self
        )
        .prefix(1)
        .map { $0.value ?? false }

        let cowboysPromotionIsEnabled = cowboysAnnouncementsIsEnabled
            .zip(userIsCowboysFan)
            .map { $0 && $1 }
            .eraseError()
            .eraseToAnyPublisher()

        let walletAwarenessExperiment = exchangeExperimentsService.walletAwarenessResponse.eraseToAnyPublisher()

        let walletAwarenessCohort = app.publisher(
            for: blockchain.app.configuration.exchange.walletawareness.prompt.is.enabled,
            as: Bool.self
        )
        .map { $0.value ?? false }
        .zip(walletAwarenessExperiment)
        .map { $0 ? $1 : nil }
        .eraseError()
        .eraseToAnyPublisher()

        let isRecoveryPhraseVerified = recoveryPhraseStatusProvider.isRecoveryPhraseVerified
            .eraseError()
            .eraseToAnyPublisher()

        let preliminaryData: AnyPublisher<AnnouncementPreliminaryData, Error> = Publishers
            .Zip4(nabuUser, tiers, countries, authenticatorType)
            .zip(
                Publishers.Zip4(hasAnyWalletBalance, newAsset, assetRename, isSimpleBuyAvailable),
                Publishers.Zip4(sddEligibility, claimFreeDomainEligible, majorProductBlocked, cowboysPromotionIsEnabled),
                Publishers.Zip(isRecoveryPhraseVerified, walletAwarenessCohort)
            )
            .map { payload -> AnnouncementPreliminaryData in
                let (
                    nabuUser, tiers, countries, authenticatorType
                ) = payload.0
                let (
                    hasAnyWalletBalance, newAsset, assetRename, isSimpleBuyAvailable
                ) = payload.1
                let (
                    sddEligibility, claimFreeDomainEligible, majorProductBlocked, cowboysPromotionIsEnabled
                ) = payload.2
                let (
                    isRecoveryPhraseVerified,
                    walletAwareness
                ) = payload.3

                return AnnouncementPreliminaryData(
                    assetRename: assetRename,
                    authenticatorType: authenticatorType,
                    claimFreeDomainEligible: claimFreeDomainEligible,
                    countries: countries,
                    cowboysPromotionIsEnabled: cowboysPromotionIsEnabled,
                    hasAnyWalletBalance: hasAnyWalletBalance,
                    isRecoveryPhraseVerified: isRecoveryPhraseVerified,
                    isSDDEligible: sddEligibility,
                    majorProductBlocked: majorProductBlocked,
                    newAsset: newAsset,
                    simpleBuyIsAvailable: isSimpleBuyAvailable,
                    tiers: tiers,
                    user: nabuUser,
                    walletAwareness: walletAwareness
                )
            }
            .eraseToAnyPublisher()

        return isWalletInitialized()
            .flatMap { isInitialized -> AnyPublisher<AnnouncementPreliminaryData, Error> in
                guard isInitialized else {
                    return .failure(AnnouncementError.uninitializedWallet)
                }
                return preliminaryData
            }
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }

    // MARK: - Private properties

    private let beneficiariesService: BeneficiariesServiceAPI
    private let claimEligibilityRepository: ClaimEligibilityRepositoryAPI
    private let coincore: CoincoreAPI
    private let enabledCurrenciesService: EnabledCurrenciesServiceAPI
    private let featureFetcher: FeatureFetching
    private let infoService: GeneralInformationServiceAPI
    private let pendingOrderDetailsService: PendingOrderDetailsServiceAPI
    private let repository: AuthenticatorRepositoryAPI
    private let simpleBuyEligibilityService: EligibilityServiceAPI
    private let supportedPairsInteractor: SupportedPairsInteractorServiceAPI
    private let tiersService: KYCTiersServiceAPI
    private let userService: NabuUserServiceAPI
    private let productsService: FeatureProductsDomain.ProductsServiceAPI
    private let recoveryPhraseStatusProvider: RecoveryPhraseStatusProviding
    private let walletStateProvider: WalletStateProvider
    private let exchangeExperimentsService: ExchangeExperimentsServiceAPI

    // MARK: - Setup

    init(
        beneficiariesService: BeneficiariesServiceAPI = resolve(),
        claimEligibilityRepository: ClaimEligibilityRepositoryAPI = resolve(),
        coincore: CoincoreAPI = resolve(),
        enabledCurrenciesService: EnabledCurrenciesServiceAPI = resolve(),
        featureFetcher: FeatureFetching = resolve(),
        infoService: GeneralInformationServiceAPI = resolve(),
        pendingOrderDetailsService: PendingOrderDetailsServiceAPI = resolve(),
        productsService: FeatureProductsDomain.ProductsServiceAPI = resolve(),
        recoveryPhraseStatusProvider: RecoveryPhraseStatusProviding = resolve(),
        repository: AuthenticatorRepositoryAPI = resolve(),
        simpleBuyEligibilityService: EligibilityServiceAPI = resolve(),
        supportedPairsInteractor: SupportedPairsInteractorServiceAPI = resolve(),
        tiersService: KYCTiersServiceAPI = resolve(),
        userService: NabuUserServiceAPI = resolve(),
        walletStateProvider: WalletStateProvider = resolve(),
        exchangeExperimentsService: ExchangeExperimentsServiceAPI = resolve()
    ) {
        self.beneficiariesService = beneficiariesService
        self.claimEligibilityRepository = claimEligibilityRepository
        self.coincore = coincore
        self.enabledCurrenciesService = enabledCurrenciesService
        self.featureFetcher = featureFetcher
        self.infoService = infoService
        self.pendingOrderDetailsService = pendingOrderDetailsService
        self.productsService = productsService
        self.recoveryPhraseStatusProvider = recoveryPhraseStatusProvider
        self.repository = repository
        self.simpleBuyEligibilityService = simpleBuyEligibilityService
        self.supportedPairsInteractor = supportedPairsInteractor
        self.tiersService = tiersService
        self.userService = userService
        self.walletStateProvider = walletStateProvider
        self.exchangeExperimentsService = exchangeExperimentsService
    }

    private func isWalletInitialized() -> AnyPublisher<Bool, Never> {
        walletStateProvider.isWalletInitializedPublisher()
    }
}
