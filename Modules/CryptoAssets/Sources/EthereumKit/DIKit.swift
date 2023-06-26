// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import DIKit
import FeatureTransactionDomain
import MoneyKit
import PlatformKit
import ToolKit
import WalletPayloadKit

extension DependencyContainer {

    // MARK: - EthereumKit Module

    public static var ethereumKit = module {

        // MARK: APIClient

        factory { APIClient() as TransactionPushClientAPI }

        factory { APIClient() as TransactionFeeClientAPI }

        // MARK: RPCClient

        factory { RPCClient() as EstimateGasClientAPI }

        factory { RPCClient() as GetTransactionCountClientAPI }

        factory { RPCClient() as GetBalanceClientAPI }

        factory { RPCClient() as GetCodeClientAPI }

        // MARK: CoinCore

        factory(tag: CryptoCurrency.ethereum) {
            EVMAsset(
                network: .ethereum,
                keyPairProvider: DIKit.resolve(),
                repository: DIKit.resolve(),
                addressFactory: EthereumExternalAssetAddressFactory(
                    enabledCurrenciesService: DIKit.resolve(),
                    network: .ethereum
                ),
                errorRecorder: DIKit.resolve(),
                exchangeAccountProvider: DIKit.resolve(),
                kycTiersService: DIKit.resolve()
            ) as CryptoAsset
        }

        // MARK: Other

        factory { () -> EthereumTxNotesStrategyAPI in
            EthereumTxNotesStrategy(
                repository: DIKit.resolve(),
                updater: DIKit.resolve()
            )
        }

        factory {
            EthereumOnChainEngineCompanion(
                hotWalletAddressService: DIKit.resolve()
            ) as EthereumOnChainEngineCompanionAPI
        }

        single { EthereumNonceRepository() as EthereumNonceRepositoryAPI }

        single { EthereumBalanceRepository() as EthereumBalanceRepositoryAPI }

        single { EthereumWalletAccountRepository() }

        factory { () -> EthereumWalletAccountRepositoryAPI in
            let repo: EthereumWalletAccountRepository = DIKit.resolve()
            return repo as EthereumWalletAccountRepositoryAPI
        }

        factory { () -> EthereumWalletRepositoryAPI in
            let repo: EthereumWalletAccountRepository = DIKit.resolve()
            return repo as EthereumWalletRepositoryAPI
        }

        factory { () -> AnyActivityItemEventDetailsFetcher<EthereumActivityItemEventDetails> in
            AnyActivityItemEventDetailsFetcher(api: EthereumActivityItemEventDetailsFetcher())
        }

        factory { EthereumTransactionBuildingService() as EthereumTransactionBuildingServiceAPI }

        factory {
            EthereumTransactionSendingService(
                pushService: DIKit.resolve(),
                transactionSigner: DIKit.resolve()
            ) as EthereumTransactionSendingServiceAPI
        }

        factory { EthereumTransactionSigningService() as EthereumTransactionSigningServiceAPI }

        factory { EthereumFeeService() as EthereumFeeServiceAPI }

        factory { EthereumAccountService() as EthereumAccountServiceAPI }

        factory { EthereumKeyPairDeriver() }

        factory {
            EthereumKeyPairProvider(
                mnemonicAccess: DIKit.resolve(),
                deriver: DIKit.resolve()
            )
        }

        factory { EthereumSigner() as EthereumSignerAPI }

        factory { () -> EthereumTransactionDispatcherAPI in
            EthereumTransactionDispatcher(
                keyPairProvider: DIKit.resolve(),
                transactionSendingService: DIKit.resolve(),
                recordLastTransaction: { transaction in
                        .just(transaction)
                }
            )
        }

        single(tag: Tags.EthereumAccountService.isContractAddressCache) {
            Atomic<[String: Bool]>([:])
        }

        factory { WalletConnectEngineFactory() as WalletConnectEngineFactoryAPI }

        factory { GasEstimateService() as GasEstimateServiceAPI }

        factory { () -> EthereumTransactionPushServiceAPI in
            EthereumTransactionPushService(
                client: DIKit.resolve()
            )
        }

        factory { EVMAssetFactory() as EVMAssetFactoryAPI }
    }
}

extension DependencyContainer {
    enum Tags {
        enum EthereumAccountService {
            static let isContractAddressCache = String(describing: Self.self)
        }
    }
}

extension EVMNetwork {
    public static let ethereum: EVMNetwork = .init(networkConfig: .ethereum, nativeAsset: .ethereum)
}

final class EVMAssetFactory: EVMAssetFactoryAPI {
    func evmAsset(network: EVMNetwork) -> CryptoAsset {
        EVMAsset(
            network: network,
            keyPairProvider: DIKit.resolve(),
            repository: DIKit.resolve(),
            addressFactory: EthereumExternalAssetAddressFactory(
                enabledCurrenciesService: DIKit.resolve(),
                network: network
            ),
            errorRecorder: DIKit.resolve(),
            exchangeAccountProvider: DIKit.resolve(),
            kycTiersService: DIKit.resolve()
        )
    }
}
