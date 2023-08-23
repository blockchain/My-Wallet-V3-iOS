// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import NetworkKit

final class Client {

    enum Endpoint {
        static let addresses = "/wallet-pubkey/addresses"
        static let auth = "/wallet-pubkey/auth"
        static let balance = "/wallet-pubkey/balance"
        static let buildTx = "/wallet-pubkey/buildTx"
        static let pushTx = "/wallet-pubkey/pushTx"
        static let subscribe = "/wallet-pubkey/subscribe"
        static let subscriptions = "/wallet-pubkey/subscriptions"
        static let unsubscribe = "/wallet-pubkey/unsubscribe"
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
