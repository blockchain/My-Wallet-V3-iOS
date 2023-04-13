// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import MoneyKit
import PlatformKit

final class ExternalAssetAddressServiceMock: ExternalAssetAddressServiceAPI {

    var underlyingResult: Result<
        CryptoReceiveAddress, CryptoReceiveAddressFactoryError
    > = .failure(.invalidAddress)

    func makeExternalAssetAddress(
        asset: CryptoCurrency,
        address: String,
        label: String,
        onTxCompleted: @escaping (TransactionResult) -> AnyPublisher<Void, Error>
    ) -> Result<CryptoReceiveAddress, CryptoReceiveAddressFactoryError> {
        underlyingResult
    }
}
