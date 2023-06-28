// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import DIKit
import NetworkKit
import PlatformKit

public struct EncodedBitcoinChainTransaction {
    let encodedTx: String
    let replayProtectionLockSecret: String?
}

public protocol APIClientAPI {

    func multiAddress<T: BitcoinChainHistoricalTransactionResponse>(
        for wallets: [XPub]
    ) -> AnyPublisher<BitcoinChainMultiAddressResponse<T>, NetworkError>

    func unspentOutputs(
        for wallets: [XPub]
    ) -> AnyPublisher<UnspentOutputsResponse, NetworkError>

    func push(
        transaction: EncodedBitcoinChainTransaction
    ) -> AnyPublisher<Void, NetworkError>
}

extension DerivationType {

    fileprivate var activeParameter: String {
        switch self {
        case .legacy:
            return "active"
        case .bech32:
            return "activeBech32"
        }
    }
}

final class APIClient: APIClientAPI {

    private struct Endpoint {
        var multiaddress: [String] {
            base + ["multiaddr"]
        }

        var unspent: [String] {
            base + ["unspent"]
        }

        var pushTx: [String] {
            base + ["pushtx"]
        }

        let base: [String]

        init(coin: BitcoinChainCoin) {
            self.base = [coin.rawValue.lowercased()]
        }
    }

    private enum Parameter {
        static func active(wallets: [XPub]) -> [URLQueryItem] {
            wallets
                .reduce(into: [DerivationType: [String]]()) { result, wallet in
                    var list = result[wallet.derivationType] ?? []
                    list.append(wallet.address)
                    result[wallet.derivationType] = list
                }
                .map { type, addresses -> URLQueryItem in
                    URLQueryItem(
                        name: type.activeParameter,
                        value: addresses.joined(separator: "|")
                    )
                }
        }
    }

    private let coin: BitcoinChainCoin
    private let networkAdapter: NetworkAdapterAPI
    private let requestBuilder: RequestBuilder
    private let endpoint: Endpoint
    private let apicode: APICode

    // MARK: - Init

    init(
        coin: BitcoinChainCoin,
        requestBuilder: RequestBuilder = resolve(),
        networkAdapter: NetworkAdapterAPI = resolve(),
        apicode: APICode = resolve()
    ) {
        self.coin = coin
        self.requestBuilder = requestBuilder
        self.apicode = apicode
        self.endpoint = Endpoint(coin: coin)
        self.networkAdapter = networkAdapter
    }

    // MARK: - APIClientAPI

    func multiAddress<T: BitcoinChainHistoricalTransactionResponse>(
        for wallets: [XPub]
    ) -> AnyPublisher<BitcoinChainMultiAddressResponse<T>, NetworkError> {
        let parameters = Parameter.active(wallets: wallets)
        let request = requestBuilder.get(
            path: endpoint.multiaddress,
            parameters: parameters,
            recordErrors: true
        )!
        return networkAdapter.perform(request: request)
    }

    func unspentOutputs(
        for wallets: [XPub]
    ) -> AnyPublisher<UnspentOutputsResponse, NetworkError> {
        let parameters = Parameter.active(wallets: wallets)
        let request = requestBuilder.post(
            path: endpoint.unspent,
            parameters: parameters,
            recordErrors: true
        )!
        return networkAdapter.perform(request: request)
    }

    func push(
        transaction: EncodedBitcoinChainTransaction
    ) -> AnyPublisher<Void, NetworkError> {
        let payload = PushTxPayload(
            tx: transaction.encodedTx,
            apiCode: apicode,
            lockSecret: transaction.replayProtectionLockSecret
        )
        let parameters = payload
            .dictionary
            .map(URLQueryItem.init)
        let body = RequestBuilder.body(from: parameters)
        let request = requestBuilder.post(
            path: endpoint.pushTx,
            body: body,
            contentType: .formUrlEncoded
        )!
        return networkAdapter.perform(request: request)
    }
}

private struct PushTxPayload {

    var dictionary: [String: String] {
        var base = [
            "tx": tx,
            "api_code": apiCode,
            "format": "plain"
        ]
        if let lockSecret {
            base["lock_secret"] = lockSecret
        }
        return base
    }

    let tx: String
    let apiCode: String
    let lockSecret: String?
}
