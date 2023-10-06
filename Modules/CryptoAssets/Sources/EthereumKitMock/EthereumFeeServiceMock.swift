// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import EthereumKit
import MoneyKit
import PlatformKit

class EthereumFeeServiceMock: EthereumFeeServiceAPI {
    var underlyingFees: EVMTransactionFee

    init(underlyingFees: EVMTransactionFee) {
        self.underlyingFees = underlyingFees
    }

    func fees(
        network: EVMNetwork,
        contractAddress: String?
    ) -> AnyPublisher<EVMTransactionFee, Never> {
        .just(underlyingFees)
    }
}
