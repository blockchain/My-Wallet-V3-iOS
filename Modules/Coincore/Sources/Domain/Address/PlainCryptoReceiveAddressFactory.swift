// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation
import MoneyKit

/// A `CryptoReceiveAddressFactory` that doesn't know how to validate the asset/address and assumes it is correct.
public final class PlainCryptoReceiveAddressFactory: ExternalAssetAddressFactory {

    private static let knownSchemes: [String] = [
        "bitcoin:", "bitcoincash:", "ethereum:"
    ]

    private let asset: CryptoCurrency

    public init(asset: CryptoCurrency) {
        self.asset = asset
    }

    public func makeExternalAssetAddress(
        address: String,
        label: String,
        onTxCompleted: @escaping TxCompleted
    ) -> Result<CryptoReceiveAddress, CryptoReceiveAddressFactoryError> {
        guard !Self.knownSchemes.contains(where: { address.hasPrefix($0) }) else {
            return .failure(.invalidAddress)
        }
        guard let regex = try? NSRegularExpression(pattern: "[a-zA-Z0-9]{15,}") else {
            return .failure(.invalidAddress)
        }
        let range = NSRange(location: 0, length: address.utf16.count)
        let firstMatch = regex.firstMatch(in: address, options: [], range: range)
        guard firstMatch != nil else {
            return .failure(.invalidAddress)
        }
        return .success(PlainCryptoReceiveAddress(address: address, asset: asset, label: label))
    }
}
