// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BigInt
import Combine
import FeatureTransactionDomain
import MoneyKit
import PlatformKit

public typealias RecordLastTransaction =
    (EthereumTransactionPublished) -> AnyPublisher<EthereumTransactionPublished, Never>

public protocol EthereumTransactionDispatcherAPI {

    func send(
        transaction: EthereumTransactionCandidate,
        network: EVMNetworkConfig
    ) -> AnyPublisher<EthereumTransactionPublished, Error>
}

final class EthereumTransactionDispatcher: EthereumTransactionDispatcherAPI {

    private let recordLastTransaction: RecordLastTransaction
    private let keyPairProvider: EthereumKeyPairProvider
    private let transactionSendingService: EthereumTransactionSendingServiceAPI

    init(
        keyPairProvider: EthereumKeyPairProvider,
        transactionSendingService: EthereumTransactionSendingServiceAPI,
        recordLastTransaction: @escaping RecordLastTransaction
    ) {
        self.keyPairProvider = keyPairProvider
        self.transactionSendingService = transactionSendingService
        self.recordLastTransaction = recordLastTransaction
    }

    func send(
        transaction: EthereumTransactionCandidate,
        network: EVMNetworkConfig
    ) -> AnyPublisher<EthereumTransactionPublished, Error> {
        keyPairProvider
            .keyPair
            .flatMap { [transactionSendingService] keyPair
                -> AnyPublisher<EthereumTransactionPublished, Error> in
                transactionSendingService.signAndSend(
                    transaction: transaction,
                    keyPair: keyPair,
                    network: network
                )
                .eraseError()
            }
            .flatMap { [recordLastTransaction] transaction
                -> AnyPublisher<EthereumTransactionPublished, Error> in
                if network == .ethereum {
                    recordLastTransaction(transaction)
                        .setFailureType(to: Error.self)
                        .eraseToAnyPublisher()
                } else {
                    .just(transaction)
                }
            }
            .eraseToAnyPublisher()
    }
}
