// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import NetworkKit

final class Client {

    enum Endpoint {
        static let chains = "/v1/aaaaaa"
        static let venues = "/v1/venues"
        static let tokens = "/v1/tokens"
    }

    // MARK: - Properties

    let requestBuilder: RequestBuilder
    let networkAdapter: NetworkAdapterAPI

    // MARK: - Init

    init(
        networkAdapter: NetworkAdapterAPI,
        requestBuilder: RequestBuilder
    ) {
        self.networkAdapter = networkAdapter
        self.requestBuilder = requestBuilder
    }
}
