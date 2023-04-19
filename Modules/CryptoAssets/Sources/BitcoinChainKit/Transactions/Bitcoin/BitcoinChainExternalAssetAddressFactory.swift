// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import FeatureTransactionDomain
import PlatformKit
import ToolKit
import WalletCore

/// ExternalAssetAddressFactory implementation for Bitcoin and BitcoinCash.
///
/// This factory will first try to create a BitcoinChainReceiveAddress assuming the input is a BIP21URI, so
/// to preserve any extra information (eg amount), if that fails it tries to create BitcoinChainReceiveAddress
/// by assuming the input is an address.
final class BitcoinChainExternalAssetAddressFactory<Token: BitcoinChainToken>: ExternalAssetAddressFactory {

    func makeExternalAssetAddress(
        address: String,
        label: String,
        onTxCompleted: @escaping TxCompleted
    ) -> Result<CryptoReceiveAddress, CryptoReceiveAddressFactoryError> {
        bip21URI(address: address, label: label, onTxCompleted: onTxCompleted)
            .flatMapError { _ in
                self.bitcoinChainReceiveAddress(
                    address: address,
                    label: label,
                    onTxCompleted: onTxCompleted
                )
            }
    }

    /// Tries to create a BitcoinChainReceiveAddress from the given input.
    /// Assumes address is a BIP21URI.
    private func bip21URI(
        address: String,
        label: String,
        onTxCompleted: @escaping TxCompleted
    ) -> Result<CryptoReceiveAddress, CryptoReceiveAddressFactoryError> {
        // Creates URL from 'address'.
        guard let url = URL(string: address) else {
            return .failure(.invalidAddress)
        }
        // Creates BIP21URI from url.
        guard let bip21URI = BIP21URI<Token>(url: url) else {
            return .failure(.invalidAddress)
        }
        // Validates the address is valid.
        guard Token.coin.walletCoreCoinType.validate(address: bip21URI.address) else {
            return .failure(.invalidAddress)
        }
        // Creates BitcoinChainReceiveAddress from 'BIP21URI'.
        let receiveAddress = BitcoinChainReceiveAddress<Token>(
            bip21URI: bip21URI,
            label: label,
            onTxCompleted: onTxCompleted
        )
        return .success(receiveAddress)
    }

    /// Tries to create a BitcoinChainReceiveAddress from the given input.
    /// Assumes address is not a BIP21URI, just a plain address.
    private func bitcoinChainReceiveAddress(
        address: String,
        label: String,
        onTxCompleted: @escaping TxCompleted
    ) -> Result<CryptoReceiveAddress, CryptoReceiveAddressFactoryError> {
        // Removes the prefix, if present.
        let address = address.removing(prefix: "\(Token.coin.uriScheme):")
        // Validates the address is valid.
        guard Token.coin.walletCoreCoinType.validate(address: address) else {
            return .failure(.invalidAddress)
        }
        // Creates BitcoinChainReceiveAddress from 'address'.
        let receiveAddress = BitcoinChainReceiveAddress<Token>(
            address: address,
            label: label,
            onTxCompleted: onTxCompleted
        )
        // Return success.
        return .success(receiveAddress)
    }
}
