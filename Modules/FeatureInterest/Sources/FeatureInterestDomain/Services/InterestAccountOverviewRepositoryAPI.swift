// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import MoneyKit
import PlatformKit

public enum InterestAccountOverviewError: Error, Equatable {
    case networkError(Error)
    case accountRepositoryError(Error)

    var description: String {
        switch self {
        case .networkError(let error):
            String(describing: error)
        case .accountRepositoryError(let error):
            String(describing: error)
        }
    }
}

extension InterestAccountOverviewError {
    public static func == (
        lhs: InterestAccountOverviewError,
        rhs: InterestAccountOverviewError
    ) -> Bool {
        lhs.description == rhs.description
    }
}

public protocol InterestAccountOverviewRepositoryAPI {
    /// Fetches a list of all interest accounts that are currently available
    /// though may not yet be supported for the given `FiatCurrency`
    /// - Parameter currency: FiatCurrency
    func fetchInterestAccountOverviewListForFiatCurrency(
        _ fiatCurrency: FiatCurrency
    ) -> AnyPublisher<[InterestAccountOverview], InterestAccountOverviewError>
}
