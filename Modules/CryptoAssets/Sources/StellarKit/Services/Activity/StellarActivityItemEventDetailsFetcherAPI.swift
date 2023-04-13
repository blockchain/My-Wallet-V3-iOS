// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import MoneyKit
import PlatformKit

final class StellarActivityItemEventDetailsFetcher: ActivityItemEventDetailsFetcherAPI {
    typealias Model = StellarActivityItemEventDetails

    private let repository: StellarWalletAccountRepositoryAPI
    private let operationsService: StellarHistoricalTransactionServiceAPI

    init(
        repository: StellarWalletAccountRepositoryAPI,
        operationsService: StellarHistoricalTransactionServiceAPI
    ) {
        self.repository = repository
        self.operationsService = operationsService
    }

    func details(
        for identifier: String,
        cryptoCurrency: CryptoCurrency
    ) -> AnyPublisher<StellarActivityItemEventDetails, Error> {
        repository.defaultAccount
            .flatMap { [operationsService] account -> AnyPublisher<StellarActivityItemEventDetails, Error> in
                guard let accountID = account?.publicKey else {
                    return AnyPublisher
                        .failure(StellarNetworkError.notFound)
                        .eraseError()
                        .eraseToAnyPublisher()
                }
                return operationsService
                    .transaction(accountID: accountID, operationID: identifier)
                    .asPublisher()
                    .map(StellarActivityItemEventDetails.init)
                    .eraseError()
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }
}
