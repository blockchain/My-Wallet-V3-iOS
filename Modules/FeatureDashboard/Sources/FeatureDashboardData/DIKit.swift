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
                buySellActivity: DIKit.resolve(),
                stakingActivityService: DIKit.resolve(tag: EarnProduct.staking),
                savingsActivityService: DIKit.resolve(tag: EarnProduct.savings),
                activeRewardsActivityService: DIKit.resolve(tag: EarnProduct.active)
            )
        }

        factory { () -> CustodialActivityDetailsServiceAPI in
            CustodialActivityDetailsService(
                app: DIKit.resolve(),
                coincore: DIKit.resolve(),
                fiatCurrencyService: DIKit.resolve(),
                ordersActivity: DIKit.resolve(),
                swapActivity: DIKit.resolve(),
                buySellActivity: DIKit.resolve(),
                stakingActivityService: DIKit.resolve(tag: EarnProduct.staking),
                savingsActivityService: DIKit.resolve(tag: EarnProduct.savings),
                activeRewardsActivityService: DIKit.resolve(tag: EarnProduct.active)
            )
        }

        single { () -> CustodialActivityRepositoryAPI in
            CustodialActivityRepository(service: DIKit.resolve())
        }
    }
}
