// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit
import FeatureStakingDomain
import NetworkKit

extension DependencyContainer {

    // MARK: - FeatureInterestData Module

    public static var featureStakingDataKit = module {

        single(tag: EarnProduct.savings) { () -> EarnRepositoryAPI in
            EarnRepository(
                client: EarnClient(
                    product: EarnProduct.savings.value,
                    networkAdapter: DIKit.resolve(tag: DIKitContext.retail),
                    requestBuilder: DIKit.resolve(tag: DIKitContext.retail)
                )
            )
        }

        single(tag: EarnProduct.staking) { () -> EarnRepositoryAPI in
            EarnRepository(
                client: EarnClient(
                    product: EarnProduct.staking.value,
                    networkAdapter: DIKit.resolve(tag: DIKitContext.retail),
                    requestBuilder: DIKit.resolve(tag: DIKitContext.retail)
                )
            )
        }

        single(tag: EarnProduct.active) { () -> EarnRepositoryAPI in
            EarnRepository(
                client: EarnClient(
                    product: EarnProduct.active.value,
                    networkAdapter: DIKit.resolve(tag: DIKitContext.retail),
                    requestBuilder: DIKit.resolve(tag: DIKitContext.retail)
                )
            )
        }
    }
}
