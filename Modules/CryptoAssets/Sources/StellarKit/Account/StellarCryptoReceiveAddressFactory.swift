// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import FeatureTransactionDomain
import PlatformKit
import stellarsdk

final class StellarCryptoReceiveAddressFactory: ExternalAssetAddressFactory {

    func makeExternalAssetAddress(
        address: String,
        label: String,
        onTxCompleted: @escaping TxCompleted
    ) -> Result<CryptoReceiveAddress, CryptoReceiveAddressFactoryError> {
        guard !address.isEmpty else {
            return .failure(.invalidAddress)
        }
        if let fromSimpleAddress = parseFromSimpleAddress(address: address, label: label, onTxCompleted: onTxCompleted) {
            return .success(fromSimpleAddress)
        }
        if let fromStellarURL = parseFromStellarURL(address: address, label: label, onTxCompleted: onTxCompleted) {
            return .success(fromStellarURL)
        }
        return .failure(.invalidAddress)
    }

    /// Try parsing address in format 'web+stellar:pay?destination=<address>&memo=<memo>'
    private func parseFromStellarURL(
        address: String,
        label: String,
        onTxCompleted: @escaping TxCompleted
    ) -> CryptoReceiveAddress? {
        guard let url = URL(string: address) else {
            return nil
        }
        guard let urlPayload = SEP7URI(url: url) else {
            return nil
        }
        return validateAndCreate(
            address: urlPayload.address,
            label: label,
            memo: urlPayload.memo ?? "",
            onTxCompleted: onTxCompleted
        )
    }

    /// Try parsing address in format '<address>:<memo>'
    private func parseFromSimpleAddress(
        address: String,
        label: String,
        onTxCompleted: @escaping TxCompleted
    ) -> CryptoReceiveAddress? {
        let components = address.split(separator: ":")
        // If must have one or two components.
        guard components.count == 1 || components.count == 2 else {
            return nil
        }
        // The first component is the address.
        guard let addressComponent = components.first else {
            return nil
        }
        // If we have two components, the second one will be the memo.
        let memo: String = components.count == 2 ? String(components.last ?? "") : ""
        return validateAndCreate(
            address: String(addressComponent),
            label: label,
            memo: memo,
            onTxCompleted: onTxCompleted
        )
    }

    private func validateAndCreate(
        address: String,
        label: String,
        memo: String,
        onTxCompleted: @escaping TxCompleted
    ) -> CryptoReceiveAddress? {
        guard address.count == 56 else {
            return nil
        }
        guard let pair = try? stellarsdk.KeyPair(accountId: address) else {
            return nil
        }
        let accountID = pair.accountId
        return StellarReceiveAddress(
            address: accountID,
            label: label,
            memo: memo.isEmpty ? nil : memo,
            onTxCompleted: onTxCompleted
        )
    }
}
