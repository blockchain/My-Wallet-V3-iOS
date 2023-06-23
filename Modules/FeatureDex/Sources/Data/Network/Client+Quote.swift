// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import FeatureDexDomain
import Foundation
import NetworkKit

protocol QuoteClientAPI {
    func quote(
        product: DexQuoteProduct,
        quote: DexQuoteRequest
    ) -> AnyPublisher<DexQuoteResponse, NetworkError>
}

extension Client: QuoteClientAPI {
    func quote(
        product: DexQuoteProduct,
        quote: DexQuoteRequest
    ) -> AnyPublisher<DexQuoteResponse, NetworkError> {
        guard let request = request(product: product, quote: quote) else {
            return .failure(.unknown)
        }
        return networkAdapter.perform(request: request)
    }

    private func request(
        product: DexQuoteProduct,
        quote: DexQuoteRequest
    ) -> NetworkRequest? {
        guard let body = try? JSONEncoder().encode(quote) else {
            return nil
        }
        let product = URLQueryItem(name: "product", value: product.rawValue)
        return requestBuilder.post(
            path: Endpoint.quote,
            parameters: [product],
            body: body,
            authenticated: true
        )
    }
}
