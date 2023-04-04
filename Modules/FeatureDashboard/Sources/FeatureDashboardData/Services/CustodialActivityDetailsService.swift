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
        switch activityEntry.type {
        case .buy, .sell:
            return await buySellActivityDetails(entry: activityEntry)
        case .fiatOrder:
            return await fetchFiatActivityDetails(entry: activityEntry)
        case .cryptoOrder:
            return await ordersActivityDetails(entry: activityEntry)
        case .swap:
            return await swapActivityDetails(entry: activityEntry)
        case .saving:
            return await savingActivityDetails(entry: activityEntry)
        case .staking:
            return await stakingActivityDetails(entry: activityEntry)
        case .activeRewards:
            return await activeRewardsActivityDetails(entry: activityEntry)
        case .defi:
            // defi fetches activity details via a different api
            return nil
        }
    }

    private func fetchFiatActivityDetails(entry: ActivityEntry) async -> ActivityDetail.GroupedItems? {
        guard let fiatCurrency = entry.asset?.fiatCurrency else {
            return nil
        }
        let fiatOrdersActivity = try? await ordersActivity.activity(fiatCurrency: fiatCurrency).await()
            .filter { $0.identifier == entry.id && $0.date == entry.date }
            .first
        guard let fiatOrdersActivity else {
            return nil
        }
        return ActivityDetailsAdapter.createActivityDetails(with: fiatOrdersActivity)
    }

    private func buySellActivityDetails(entry: ActivityEntry) async -> ActivityDetail.GroupedItems? {
        guard let currency = entry.asset?.cryptoCurrency else {
            return nil
        }
        let buySellActivity = try? await buySellActivity.buySellActivityEvents(cryptoCurrency: currency)
            .await()
            .filter { $0.identifier == entry.id && $0.creationDate == entry.date }
            .first
        guard let buySellActivity else {
            return nil
        }
        return ActivityDetailsAdapter.createActivityDetails(with: buySellActivity)
    }

    private func ordersActivityDetails(entry: ActivityEntry) async -> ActivityDetail.GroupedItems? {
        guard let currency = entry.asset?.cryptoCurrency else {
            return nil
        }
        let orderActivity = try? await ordersActivity.activity(cryptoCurrency: currency)
            .await()
            .filter { $0.identifier == entry.id }
            .first
        guard let orderActivity else {
            return nil
        }
        return ActivityDetailsAdapter.createActivityDetails(with: orderActivity)
    }

    private func swapActivityDetails(entry: ActivityEntry) async -> ActivityDetail.GroupedItems? {
        guard let currency = entry.asset?.cryptoCurrency else {
            return nil
        }
        let swapActivity = try? await swapActivity.fetchActivity(cryptoCurrency: currency, directions: [.internal])
            .await()
            .filter { $0.identifier == entry.id }
            .first
        guard let swapActivity else {
            return nil
        }

        if swapActivity.pair.outputCurrencyType.isFiatCurrency {
            let buySellActivityEntry = BuySellActivityItemEvent(swapActivityItemEvent: swapActivity)
            return ActivityDetailsAdapter.createActivityDetails(with: buySellActivityEntry)
        }
        return ActivityDetailsAdapter.createActivityDetails(with: swapActivity)
    }

    private func stakingActivityDetails(entry: ActivityEntry) async -> ActivityDetail.GroupedItems? {
        guard let currency = entry.asset?.cryptoCurrency else {
            return nil
        }
        let stakingActivity = try? await stakingActivityService.activity(currency: currency)
            .await()
            .filter { $0.id == entry.id }
            .first
        guard let stakingActivity else {
            return nil
        }
        return ActivityDetailsAdapter.createActivityDetails(
            from: LocalizationConstants.Activity.Details.stakingAccount,
            type: .staking,
            activity: stakingActivity
        )
    }

    private func savingActivityDetails(entry: ActivityEntry) async -> ActivityDetail.GroupedItems? {
        guard let currency = entry.asset?.cryptoCurrency else {
            return nil
        }
        let savingActivity = try? await savingsActivityService.activity(currency: currency)
            .await()
            .filter { $0.id == entry.id }
            .first
        guard let savingActivity else {
            return nil
        }
        return ActivityDetailsAdapter.createActivityDetails(
            from: LocalizationConstants.Activity.Details.rewardsAccount,
            type: .saving,
            activity: savingActivity
        )
    }

    private func activeRewardsActivityDetails(entry: ActivityEntry) async -> ActivityDetail.GroupedItems? {
        guard let currency = entry.asset?.cryptoCurrency else {
            return nil
        }
        let activityRewardsActivity = try? await activeRewardsActivityService.activity(currency: currency)
            .await()
            .filter { $0.id == entry.id }
            .first
        guard let activityRewardsActivity else {
            return nil
        }
        return ActivityDetailsAdapter.createActivityDetails(
            from: LocalizationConstants.Activity.Details.activeRewardsAccount,
            type: .activeRewards,
            activity: activityRewardsActivity
        )
    }
}
