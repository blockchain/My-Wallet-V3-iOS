// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import NetworkKit

final class Client {

    enum Endpoint {
        static let chains = "/v1/chains"
        static let quote = "/dex/quote"
        static let allowance = "/currency/evm/allowance"
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
