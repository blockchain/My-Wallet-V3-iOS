// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import FeatureDexDomain
import NetworkKit

protocol VenuesClientAPI {
    func venues() -> AnyPublisher<[Venue], NetworkError>
}

extension Client: VenuesClientAPI {
    func venues() -> AnyPublisher<[Venue], NetworkError> {
        guard let request = requestBuilder.get(path: Endpoint.venues) else {
            return .failure(.unknown)
        }
        return networkAdapter.perform(request: request)
    }
}
