// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit
import ToolKit
import WalletConnectRelay
import WalletPayloadKit
import Web3Wallet

extension DependencyContainer {

    // MARK: - FeatureWalletConnectDomain Module

    public static var featureWalletConnectDomain = module {

        factory { WalletConnectConsoleLogger() as WalletConnectConsoleLoggerAPI }

        factory { WalletConnectAccountProvider() as WalletConnectAccountProviderAPI }

        factory { WalletConnectAccountProvider() as WalletConnectPublicKeyProviderAPI }

        factory {
            WalletConnectVersionRouter(
                app: DIKit.resolve(),
                v1Service: DIKit.resolve(),
                v2Service: DIKit.resolve()
            )
        }

        // MARK: - Data related

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

        single { () -> WalletConnectServiceV2API in
            WalletConnectServiceV2(
                productId: InfoDictionaryHelper.value(for: .walletConnectId),
                app: DIKit.resolve(),
                enabledCurrenciesService: DIKit.resolve(),
                publicKeyProvider: DIKit.resolve(),
                accountProvider: DIKit.resolve(),
                ethereumKeyPairProvider: DIKit.resolve(),
                ethereumSignerFactory: EthereumSignerFactory()
            )
        }
    }
}
