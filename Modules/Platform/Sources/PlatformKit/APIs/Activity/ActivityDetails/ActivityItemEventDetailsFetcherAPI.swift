// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import MoneyKit

public protocol ActivityItemEventDetailsFetcherAPI: AnyObject {
    associatedtype Model
    func details(
        for identifier: String,
        cryptoCurrency: CryptoCurrency
    ) -> AnyPublisher<Model, Error>
}

public struct AnyActivityItemEventDetailsFetcher<Model> {

    private let details: (String, CryptoCurrency) -> AnyPublisher<Model, Error>

    public init<API: ActivityItemEventDetailsFetcherAPI>(api: API) where API.Model == Model {
        self.details = api.details
    }

    public func details(
        for identifier: String,
        cryptoCurrency: CryptoCurrency
    ) -> AnyPublisher<Model, Error> {
        details(identifier, cryptoCurrency)
    }
}
