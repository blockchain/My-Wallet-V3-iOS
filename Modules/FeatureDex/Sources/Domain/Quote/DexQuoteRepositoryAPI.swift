// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import Errors

public protocol DexQuoteRepositoryAPI {
    func quote(
        input: DexQuoteInput
    ) -> AnyPublisher<Result<DexQuoteOutput, UX.Error>, Never>
}

public enum QuoteError: Error, Equatable {
    case noReceiveAddress
    case notSupported
    case notReady
}
