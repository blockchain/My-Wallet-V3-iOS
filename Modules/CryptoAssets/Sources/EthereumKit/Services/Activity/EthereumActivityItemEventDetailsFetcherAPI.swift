// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import DIKit
import MoneyKit
import PlatformKit

final class EthereumActivityItemEventDetailsFetcher: ActivityItemEventDetailsFetcherAPI {
    typealias Model = EthereumActivityItemEventDetails

    private let transactionService: HistoricalTransactionsRepositoryAPI

    init(transactionService: HistoricalTransactionsRepositoryAPI = resolve()) {
        self.transactionService = transactionService
    }

    func details(
        for identifier: String,
        cryptoCurrency: CryptoCurrency
    ) -> AnyPublisher<EthereumActivityItemEventDetails, Error> {
        transactionService
            .transaction(identifier: identifier)
            .map(EthereumActivityItemEventDetails.init(transaction:))
            .eraseError()
            .eraseToAnyPublisher()
    }
}
