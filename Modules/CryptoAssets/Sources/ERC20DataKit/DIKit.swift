// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit
import ERC20Kit

extension DependencyContainer {

    // MARK: - ERC20DataKit Module

    public static var erc20DataKit = module {

        factory {
            ERC20BalancesClient(
                apiCode: DIKit.resolve(),
                networkAdapter: DIKit.resolve(),
                requestBuilder: DIKit.resolve()
            ) as ERC20BalancesClientAPI
        }

        factory {
            ERC20ActivityClient(
                apiCode: DIKit.resolve(),
                networkAdapter: DIKit.resolve(),
                requestBuilder: DIKit.resolve()
            ) as ERC20ActivityClientAPI
        }

        single {
            ERC20BalancesRepository(
                client: DIKit.resolve(),
                enabledCurrenciesService: DIKit.resolve()
            ) as ERC20BalancesRepositoryAPI
        }
    }
}
