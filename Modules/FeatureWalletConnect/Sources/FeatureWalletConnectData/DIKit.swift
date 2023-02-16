// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit
import FeatureWalletConnectDomain
import WalletPayloadKit

extension DependencyContainer {

    // MARK: - FeatureWalletConnectData Module

    public static var featureWalletConnectData = module {

        single { () -> WalletConnectServiceAPI in
            WalletConnectService(
                analyticsEventRecorder: DIKit.resolve(),
                app: DIKit.resolve(),
                publicKeyProvider: DIKit.resolve(),
                sessionRepository: DIKit.resolve(),
                featureFlagService: DIKit.resolve(),
                enabledCurrenciesService: DIKit.resolve(),
                walletConnectConsoleLogger: DIKit.resolve()
            )
        }

        single { () -> SessionRepositoryAPI in
            SessionRepositoryMetadata(
                walletConnectFetcher: DIKit.resolve()
            )
        }
    }
}
