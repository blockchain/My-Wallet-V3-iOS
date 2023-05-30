// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit

extension DependencyContainer {

    public static var coincore = module {

        factory { () -> AssetLoaderAPI in
            AssetLoader(
                app: DIKit.resolve(),
                currenciesService: DIKit.resolve(),
                evmAssetFactory: DIKit.resolve(),
                erc20AssetFactory: DIKit.resolve(),
                custodialCryptoAssetFactory: DIKit.resolve()
            )
        }

        factory { ExternalAssetAddressService() as ExternalAssetAddressServiceAPI }
    }
}
