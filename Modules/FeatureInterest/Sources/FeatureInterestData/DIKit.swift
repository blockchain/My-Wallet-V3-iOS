// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit
import FeatureInterestDomain

extension DependencyContainer {

    // MARK: - FeatureInterestData Module

    public static var interestDataKit = module {

        // MARK: - Data

        factory { APIClient() as FeatureInterestDataAPIClient }

        factory { () -> InterestAccountBalanceClientAPI in
            let client: FeatureInterestDataAPIClient = DIKit.resolve()
            return client as InterestAccountBalanceClientAPI
        }

        factory { () -> InterestAccountWithdrawClientAPI in
            let client: FeatureInterestDataAPIClient = DIKit.resolve()
            return client as InterestAccountWithdrawClientAPI
        }

        factory { () -> InterestAccountLimitsClientAPI in
            let client: FeatureInterestDataAPIClient = DIKit.resolve()
            return client as InterestAccountLimitsClientAPI
        }

        factory { () -> InterestAccountRateClientAPI in
            let client: FeatureInterestDataAPIClient = DIKit.resolve()
            return client as InterestAccountRateClientAPI
        }

        factory { () -> InterestAccountTransferClientAPI in
            let client: FeatureInterestDataAPIClient = DIKit.resolve()
            return client as InterestAccountTransferClientAPI
        }

        factory { () -> BlockchainAccountRepositoryAPI in
            BlockchainAccountRepository(
                coincore: DIKit.resolve(),
                app: DIKit.resolve()
            )
        }

        factory { InterestAccountWithdrawRepository() as InterestAccountWithdrawRepositoryAPI }

        factory { InterestAccountOverviewRepository() as InterestAccountOverviewRepositoryAPI }

        factory { InterestAccountLimitsRepository() as InterestAccountLimitsRepositoryAPI }

        factory { InterestAccountTransferRepository() as InterestAccountTransferRepositoryAPI }

        single { InterestAccountBalanceRepository() as InterestAccountBalanceRepositoryAPI }

        factory { InterestAccountRateRepository() as InterestAccountRateRepositoryAPI }
    }
}
