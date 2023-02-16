// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit

extension DependencyContainer {

    // MARK: - FeatureStakingDomain Module

    public static var featureStakingDomainKit = module {

        single(tag: EarnProduct.savings) { () -> EarnAccountService in
            EarnAccountService(app: DIKit.resolve(), repository: DIKit.resolve(tag: EarnProduct.savings))
        }

        single(tag: EarnProduct.staking) { () -> EarnAccountService in
            EarnAccountService(app: DIKit.resolve(), repository: DIKit.resolve(tag: EarnProduct.staking))
        }

        single(tag: EarnProduct.active) { () -> EarnAccountService in
            EarnAccountService(app: DIKit.resolve(), repository: DIKit.resolve(tag: EarnProduct.active))
        }
    }
}
