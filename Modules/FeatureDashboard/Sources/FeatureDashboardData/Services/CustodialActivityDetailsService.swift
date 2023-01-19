// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainNamespace
import Combine
import FeatureDashboardDomain
import Foundation
import PlatformKit
import UnifiedActivityDomain

public class CustodialActivityDetailsService: CustodialActivityDetailsServiceAPI {
    private let app: AppProtocol
    private let coincore: CoincoreAPI
    private let fiatCurrencyService: FiatCurrencySettingsServiceAPI
    private let ordersActivity: OrdersActivityServiceAPI
    private let swapActivity: SwapActivityServiceAPI
    private let buySellActivity: BuySellActivityItemEventServiceAPI

    public init(
        app: AppProtocol,
        coincore: CoincoreAPI,
        fiatCurrencyService: FiatCurrencySettingsServiceAPI,
        ordersActivity: OrdersActivityServiceAPI,
        swapActivity: SwapActivityServiceAPI,
        buySellActivity: BuySellActivityItemEventServiceAPI
    ) {
        self.app = app
        self.coincore = coincore
        self.fiatCurrencyService = fiatCurrencyService
        self.ordersActivity = ordersActivity
        self.swapActivity = swapActivity
        self.buySellActivity = buySellActivity
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

            let buySellActivity = try? await buySellActivity.buySellActivityEvents(cryptoCurrency: asset.asset)
                .await()
                .filter { $0.identifier == activityEntry.id && $0.creationDate == activityEntry.date }
                .first

            let orderActivity = try? await ordersActivity.activity(cryptoCurrency: asset.asset)
                .await()
                .filter { $0.identifier == activityEntry.id }
                .first

            if let swapActivity {
                if swapActivity.pair.outputCurrencyType.isFiatCurrency {
                    let buySellActivityEntry = BuySellActivityItemEvent(swapActivityItemEvent: swapActivity)
                    return ActivityDetailsAdapter.createActivityDetails(with: buySellActivityEntry)
                }
                return ActivityDetailsAdapter.createActivityDetails(with: swapActivity)
            }

            if let buySellActivity {
                return ActivityDetailsAdapter.createActivityDetails(with: buySellActivity)
            }

            if let orderActivity {
                return ActivityDetailsAdapter.createActivityDetails(with: orderActivity)
            }
        }
        return nil
    }
}
