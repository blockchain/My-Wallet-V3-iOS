// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit
import FeatureDashboardDomain

extension DependencyContainer {

    public static var dashboardData = module {

        factory { () -> AssetBalanceInfoServiceAPI in
            AssetBalanceInfoService(
                allCrypoBalanceRepository: DIKit.resolve(),
                nonCustodialBalanceRepository: DIKit.resolve(),
                priceService: DIKit.resolve(),
                fiatCurrencyService: DIKit.resolve(),
                coincore: DIKit.resolve(),
                app: DIKit.resolve()
            )
        }

        single { () -> AssetBalanceInfoRepositoryAPI in
            AssetBalanceInfoRepository(
                service: DIKit.resolve()
            )
        }

        single { () -> CustodialAssetsRepositoryAPI in
            CustodialAssetsRepository(
                coincore: DIKit.resolve(),
                app: DIKit.resolve(),
                fiatCurrencyService: DIKit.resolve(),
                priceService: DIKit.resolve()
            )
        }

        factory { () -> CustodialActivityServiceAPI in
            CustodialActivityService(
                app: DIKit.resolve(),
                coincore: DIKit.resolve(),
                fiatCurrencyService: DIKit.resolve(),
                ordersActivity: DIKit.resolve(),
                swapActivity: DIKit.resolve(),
                buySellActivity: DIKit.resolve()
            )
        }
    }
}
