// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine

/// A protocol defining a component that creates a `CryptoReceiveAddress`.
public protocol ExternalAssetAddressFactory {

    typealias TxCompleted = (TransactionResult) -> AnyPublisher<Void, Error>

    func makeExternalAssetAddress(
        address: String,
        memo: String?,
        label: String,
        onTxCompleted: @escaping TxCompleted
    ) -> Result<CryptoReceiveAddress, CryptoReceiveAddressFactoryError>
}
