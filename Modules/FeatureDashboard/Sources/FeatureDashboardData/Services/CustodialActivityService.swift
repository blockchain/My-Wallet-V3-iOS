// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainNamespace
import Combine
import FeatureDashboardDomain
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
            let swapActivity = try? await swapActivity.fetchActivity(
                cryptoCurrency: asset.asset,
                directions: [.internal]
            ).await()

            let buySellActivity = try? await buySellActivity.buySellActivityEvents(cryptoCurrency: asset.asset).await()
            let orderActivity = try? await ordersActivity.activity(cryptoCurrency: asset.asset).await()

            let mappedSwappedActivity = swapActivity?.map { swapActivity in
                if swapActivity.pair.outputCurrencyType.isFiatCurrency {
                    let buySellActivityEntry = BuySellActivityItemEvent(swapActivityItemEvent: swapActivity)
                    return ActivityEntryAdapter.createEntry(with: buySellActivityEntry)
                }
                return ActivityEntryAdapter.createEntry(with: swapActivity)
            }

            if let entries = mappedSwappedActivity {
                activityEntries += entries
            }

            if let entries = buySellActivity?.map(ActivityEntryAdapter.createEntry) {
                activityEntries += entries
            }

            if let entries = orderActivity?.map(ActivityEntryAdapter.createEntry) {
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
