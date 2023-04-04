// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import CombineExtensions
import Errors

public protocol RatesRepositoryAPI {

    func fetchEarnRates(
        code: String
    ) -> AnyPublisher<EarnRates, NetworkError>
}

// MARK: - Preview Helper

public struct PreviewRatesRepository: RatesRepositoryAPI {

    private let rate: AnyPublisher<EarnRates, NetworkError>

    public init(_ rate: AnyPublisher<EarnRates, NetworkError> = .empty()) {
        self.rate = rate
    }

    public func fetchEarnRates(
        code: String
    ) -> AnyPublisher<EarnRates, NetworkError> {
        rate
    }
}
