// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import EthereumKit
import FeatureDexData

// MARK: - Blockchain Module

extension DependencyContainer {

    static var dex = module {
        factory { EVMPrivateKeyProvider(provider: DIKit.resolve()) as EVMPrivateKeyProviderAPI }
    }
}

enum EVMPrivateKeyProviderError: Error {
    case noAccount(Int)
}

final class EVMPrivateKeyProvider: EVMPrivateKeyProviderAPI {

    private let provider: EthereumKeyPairProvider

    init(provider: EthereumKeyPairProvider) {
        self.provider = provider
    }

    func privateKey(account: Int) -> AnyPublisher<Data, Error> {
        guard account == 0 else {
            return .failure(EVMPrivateKeyProviderError.noAccount(account))
        }
        return provider
            .keyPair
            .map(\.privateKey.data)
            .eraseToAnyPublisher()
    }
}
