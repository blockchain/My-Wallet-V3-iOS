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

final class CustodialActivityService: CustodialActivityServiceAPI {
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

    private func getActivity(fiatCurrency: FiatCurrency) -> AnyPublisher<[ActivityEntry], Never> {
        let assets = coincore.cryptoAssets.filter { asset in
            asset.asset.assetModel.supports(product: .custodialWalletBalance) ||
            asset.asset.assetModel.supports(product: .interestBalance) ||
            asset.asset.assetModel.supports(product: .activeRewardsBalance) ||
            asset.asset.assetModel.supports(product: .staking)
        }
        var streams: [(String, AnyPublisher<[ActivityEntry], Never>)] = [
            (
                "orders",
                ordersActivity
                    .allActivity(displayCurrency: fiatCurrency)
                    .replaceError(with: [])
                    .mapEach { item in ActivityEntryAdapter.createEntry(with: item) }
            ),
            (
                "buy & sell",
                buySellActivity
                    .buySellActivityEvents(cryptoCurrency: nil)
                    .replaceError(with: [])
                    .mapEach { item in
                        ActivityEntryAdapter.createEntry(with: item)
                    }
            )
        ]

        if assets.contains(where: { $0.asset.supports(product: .staking) }) {
            streams.append(
                (
                    "staking",
                    stakingActivityService
                        .activity(currency: nil)
                        .replaceError(with: [])
                        .mapEach { item in ActivityEntryAdapter.createEntry(with: item, type: .staking) }
                )
            )
        }
        if assets.contains(where: { $0.asset.supports(product: .interestBalance) }) {
            streams.append(
                (
                    "savings",
                    savingsActivityService
                        .activity(currency: nil)
                        .replaceError(with: [])
                        .mapEach { item in ActivityEntryAdapter.createEntry(with: item, type: .saving) }
                )
            )
        }

        if assets.contains(where: { $0.asset.supports(product: .activeRewardsBalance) }) {
            streams.append(
                (
                    "active rewards",
                    activeRewardsActivityService
                        .activity(currency: nil)
                        .replaceError(with: [])
                        .mapEach { item in ActivityEntryAdapter.createEntry(with: item, type: .activeRewards) }
                )
            )
        }

        for asset in assets {
            streams.append(
                ("swap \(asset.asset)", swapActivity.fetchActivity(cryptoCurrency: asset.asset, directions: [.internal]).replaceError(with: []).mapEach { item in
                    if item.pair.outputCurrencyType.isFiatCurrency {
                        let buySellActivityEntry = BuySellActivityItemEvent(swapActivityItemEvent: item)
                        return ActivityEntryAdapter.createEntry(
                            with: buySellActivityEntry,
                            originFromSwap: true,
                            networkFromSwap: item.pair.inputCurrencyType.code
                        )
                    }
                    return ActivityEntryAdapter.createEntry(with: item)
                })
            )
        }

        return streams
            .map { _, stream in stream.prepend([]) }
            .combineLatest()
            .map { items in
                items.flatMap { $0 }.sorted(by: { $0.timestamp > $1.timestamp })
            }
            .eraseToAnyPublisher()
    }

    func activity() -> AnyPublisher<[ActivityEntry], Never> {
        app.publisher(for: blockchain.user.currency.preferred.fiat.display.currency, as: FiatCurrency.self)
            .compactMap(\.value)
            .map { self.getActivity(fiatCurrency: $0) }
            .switchToLatest()
            .eraseToAnyPublisher()
    }
}

extension Publisher where Output: Sequence {

    func mapEach<T>(_ transform: @escaping (Output.Element) -> T) -> AnyPublisher<[T], Failure> {
        map { sequence in sequence.map(transform) }.eraseToAnyPublisher()
    }
}

extension Publisher {

    func recordFailure(to app: AppProtocol, _ file: String = #file, _ line: Int = #line) -> AnyPublisher<Output, Failure> {
        `catch` { error in
            app.post(error: error, file: file, line: line)
            return Fail(outputType: Output.self, failure: error)
        }
        .eraseToAnyPublisher()
    }
}
