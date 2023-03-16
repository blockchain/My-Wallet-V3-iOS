// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainNamespace
import Combine
import FeatureDashboardDomain
import FeatureStakingDomain
import Foundation
import Localization
import PlatformKit
import UnifiedActivityDomain

public class CustodialActivityDetailsService: CustodialActivityDetailsServiceAPI {
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

    public func getActivityDetails(for activityEntry: ActivityEntry) async throws -> ActivityDetail.GroupedItems? {
        let assets = coincore.cryptoAssets

        let fiatCurrency = try? await fiatCurrencyService.displayCurrency.await()
        if let fiatCurrency,
           let fiatOrdersActivity = try? await ordersActivity.activity(fiatCurrency: fiatCurrency).await()
            .filter({ $0.identifier == activityEntry.id && $0.date == activityEntry.date })
            .first
        {
            return ActivityDetailsAdapter.createActivityDetails(with: fiatOrdersActivity)
        }

        for asset in assets {
            let swapActivity = try? await swapActivity.fetchActivity(
                cryptoCurrency: asset.asset,
                directions: [.internal]
            ).await()
             .filter { $0.identifier == activityEntry.id }
             .first

            async let buySellActivity = try? await buySellActivity.buySellActivityEvents(cryptoCurrency: asset.asset)
                .await()
                .filter { $0.identifier == activityEntry.id && $0.creationDate == activityEntry.date }
                .first

            async let orderActivity = try? await ordersActivity.activity(cryptoCurrency: asset.asset)
                .await()
                .filter { $0.identifier == activityEntry.id }
                .first

            async let stakingActivity = try? await stakingActivityService.activity(currency: asset.asset)
                .await()
                .filter { $0.id == activityEntry.id }
                .first

            async let savingsActivity = try? await savingsActivityService.activity(currency: asset.asset)
                .await()
                .filter { $0.id == activityEntry.id }
                .first

            async let activeRewardsActivity = try? await activeRewardsActivityService.activity(currency: asset.asset)
                .await()
                .filter { $0.id == activityEntry.id }
                .first

            if let stakingActivity = await stakingActivity {
                return ActivityDetailsAdapter.createActivityDetails(from: LocalizationConstants.Activity.Details.stakingAccount, activity: stakingActivity)
            }

            if let savingsActivity = await savingsActivity {
                return ActivityDetailsAdapter.createActivityDetails(from: LocalizationConstants.Activity.Details.rewardsAccount, activity: savingsActivity)
            }

            if let activeRewardsActivity = await activeRewardsActivity {
                return ActivityDetailsAdapter.createActivityDetails(from: LocalizationConstants.Activity.Details.activeRewardsAccount, activity: activeRewardsActivity)
            }

            if let swapActivity {
                if swapActivity.pair.outputCurrencyType.isFiatCurrency {
                    let buySellActivityEntry = BuySellActivityItemEvent(swapActivityItemEvent: swapActivity)
                    return ActivityDetailsAdapter.createActivityDetails(with: buySellActivityEntry)
                }
                return ActivityDetailsAdapter.createActivityDetails(with: swapActivity)
            }

            if let buySellActivity = await buySellActivity {
                return ActivityDetailsAdapter.createActivityDetails(with: buySellActivity)
            }

            if let orderActivity = await orderActivity {
                return ActivityDetailsAdapter.createActivityDetails(with: orderActivity)
            }
        }
        return nil
    }
}
