// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import Errors
@testable import EthereumKit
import MoneyKit

final class TransactionFeeClientAPIMock: TransactionFeeClientAPI {
    var underlyingFees: AnyPublisher<TransactionFeeResponse, NetworkError> = .just(
        TransactionFeeResponse(
            gasLimit: "21000",
            gasLimitContract: "75000",
            normal: "2000000000",
            high: "3000000000"
        )
    )

    func fees(
        network: EVMNetworkConfig,
        contractAddress: String?
    ) -> AnyPublisher<TransactionFeeResponse, NetworkError> {
        underlyingFees
    }
}
