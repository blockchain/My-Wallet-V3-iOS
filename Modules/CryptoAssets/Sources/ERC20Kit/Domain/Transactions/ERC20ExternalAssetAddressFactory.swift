// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit
import EthereumKit
import FeatureTransactionDomain
import MoneyKit
import PlatformKit
import WalletCore

enum ERC20AddressFactoryError: Error {
    case invalidAddress
    case wrongAsset
}

/// ExternalAssetAddressFactory implementation for ERC20.
final class ERC20ExternalAssetAddressFactory: ExternalAssetAddressFactory {

    private let asset: CryptoCurrency
    private let network: EVMNetwork
    private let enabledCurrenciesService: EnabledCurrenciesServiceAPI

    init(
        asset: CryptoCurrency,
        network: EVMNetwork,
        enabledCurrenciesService: EnabledCurrenciesServiceAPI
    ) {
        self.asset = asset
        self.network = network
        self.enabledCurrenciesService = enabledCurrenciesService
    }

    func makeExternalAssetAddress(
        address: String,
        label: String,
        onTxCompleted: @escaping TxCompleted
    ) -> Result<CryptoReceiveAddress, CryptoReceiveAddressFactoryError> {
        // Try to create EthereumReceiveAddress assuming the input ('address') is a EIP681URI.
        eip681URI(address: address, label: label, onTxCompleted: onTxCompleted)
            .flatMapError { error in
                // Failed to create EthereumReceiveAddress from EIP681URI.
                switch error {
                case .invalidAddress:
                    // Failed because input ('address') is NOT a EIP681URI.
                    // Retry by assuming the input is a plain address.
                    return self.erc20ReceiveAddress(
                        address: address,
                        label: label,
                        onTxCompleted: onTxCompleted
                    )
                    .replaceError(with: .invalidAddress)
                case .wrongAsset:
                    // Failed because input ('address') is a EIP681URI but
                    // not for this factory's 'asset', fail straight away.
                    return .failure(.invalidAddress)
                }
            }
    }

    /// Tries to create a ERC20ReceiveAddress from the given input.
    /// Assumes address is a EIP681URI.
    private func eip681URI(
        address: String,
        label: String,
        onTxCompleted: @escaping TxCompleted
    ) -> Result<CryptoReceiveAddress, ERC20AddressFactoryError> {
        // If label is same as address, we will replace it with the sanitized version (without prefix).
        let replaceLabel = label == address
        // Creates BIP21URI from url.

        guard let eip681URI = EIP681URI(
            url: address,
            network: network,
            enabledCurrenciesService: enabledCurrenciesService
        ) else {
            return .failure(.invalidAddress)
        }
        // Validates the address is valid.
        guard Self.validateAddress(eip681URI: eip681URI, network: network) else {
            return .failure(.invalidAddress)
        }
        // Validates the address is valid.
        guard Self.validate(cryptoCurrency: asset, eip681URI: eip681URI, enabledCurrenciesService: enabledCurrenciesService) else {
            return .failure(.invalidAddress)
        }
        guard eip681URI.amount == nil || eip681URI.amount?.currency == asset else {
            return .failure(.wrongAsset)
        }
        // If we should replace the label, use Transfer Address or 'main' address.
        let label: String = replaceLabel
            ? eip681URI.method.destination ?? eip681URI.address
            : label
        // Creates ERC20ReceiveAddress from 'BIP21URI'.
        guard let receiveAddress = ERC20ReceiveAddress(
            asset: asset,
            eip681URI: eip681URI,
            label: label,
            onTxCompleted: onTxCompleted
        ) else {
            return .failure(.wrongAsset)
        }
        return .success(receiveAddress)
    }

    /// Tries to create a ERC20ReceiveAddress from the given input.
    /// Assumes address is not a EIP681URI, just a plain address.
    private func erc20ReceiveAddress(
        address: String,
        label: String,
        onTxCompleted: @escaping TxCompleted
    ) -> Result<CryptoReceiveAddress, CryptoReceiveAddressFactoryError> {
        // If label is same as address, we will replace it with the sanitized version (without prefix).
        let replaceLabel = label == address
        // Removes the prefix, if present.
        let address = address.removing(prefix: "ethereum:")
        // Validates the address is valid.
        guard Self.validate(address: address, network: network) else {
            return .failure(.invalidAddress)
        }
        // Creates ERC20ReceiveAddress from 'address'.
        guard let receiveAddress = ERC20ReceiveAddress(
            asset: asset,
            address: address,
            label: replaceLabel ? address : label,
            onTxCompleted: onTxCompleted,
            enabledCurrenciesService: enabledCurrenciesService
        ) else {
            return .failure(.invalidAddress)
        }
        // Return success.
        return .success(receiveAddress)
    }

    /// Validates that a given EIP681URI is 'compatible' with a 'CryptoCurrency'.
    private static func validateAddress(eip681URI: EIP681URI, network: EVMNetwork) -> Bool {
        // EIP681URI address is valid
        guard validate(address: eip681URI.address, network: network) else {
            return false
        }
        // If it is a transfer, validate transfer destination
        guard let transferDestination = eip681URI.method.destination else {
            return true
        }
        return validate(address: transferDestination, network: network)
    }

    private static func validate(address: String, network: EVMNetwork) -> Bool {
        WalletCore.CoinType.ethereum.validate(address: address)
            && EthereumAddress(address: address, network: network) != nil
    }

    /// Validates that a given EIP681URI is 'compatible' with a 'CryptoCurrency'.
    private static func validate(
        cryptoCurrency: CryptoCurrency,
        eip681URI: EIP681URI,
        enabledCurrenciesService: EnabledCurrenciesServiceAPI
    ) -> Bool {
        let evmNativeAssets: [CryptoCurrency] = enabledCurrenciesService.allEnabledEVMNetworks.map(\.nativeAsset)
        switch eip681URI.cryptoCurrency {
        case let item where evmNativeAssets.contains(item):
            // CryptoCurrency is a native asset, allowed.
            return true
        case let item where item == cryptoCurrency:
            // CryptoCurrency is the same as this factory's, allowed.
            return true
        default:
            // CryptoCurrency is something else, not allowed.
            return false
        }
    }
}
