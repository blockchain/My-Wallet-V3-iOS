// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Blockchain
import BlockchainNamespace
import Combine
import FeatureDashboardDomain
import FeatureStakingDomain
import Foundation
import MoneyKit
import PlatformKit
import UnifiedActivityDomain

class CustodialActivityService: CustodialActivityServiceAPI {
    private let app: AppProtocol
    private let coincore: CoincoreAPI
    private let fiatCurrencyService: FiatCurrencySettingsServiceAPI
    private let ordersActivity: OrdersActivityServiceAPI
    private let swapActivity: SwapActivityServiceAPI
    private let buySellActivity: BuySellActivityItemEventServiceAPI
    private let stakingActivityService: EarnAccountService
    private let savingsActivityService: EarnAccountService
    private let activeRewardsActivityService: EarnAccountService

    init(
        app: AppProtocol,
        coincore: CoincoreAPI,
        fiatCurrencyService: FiatCurrencySettingsServiceAPI,
        ordersActivity: OrdersActivityServiceAPI,
        swapActivity: SwapActivityServiceAPI,
        buySellActivity: BuySellActivityItemEventServiceAPI,
        stakingActivityService: EarnAccountService,
        savingsActivityService: EarnAccountService,
        activeRewardsActivityService: EarnAccountService
    ) {
        self.app = app
        self.coincore = coincore
        self.fiatCurrencyService = fiatCurrencyService
        self.ordersActivity = ordersActivity
        self.swapActivity = swapActivity
        self.buySellActivity = buySellActivity
        self.stakingActivityService = stakingActivityService
        self.savingsActivityService = savingsActivityService
        self.activeRewardsActivityService = activeRewardsActivityService
    }

    func getActivity(fiatCurrency: FiatCurrency) -> AsyncStream<[ActivityEntry]> {
        let assets = coincore.cryptoAssets
        var streams: [AsyncStream<[ActivityEntry]>] = [
            AsyncStream(
                ordersActivity.activity(fiatCurrency: fiatCurrency).replaceError(with: [])
                    .mapEach(ActivityEntryAdapter.createEntry)
                    .prepend([]).values)
        ]

        for asset in assets {
            streams.append(
                AsyncStream(buySellActivity.buySellActivityEvents(cryptoCurrency: asset.asset).replaceError(with: []).mapEach { item in
                    ActivityEntryAdapter.createEntry(with: item)
                }.prepend([]).values)
            )

            streams.append(
                AsyncStream(ordersActivity.activity(cryptoCurrency: asset.asset).replaceError(with: []).mapEach { item in
                    ActivityEntryAdapter.createEntry(with: item)
                }.prepend([]).values)
            )

            streams.append(
                AsyncStream(stakingActivityService.activity(currency: asset.asset).replaceError(with: []).mapEach { item in
                    ActivityEntryAdapter.createEntry(with: item, type: .staking)
                }.prepend([]).values)
            )

            streams.append(
                AsyncStream(savingsActivityService.activity(currency: asset.asset).replaceError(with: []).mapEach { item in
                    ActivityEntryAdapter.createEntry(with: item, type: .saving)
                }.prepend([]).values)
            )

            streams.append(
                AsyncStream(activeRewardsActivityService.activity(currency: asset.asset).replaceError(with: []).mapEach { item in
                    ActivityEntryAdapter.createEntry(with: item, type: .activeRewards)
                }.prepend([]).values)
            )

            streams.append(
                AsyncStream(swapActivity.fetchActivity(cryptoCurrency: asset.asset, directions: [.internal]).replaceError(with: []).mapEach { item in
                    if item.pair.outputCurrencyType.isFiatCurrency {
                        let buySellActivityEntry = BuySellActivityItemEvent(swapActivityItemEvent: item)
                        return ActivityEntryAdapter.createEntry(
                            with: buySellActivityEntry,
                            originFromSwap: true,
                            networkFromSwap: item.pair.inputCurrencyType.code
                        )
                    }
                    return ActivityEntryAdapter.createEntry(with: item)
                }.prepend([]).values)
            )
        }

        return combineLatest(streams, bufferingPolicy: .unbounded)
            .map { items in
                items.flatMap({ $0 }).sorted(by: { $0.timestamp > $1.timestamp })
            }
            .eraseToStream()
    }

    func activity() -> AnyPublisher<[ActivityEntry], Never> {
        app.publisher(for: blockchain.user.currency.preferred.fiat.display.currency, as: FiatCurrency.self)
            .compactMap(\.value)
            .map { self.getActivity(fiatCurrency: $0).publisher() }
            .switchToLatest()
            .eraseToAnyPublisher()
    }
}

extension Publisher where Output: Sequence {

    func mapEach<T>(_ transform: @escaping (Output.Element) -> T) -> AnyPublisher<[T], Failure> {
        map { sequence in sequence.map(transform) }.eraseToAnyPublisher()
    }
}
