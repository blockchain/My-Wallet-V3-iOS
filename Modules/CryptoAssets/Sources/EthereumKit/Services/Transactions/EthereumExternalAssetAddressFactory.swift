// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit
import FeatureTransactionDomain
import MoneyKit
import PlatformKit
import WalletCore

enum EthereumAddressFactoryError: Error {
    case invalidAddress
    case wrongAsset
}

/// ExternalAssetAddressFactory implementation for Ethereum.
///
/// This factory will first try to create a EthereumReceiveAddress assuming the input is a EIP681URI, so
/// to preserve any extra information (eg amount), if that fails it tries to create EthereumReceiveAddress
/// by assuming the input is an address.
final class EthereumExternalAssetAddressFactory: ExternalAssetAddressFactory {

    private let enabledCurrenciesService: EnabledCurrenciesServiceAPI
    private let network: EVMNetwork

    init(
        enabledCurrenciesService: EnabledCurrenciesServiceAPI,
        network: EVMNetwork
    ) {
        self.enabledCurrenciesService = enabledCurrenciesService
        self.network = network
    }

    func makeExternalAssetAddress(
        address: String,
        label: String,
        onTxCompleted: @escaping TxCompleted
    ) -> Result<CryptoReceiveAddress, CryptoReceiveAddressFactoryError> {
        eip681URI(address: address, label: label, onTxCompleted: onTxCompleted)
            .flatMapError { error in
                switch error {
                case .invalidAddress:
                    return self.ethereumReceiveAddress(
                        address: address,
                        label: label,
                        onTxCompleted: onTxCompleted
                    )
                    .replaceError(with: .invalidAddress)
                case .wrongAsset:
                    return .failure(.invalidAddress)
                }
            }
    }

    /// Tries to create a BitcoinChainReceiveAddress from the given input.
    /// Assumes address is a BIP21URI.
    private func eip681URI(
        address: String,
        label: String,
        onTxCompleted: @escaping TxCompleted
    ) -> Result<CryptoReceiveAddress, EthereumAddressFactoryError> {
        // Creates BIP21URI from url.
        guard let eip681URI = EIP681URI(
            url: address,
            network: network,
            enabledCurrenciesService: enabledCurrenciesService
        ) else {
            return .failure(.invalidAddress)
        }
        // Validates the address is valid.
        guard Self.validate(address: eip681URI.address, network: network) else {
            return .failure(.invalidAddress)
        }
        guard eip681URI.cryptoCurrency == network.nativeAsset else {
            return .failure(.wrongAsset)
        }
        // Creates BitcoinChainReceiveAddress from 'BIP21URI'.
        let receiveAddress = EthereumReceiveAddress(
            eip681URI: eip681URI,
            label: label == address ? eip681URI.address : label,
            onTxCompleted: onTxCompleted
        )
        return .success(receiveAddress)
    }

    /// Tries to create a BitcoinChainReceiveAddress from the given input.
    /// Assumes address is not a BIP21URI, just a plain address.
    private func ethereumReceiveAddress(
        address: String,
        label: String,
        onTxCompleted: @escaping TxCompleted
    ) -> Result<CryptoReceiveAddress, EthereumAddressFactoryError> {
        // If label is same as address, we will replace it with the sanitized version (without prefix).
        let replaceLabel = label == address
        // Removes the prefix, if present.
        let address = address.removing(prefix: "ethereum:")
        // Validates the address is valid.
        guard Self.validate(address: address, network: network) else {
            return .failure(.invalidAddress)
        }
        // Creates EthereumReceiveAddress from 'address'.
        guard let receiveAddress = EthereumReceiveAddress(
            address: address,
            label: replaceLabel ? address : label,
            network: network,
            onTxCompleted: onTxCompleted
        ) else {
            return .failure(.invalidAddress)
        }
        // Return success.
        return .success(receiveAddress)
    }

    private static func validate(address: String, network: EVMNetwork) -> Bool {
        WalletCore.CoinType.ethereum.validate(address: address)
            && EthereumAddress(address: address, network: network) != nil
    }
}
