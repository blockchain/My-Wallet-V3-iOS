// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BitcoinChainKit
import DIKit
import MoneyKit
import PlatformKit
import WalletPayloadKit

extension DependencyContainer {

    // MARK: - BitcoinCashKit Module

    public static var bitcoinCashKit = module {

        factory { APIClient() as APIClientAPI }

        single { BitcoinCashWalletAccountRepository() }

        factory { () -> BitcoinCashTxNotesStrategyAPI in
            BitcoinCashTxNotesStrategy(
                repository: DIKit.resolve(),
                updater: DIKit.resolve()
            )
        }

        factory(tag: CryptoCurrency.bitcoinCash) { BitcoinCashAsset() as CryptoAsset }

        single { BitcoinCashHistoricalTransactionService() as BitcoinCashHistoricalTransactionServiceAPI }

        factory(tag: BitcoinChainCoin.bitcoinCash) { () -> BitcoinChainTransactionSigningServiceAPI in
            BchTransactionSigningService(
                signingInputService: DIKit.resolve(),
                signingService: DIKit.resolve()
            )
        }

        factory {
            BchSigningInputService(dustRepository: DIKit.resolve()) as BchSigningInputServiceAPI
        }

        factory {
            BchSigningService() as BchSigningServiceAPI
        }

        factory {
            BchDustRepository(client: DIKit.resolve()) as BchDustRepositoryAPI
        }

        single(tag: BitcoinChainCoin.bitcoinCash) {
            MultiAddressRepository<BitcoinCashHistoricalTransaction>(
                client: DIKit.resolve(tag: BitcoinChainCoin.bitcoinCash)
            )
        }

        factory(tag: BitcoinChainCoin.bitcoinCash) { () -> FetchMultiAddressFor in
            let repository: MultiAddressRepository<BitcoinCashHistoricalTransaction> =
                DIKit.resolve(tag: BitcoinChainCoin.bitcoinCash)
            return { xpubs in
                repository.multiAddress(for: xpubs)
                    .map {
                        BitcoinChainMultiAddressData(
                            addresses: $0.addresses,
                            latestBlockHeight: $0.latestBlockHeight
                        )
                    }
                    .eraseToAnyPublisher()
            }
        }
    }
}
