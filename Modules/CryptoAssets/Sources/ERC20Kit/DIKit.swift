// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit
import FeatureTransactionDomain
import PlatformKit

extension DependencyContainer {

    // MARK: - ERC20Kit Module

    public static var erc20Kit = module {

        // MARK: Asset Agnostic

        factory { ERC20AssetFactory() as ERC20AssetFactoryAPI }

        factory {
            ERC20CryptoAssetService(
                accountsRepository: DIKit.resolve(),
                app: DIKit.resolve(),
                coincore: DIKit.resolve(),
                enabledCurrenciesService: DIKit.resolve()
            ) as ERC20CryptoAssetServiceAPI
        }
    }
}
