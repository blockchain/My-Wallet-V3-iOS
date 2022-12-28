// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit
import FeatureDashboardDomain
import FeatureStakingDomain

extension DependencyContainer {

    public static var dashboardUI = module {

        factory { () -> PricesSceneServiceAPI in
            PricesSceneService(
                app: DIKit.resolve(),
                enabledCurrenciesService: DIKit.resolve(),
                fiatCurrencyService: DIKit.resolve(),
                marketCapService: DIKit.resolve(),
                priceService: DIKit.resolve(),
                supportedPairsInteractorService: DIKit.resolve(),
                watchlistRepository: DIKit.resolve()
            )
        }
    }
}
