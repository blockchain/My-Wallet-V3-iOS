// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit
import FeatureDashboardDomain
import FeatureStakingDomain

extension DependencyContainer {

    public static var dashboardData = module {

        factory { () -> AssetBalanceInfoServiceAPI in
            AssetBalanceInfoService(
                nonCustodialBalanceRepository: DIKit.resolve(),
                priceService: DIKit.resolve(),
                fiatCurrencyService: DIKit.resolve(),
                tradingBalanceService: DIKit.resolve(),
                stakingAccountService: DIKit.resolve(tag: EarnProduct.staking),
                savingsAccountService: DIKit.resolve(tag: EarnProduct.savings),
                coincore: DIKit.resolve(),
                app: DIKit.resolve()
            )
        }

        single { () -> AssetBalanceInfoRepositoryAPI in
            AssetBalanceInfoRepository(
                service: DIKit.resolve()
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

        factory { () -> CustodialActivityDetailsServiceAPI in
            CustodialActivityDetailsService(
                app: DIKit.resolve(),
                coincore: DIKit.resolve(),
                fiatCurrencyService: DIKit.resolve(),
                ordersActivity: DIKit.resolve(),
                swapActivity: DIKit.resolve(),
                buySellActivity: DIKit.resolve()
            )
        }

        single { () -> CustodialActivityRepositoryAPI in
            CustodialActivityRepository(service: DIKit.resolve())
        }
    }
}
