// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainNamespace
import Combine
import FeatureDashboardDomain
import FeatureStakingDomain
import Foundation
import PlatformKit
import UnifiedActivityDomain

public class CustodialActivityService: CustodialActivityServiceAPI {
    private let app: AppProtocol
    private let coincore: CoincoreAPI
    private let fiatCurrencyService: FiatCurrencySettingsServiceAPI
    private let ordersActivity: OrdersActivityServiceAPI
    private let swapActivity: SwapActivityServiceAPI
    private let buySellActivity: BuySellActivityItemEventServiceAPI
    private let stakingActivityService: EarnAccountService
    private let savingsActivityService: EarnAccountService
    private let activeRewardsActivityService: EarnAccountService

    public init(
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

    public func getActivity() async -> [ActivityEntry] {
        var activityEntries: [ActivityEntry] = []
        let assets = coincore.cryptoAssets

        let fiatCurrency = try? await fiatCurrencyService.displayCurrency.await()
        if let fiatCurrency,
           let fiatOrdersActivity = try? await ordersActivity.activity(fiatCurrency: fiatCurrency).await()
        {
            activityEntries += fiatOrdersActivity.map(ActivityEntryAdapter.createEntry)
        }

        for asset in assets {
            async let swapActivity = try? await swapActivity.fetchActivity(
                cryptoCurrency: asset.asset,
                directions: [.internal]
            ).await()

            async let buySellActivity = try? await buySellActivity.buySellActivityEvents(cryptoCurrency: asset.asset).await()
            async let orderActivity = try? await ordersActivity.activity(cryptoCurrency: asset.asset).await()
            async let stakingActivity = try? await stakingActivityService.activity(currency: asset.asset).await()
            async let savingActivity = try? await savingsActivityService.activity(currency: asset.asset).await()
            async let activeRewardsActivity = try? await activeRewardsActivityService.activity(currency: asset.asset).await()

            let mappedSwappedActivity = await swapActivity?.map { swapActivity in
                if swapActivity.pair.outputCurrencyType.isFiatCurrency {
                    let buySellActivityEntry = BuySellActivityItemEvent(swapActivityItemEvent: swapActivity)
                    return ActivityEntryAdapter.createEntry(with: buySellActivityEntry)
                }
                return ActivityEntryAdapter.createEntry(with: swapActivity)
            }

            if let entries = mappedSwappedActivity {
                activityEntries += entries
            }

            if let entries = await buySellActivity?.map(ActivityEntryAdapter.createEntry) {
                activityEntries += entries
            }

            if let entries = await orderActivity?.map(ActivityEntryAdapter.createEntry) {
                activityEntries += entries
            }

            if let entries = await stakingActivity?.map(ActivityEntryAdapter.createEntry) {
                activityEntries += entries
            }

            if let entries = await savingActivity?.map(ActivityEntryAdapter.createEntry) {
                activityEntries += entries
            }

            if let entries = await activeRewardsActivity?.map(ActivityEntryAdapter.createEntry) {
                activityEntries += entries
            }
        }

        return activityEntries.sorted(by: { $0.timestamp > $1.timestamp })
    }

    public func activity() -> AnyPublisher<[ActivityEntry], Never> {
        Deferred { [self] in
            Future { promise in
                Task {
                    do {
                        await promise(.success(self.getActivity()))
                    }
                }
            }
        }
        .eraseToAnyPublisher()
    }
}
