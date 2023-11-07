// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine

public enum ServerEntropyError: Error, Equatable {
    case failureToRetrieve
}

public enum EntropyFormat: String, Equatable {
    case hex
}

public enum EntropyBytes: Equatable {
    case `default`
    case custom(Int)

    public var value: Int {
        switch self {
        case .default:
            32
        case .custom(let value):
            value
        }
    }
}

public protocol ServerEntropyRepositoryAPI {

    /// Returns an entropy for the given parameters
    /// - Returns: `AnyPublisher<String, ServerEntropyError>`
    func getServerEntropy(
        bytes: EntropyBytes,
        format: EntropyFormat
    ) -> AnyPublisher<String, ServerEntropyError>
}
