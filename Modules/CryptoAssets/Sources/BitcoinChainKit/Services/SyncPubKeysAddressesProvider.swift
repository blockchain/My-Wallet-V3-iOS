// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import DIKit
import Foundation
import WalletPayloadKit

final class SyncPubKeysAddressesProvider: SyncPubKeysAddressesProviderAPI {

    private static let defaultLookAheadCount: UInt32 = 10

    private let addressProvider: BitcoinChainReceiveAddressProviderAPI
    private let fetchMultiAddressFor: FetchMultiAddressFor

    init(
        addressProvider: BitcoinChainReceiveAddressProviderAPI,
        fetchMultiAddressFor: @escaping FetchMultiAddressFor
    ) {
        self.addressProvider = addressProvider
        self.fetchMultiAddressFor = fetchMultiAddressFor
    }

    // swiftlint:disable reduce_into
    func provideAddresses(
        mnemonic: String,
        active: [String],
        accounts: [Account]
    ) -> AnyPublisher<String, SyncPubKeysAddressesProviderError> {
        hdAccountAddresses(
            mnemonic: mnemonic,
            accounts: accounts,
            coin: .bitcoin,
            lookupAheadCount: Self.defaultLookAheadCount
        )
        .map { hdAddresses -> String in
            let gathered = active + hdAddresses
            let formatted = gathered.joined(separator: "|")
            return formatted
        }
        .eraseToAnyPublisher()
    }

    private func hdAccountAddresses(
        mnemonic: String,
        accounts: [Account],
        coin: BitcoinChainCoin,
        lookupAheadCount: UInt32
    ) -> AnyPublisher<[String], SyncPubKeysAddressesProviderError> {
        accounts.publisher
            .flatMap { [fetchMultiAddressFor] account
                -> AnyPublisher<[String], SyncPubKeysAddressesProviderError> in
                receiveIndex(
                    account: account,
                    coin: coin,
                    mnemonicProvider: mnemonicProvider(mnemonic: mnemonic),
                    fetchMultiAddressFor: fetchMultiAddressFor
                )
                .map { context, receivedIndex -> (AccountKeyContextProtocol, Range<UInt32>) in
                    let receiveIndexRange: Range<UInt32> = receivedIndex..<(receivedIndex + lookupAheadCount)
                    return (context, receiveIndexRange)
                }
                .map { context, range -> [String] in
                    range
                        .map { receiveIndex in
                            deriveReceiveAddress(
                                context: context,
                                coin: coin,
                                receiveIndex: receiveIndex
                            )
                        }
                }
                .first()
                .eraseToAnyPublisher()
            }
            .reduce([String]()) { previous, new in
                previous + new
            }
            .mapError { error in
                SyncPubKeysAddressesProviderError.failureProvidingAddresses(error)
            }
            .eraseToAnyPublisher()
    }
}

/// Returns a `WalletMnemonicProvider`
private func mnemonicProvider(
    mnemonic: String
) -> WalletMnemonicProvider {
    { .just(Mnemonic(words: mnemonic)) }
}

/// Retrieves the receive index of a given account
private func receiveIndex(
    account: Account,
    coin: BitcoinChainCoin,
    mnemonicProvider: @escaping WalletMnemonicProvider,
    fetchMultiAddressFor: @escaping FetchMultiAddressFor
) -> AnyPublisher<(AccountKeyContextProtocol, UInt32), SyncPubKeysAddressesProviderError> {
    let bitcoinChainAccount = BitcoinChainAccount(index: Int32(account.index), coin: coin)
    return getAccountKeys(
        for: bitcoinChainAccount,
        walletMnemonicProvider: mnemonicProvider
    )
    .flatMap { [fetchMultiAddressFor] context -> AnyPublisher<(AccountKeyContextProtocol, UInt32), Error> in
        let xpubs = context.xpubs
        let multiAddressPublisher = getMultiAddress(
            xpubs: xpubs,
            fetchMultiAddressFor: fetchMultiAddressFor
        )
        return multiAddressPublisher
            .map { addressItems in
                let defaultAddress = addressItems.first(where: {
                    $0.xpub == context.defaultDerivation(coin: coin).xpub
                })
                guard let address = defaultAddress else {
                    return 0
                }
                return UInt32(address.accountIndex)
            }
            .map { receiveIndex in
                (context, receiveIndex)
            }
            .eraseToAnyPublisher()
    }
    .mapError { error in
        SyncPubKeysAddressesProviderError.failureProvidingAddresses(error)
    }
    .eraseToAnyPublisher()
}
