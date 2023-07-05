// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainNamespace
import Combine
import FeatureDashboardDomain
import FeatureStakingDomain
import Foundation
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

    func getActivity() async -> [ActivityEntry] {
        var activityEntries: [ActivityEntry] = []
        let assets = coincore.cryptoAssets

        let fiatCurrency = try? await fiatCurrencyService.displayCurrency.await()
        if let fiatCurrency, let fiatOrdersActivity = try? await ordersActivity.activity(fiatCurrency: fiatCurrency).await() {
            activityEntries += fiatOrdersActivity.map(ActivityEntryAdapter.createEntry)
        }

        for asset in assets {
            async let a_swapActivity = try? await swapActivity.fetchActivity(
                cryptoCurrency: asset.asset,
                directions: [.internal]
            ).await()

            async let a_buySellActivity = try? await buySellActivity.buySellActivityEvents(cryptoCurrency: asset.asset).await()
            async let a_orderActivity = try? await ordersActivity.activity(cryptoCurrency: asset.asset).await()
            async let a_stakingActivity = try? await stakingActivityService.activity(currency: asset.asset).await()
            async let a_savingActivity = try? await savingsActivityService.activity(currency: asset.asset).await()
            async let a_activeRewardsActivity = try? await activeRewardsActivityService.activity(currency: asset.asset).await()

            let (
                swapActivity,
                buySellActivity,
                orderActivity,
                stakingActivity,
                savingActivity,
                activeRewardsActivity
            ) = await (
                a_swapActivity,
                a_buySellActivity,
                a_orderActivity,
                a_stakingActivity,
                a_savingActivity,
                a_activeRewardsActivity
            )

            let mappedSwappedActivity = swapActivity?.map { swapActivity in
                if swapActivity.pair.outputCurrencyType.isFiatCurrency {
                    let buySellActivityEntry = BuySellActivityItemEvent(swapActivityItemEvent: swapActivity)
                    return ActivityEntryAdapter.createEntry(
                        with: buySellActivityEntry,
                        originFromSwap: true,
                        networkFromSwap: swapActivity.pair.inputCurrencyType.code
                    )
                }
                return ActivityEntryAdapter.createEntry(with: swapActivity)
            }

            if let entries = mappedSwappedActivity {
                activityEntries += entries
            }

            let entries = buySellActivity?.map { ActivityEntryAdapter.createEntry(with: $0) }
            if let entries {
                activityEntries += entries
            }

            if let entries = orderActivity?.map(ActivityEntryAdapter.createEntry) {
                activityEntries += entries
            }

            let stakingEntries = stakingActivity?.map { ActivityEntryAdapter.createEntry(with: $0, type: .staking) }
            if let entries = stakingEntries {
                activityEntries += entries
            }

            let savingEntries = savingActivity?.map { ActivityEntryAdapter.createEntry(with: $0, type: .saving) }
            if let entries = savingEntries {
                activityEntries += entries
            }

            let activeRewardsEntries = activeRewardsActivity?.map { ActivityEntryAdapter.createEntry(with: $0, type: .activeRewards) }
            if let entries = activeRewardsEntries {
                activityEntries += entries
            }
        }

        return activityEntries.sorted(by: { $0.timestamp > $1.timestamp })
    }

    func activity() -> AnyPublisher<[ActivityEntry], Never> {
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
