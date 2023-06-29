// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainNamespace
import Combine

extension CryptoNonCustodialAccount {

    public var canPerformInterestTransfer: AnyPublisher<Bool, Never> {
        isFunded
            .replaceError(with: false)
            .eraseToAnyPublisher()
    }
}
