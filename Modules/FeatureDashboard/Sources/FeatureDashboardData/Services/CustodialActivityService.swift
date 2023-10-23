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
        let assets = coincore.cryptoAssets.filter { asset in
            asset.asset.assetModel.supports(product: .custodialWalletBalance) ||
            asset.asset.assetModel.supports(product: .interestBalance) ||
            asset.asset.assetModel.supports(product: .activeRewardsBalance) ||
            asset.asset.assetModel.supports(product: .staking)
        }
        var streams: [(String, AnyPublisher<[ActivityEntry], Never>)] = [
            (
                "fiat \(fiatCurrency)",
                ordersActivity.activity(fiatCurrency: fiatCurrency).replaceError(with: [])
                .mapEach(ActivityEntryAdapter.createEntry)
            )
        ]

        for asset in assets {
            streams.append(
                ("buy & sell \(asset.asset)", buySellActivity.buySellActivityEvents(cryptoCurrency: asset.asset).replaceError(with: []).mapEach { item in
                    ActivityEntryAdapter.createEntry(with: item)
                })
            )

            streams.append(
                ("orders \(asset.asset)", ordersActivity.activity(cryptoCurrency: asset.asset).replaceError(with: []).mapEach { item in
                    ActivityEntryAdapter.createEntry(with: item)
                })
            )

            if asset.asset.supports(product: .staking) {
                streams.append(
                    ("staking \(asset.asset)", stakingActivityService.activity(currency: asset.asset).replaceError(with: []).mapEach { item in
                        ActivityEntryAdapter.createEntry(with: item, type: .staking)
                    })
                )
            }
            if asset.asset.supports(product: .interestBalance) {
                streams.append(
                    ("savings \(asset.asset)", savingsActivityService.activity(currency: asset.asset).replaceError(with: []).mapEach { item in
                        ActivityEntryAdapter.createEntry(with: item, type: .saving)
                    })
                )
            }

            if asset.asset.supports(product: .activeRewardsBalance) {
                streams.append(
                    ("active rewards \(asset.asset)", activeRewardsActivityService.activity(currency: asset.asset).replaceError(with: []).mapEach { item in
                        ActivityEntryAdapter.createEntry(with: item, type: .activeRewards)
                    })
                )
            }

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

        return combineLatest(
            streams.map { _, stream in stream.values },
            bufferingPolicy: .unbounded
        )
        .map { items in
            items.flatMap { $0 }.sorted(by: { $0.timestamp > $1.timestamp })
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

extension Publisher {

    func recordFailure(to app: AppProtocol, _ file: String = #file, _ line: Int = #line) -> AnyPublisher<Output, Failure> {
        `catch` { error in
            app.post(error: error, file: file, line: line)
            return Fail(outputType: Output.self, failure: error)
        }
        .eraseToAnyPublisher()
    }
}
