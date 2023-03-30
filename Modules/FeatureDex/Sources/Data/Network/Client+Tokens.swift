// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import FeatureDexDomain
import Foundation
import NetworkKit

enum TokensQueryBy: String, Codable {
    case native = "NATIVE"
    case top = "TOP"
    case symbol = "SYMBOL"
    case address = "ADDRESS"
    case mixed = "MIXED"
    case all = "ALL"
}

protocol TokensClientAPI {
    func tokens(
        chainId: Int,
        queryBy:  TokensQueryBy,
        query: String?,
        offset: Int?,
        limit: Int?
    ) -> AnyPublisher<[Token], NetworkError>
}

extension Client: TokensClientAPI {

    func tokens(
        chainId: Int,
        queryBy:  TokensQueryBy,
        query: String?,
        offset: Int?,
        limit: Int?
    ) -> AnyPublisher<[Token], NetworkError> {
        let parameters = Client.tokensParameters(
            chainId: chainId,
            queryBy: queryBy,
            query: query,
            offset: offset,
            limit: limit
        )
        guard let request = requestBuilder.get(path: Endpoint.tokens, parameters: parameters) else {
            return .failure(.unknown)
        }
        return networkAdapter.perform(request: request)
    }

    static private func tokensParameters(
        chainId: Int,
        queryBy:  TokensQueryBy,
        query: String?,
        offset: Int?,
        limit: Int?
    ) -> [URLQueryItem] {
        var items: [URLQueryItem] = [
            URLQueryItem(name: "chainId", value: String(chainId)),
            URLQueryItem(name: "queryBy", value: queryBy.rawValue)
        ]
        if let query {
            items.append(URLQueryItem(name: "query", value: query))
        }
        if let offset {
            items.append(URLQueryItem(name: "offset", value: String(offset)))
        }
        if let limit {
            items.append(URLQueryItem(name: "limit", value: String(limit)))
        }
        return items
    }
}
