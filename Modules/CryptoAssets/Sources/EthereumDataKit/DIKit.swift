// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit
import EthereumKit

extension DependencyContainer {

    // MARK: - EthereumDataKit Module

    public static var ethereumDataKit = module {

        // MARK: Client

        factory {
            RPCClient(
                networkAdapter: DIKit.resolve(),
                requestBuilder: DIKit.resolve(),
                apiCode: DIKit.resolve()
            ) as LatestBlockClientAPI
        }

        // MARK: Repository

        single {
            PendingTransactionRepository(
                repository: DIKit.resolve()
            ) as PendingTransactionRepositoryAPI
        }

        single {
            LatestBlockRepository(
                client: DIKit.resolve()
            ) as LatestBlockRepositoryAPI
        }
    }
}
