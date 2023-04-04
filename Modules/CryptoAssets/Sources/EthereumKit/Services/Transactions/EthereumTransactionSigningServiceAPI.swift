// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BigInt
import Combine
import DIKit
import PlatformKit

public enum EthereumTransactionSigningServiceError: Error {
    case errorSigningTransaction(Error)
}

protocol EthereumTransactionSigningServiceAPI {
    func sign(
        transaction: EthereumTransactionCandidate,
        keyPair: EthereumKeyPair
    ) -> AnyPublisher<EthereumTransactionEncoded, EthereumTransactionSigningServiceError>
}

final class EthereumTransactionSigningService: EthereumTransactionSigningServiceAPI {

    private let transactionSigner: EthereumSignerAPI

    init(transactionSigner: EthereumSignerAPI = resolve()) {
        self.transactionSigner = transactionSigner
    }

    func sign(
        transaction: EthereumTransactionCandidate,
        keyPair: EthereumKeyPair
    ) -> AnyPublisher<EthereumTransactionEncoded, EthereumTransactionSigningServiceError> {
        EthereumTransactionCandidateCosted
            .create(transaction: transaction)
            .eraseError()
            .flatMap { costed in
                transactionSigner.sign(transaction: costed, keyPair: keyPair)
                    .eraseError()
            }
            .mapError(EthereumTransactionSigningServiceError.errorSigningTransaction)
            .publisher
            .eraseToAnyPublisher()
    }
}
