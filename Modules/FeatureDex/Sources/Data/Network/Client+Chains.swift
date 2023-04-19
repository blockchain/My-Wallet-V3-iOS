// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import FeatureDexDomain
import NetworkKit

protocol ChainsClientAPI {
    func chains() -> AnyPublisher<[Chain], NetworkError>
}

extension Client: ChainsClientAPI {
    func chains() -> AnyPublisher<[Chain], NetworkError> {
        guard let request = requestBuilder.get(path: Endpoint.chains) else {
            return .failure(.unknown)
        }
        return networkAdapter.perform(request: request)
    }
}
