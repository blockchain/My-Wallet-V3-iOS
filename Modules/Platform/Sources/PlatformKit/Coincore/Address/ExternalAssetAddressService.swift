// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import DIKit
import MoneyKit

public enum CryptoReceiveAddressFactoryError: Error {
    case invalidAddress
}

/// A service that creates a `CryptoReceiveAddress` of the given `CryptoCurrency`.
/// Use this when you don't already have access to the given `CryptoCurrency`'s `CryptoAsset`.
public protocol ExternalAssetAddressServiceAPI {

    typealias TxCompleted = (TransactionResult) -> AnyPublisher<Void, Error>

    func makeExternalAssetAddress(
        asset: CryptoCurrency,
        address: String,
        label: String,
        onTxCompleted: @escaping TxCompleted
    ) -> Result<CryptoReceiveAddress, CryptoReceiveAddressFactoryError>
}

final class ExternalAssetAddressService: ExternalAssetAddressServiceAPI {

    private let coincore: CoincoreAPI

    init(coincore: CoincoreAPI = resolve()) {
        self.coincore = coincore
    }

    func makeExternalAssetAddress(
        asset: CryptoCurrency,
        address: String,
        label: String,
        onTxCompleted: @escaping (TransactionResult) -> AnyPublisher<Void, Error>
    ) -> Result<CryptoReceiveAddress, CryptoReceiveAddressFactoryError> {
        coincore[asset]
            .parse(
                address: address,
                label: label,
                onTxCompleted: onTxCompleted
            )
    }
}
