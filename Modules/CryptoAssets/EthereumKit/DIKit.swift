// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit
import PlatformKit
import TransactionKit

extension DependencyContainer {

    // MARK: - EthereumKit Module

    public static var ethereumKit = module {

        factory { APIClient() as TransactionPushClientAPI }
        factory { APIClient() as TransactionClientAPI }
        factory { APIClient() as TransactionFeeClientAPI }
        factory { APIClient() as BalanceClientAPI }

        factory(tag: CryptoCurrency.ethereum) { EthereumExternalAssetAddressFactory() as CryptoReceiveAddressFactory }

        factory(tag: CryptoCurrency.ethereum) { EthereumAsset() as CryptoAsset }

        factory(tag: CryptoCurrency.ethereum) { EthereumOnChainTransactionEngineFactory() as OnChainTransactionEngineFactory }

        factory { EthereumAccountDetailsService() as EthereumAccountDetailsServiceAPI }

        factory { EthereumWalletAccountRepository() }

        factory { () -> EthereumWalletAccountRepositoryAPI in
            let repository: EthereumWalletAccountRepository = DIKit.resolve()
            return repository as EthereumWalletAccountRepositoryAPI
        }

        single { EthereumHistoricalTransactionService() }

        factory { EthereumTransactionalActivityItemEventsService() }

        factory { EthereumActivityItemEventDetailsFetcher() }

        factory { EthereumTransactionBuildingService() as EthereumTransactionBuildingServiceAPI }

        factory { EthereumTransactionSendingService() as EthereumTransactionSendingServiceAPI }

        factory { EthereumFeeService() as EthereumFeeServiceAPI }

        factory { AnyKeyPairProvider<EthereumKeyPair>.ethereum() }

        factory { EthereumTransactionBuilder() as EthereumTransactionBuilderAPI }

        factory { EthereumTransactionSigner() as EthereumTransactionSignerAPI }

        factory { EthereumTransactionEncoder() as EthereumTransactionEncoderAPI }

        factory { EthereumTransactionDispatcher() as EthereumTransactionDispatcherAPI }
    }
}

extension AnyKeyPairProvider where Pair == EthereumKeyPair {

    fileprivate static func ethereum(
        ethereumWalletAccountRepository: EthereumWalletAccountRepository = resolve()
    ) -> AnyKeyPairProvider<Pair> {
        AnyKeyPairProvider<Pair>(provider: ethereumWalletAccountRepository)
    }
}
