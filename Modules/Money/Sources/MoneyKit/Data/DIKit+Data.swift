// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit
import ToolKit

extension DependencyContainer {

    // MARK: - MoneyKit Module

    public static var moneyDataKit = module {

        factory { () -> EnabledCurrenciesServiceAPI in
            EnabledCurrenciesService.default
        }

        factory { () -> FilePathProviderAPI in
            FilePathProvider(
                fileManager: .default
            )
        }

        factory { () -> FileLoaderAPI in
            FileLoader(
                filePathProvider: DIKit.resolve(),
                jsonDecoder: .init()
            )
        }

        factory { () -> AssetsRepositoryAPI in
            AssetsRepository(
                fileLoader: DIKit.resolve(),
                evmSupport: DIKit.resolve()
            )
        }

        factory { () -> AssetsRemoteServiceAPI in
            AssetsRemoteService(
                client: DIKit.resolve(),
                filePathProvider: DIKit.resolve(),
                fileIO: DIKit.resolve(),
                jsonDecoder: .init()
            )
        }

        factory { () -> AssetsClientAPI in
            AssetsClient(
                requestBuilder: DIKit.resolve(),
                networkAdapter: DIKit.resolve()
            )
        }

        factory { () -> PriceClientAPI in
            PriceClient(
                networkAdapter: DIKit.resolve(),
                requestBuilder: DIKit.resolve()
            )
        }

        single { () -> PriceRepositoryAPI in
            PriceRepository(
                client: DIKit.resolve()
            )
        }

        single(tag: DIKitPriceContext.volume) { () -> PriceRepositoryAPI in
            PriceRepository(
                client: DIKit.resolve(),
                refreshControl: PerpetualCacheRefreshControl()
            )
        }

        factory { () -> EVMSupportAPI in
            EVMSupport(app: DIKit.resolve())
        }
    }
}
