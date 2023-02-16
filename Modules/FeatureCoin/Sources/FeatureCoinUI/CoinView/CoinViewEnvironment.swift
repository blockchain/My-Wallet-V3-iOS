// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainNamespace
import Combine
import ComposableArchitecture
import ComposableArchitectureExtensions
import FeatureCoinDomain
import Foundation

public struct CoinViewEnvironment: BlockchainNamespaceAppEnvironment {

    public let app: AppProtocol
    public let mainQueue: AnySchedulerOf<DispatchQueue>
    public let kycStatusProvider: () -> AnyPublisher<KYCStatus, Never>
    public let accountsProvider: () -> AnyPublisher<[Account], Error>
    public let recurringBuyProvider: () -> AnyPublisher<[RecurringBuy], Error>
    public let cancelRecurringBuyService: (String) -> AnyPublisher<Void, Error>
    public let assetInformationService: AssetInformationService
    public let historicalPriceService: HistoricalPriceService
    public let earnRatesRepository: RatesRepositoryAPI
    public let explainerService: ExplainerService
    public let dismiss: () -> Void

    private let watchlistService: WatchlistService

    public init(
        app: AppProtocol,
        mainQueue: AnySchedulerOf<DispatchQueue> = .main,
        kycStatusProvider: @escaping () -> AnyPublisher<KYCStatus, Never>,
        accountsProvider: @escaping () -> AnyPublisher<[Account], Error>,
        recurringBuyProvider: @escaping () -> AnyPublisher<[RecurringBuy], Error>,
        cancelRecurringBuyService: @escaping (String) -> AnyPublisher<Void, Error>,
        assetInformationService: AssetInformationService,
        historicalPriceService: HistoricalPriceService,
        earnRatesRepository: RatesRepositoryAPI,
        explainerService: ExplainerService,
        watchlistService: WatchlistService,
        dismiss: @escaping () -> Void
    ) {
        self.app = app
        self.mainQueue = mainQueue
        self.kycStatusProvider = kycStatusProvider
        self.accountsProvider = accountsProvider
        self.recurringBuyProvider = recurringBuyProvider
        self.cancelRecurringBuyService = cancelRecurringBuyService
        self.assetInformationService = assetInformationService
        self.historicalPriceService = historicalPriceService
        self.earnRatesRepository = earnRatesRepository
        self.explainerService = explainerService
        self.watchlistService = watchlistService
        self.dismiss = dismiss
    }
}

extension CoinViewEnvironment {
    static var preview: Self = .init(
        app: App.preview,
        kycStatusProvider: { .empty() },
        accountsProvider: { .empty() },
        recurringBuyProvider: { .empty() },
        cancelRecurringBuyService: { _ in .empty() },
        assetInformationService: .preview,
        historicalPriceService: .preview,
        earnRatesRepository: PreviewRatesRepository(.just(EarnRates(stakingRate: 5 / 3, interestRate: 5 / 3, activeRewardsRate: 8))),
        explainerService: .preview,
        watchlistService: .preview,
        dismiss: {}
    )

    static var previewEmpty: Self = .init(
        app: App.preview,
        kycStatusProvider: { .empty() },
        accountsProvider: { .empty() },
        recurringBuyProvider: { .empty() },
        cancelRecurringBuyService: { _ in .empty() },
        assetInformationService: .previewEmpty,
        historicalPriceService: .previewEmpty,
        earnRatesRepository: PreviewRatesRepository(),
        explainerService: .preview,
        watchlistService: .previewEmpty,
        dismiss: {}
    )
}
