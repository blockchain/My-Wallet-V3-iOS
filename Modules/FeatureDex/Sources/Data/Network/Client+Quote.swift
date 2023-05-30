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
        let product = URLQueryItem(name: "product", value: product.rawValue)
        guard
            let body = try? JSONEncoder().encode(quote),
            let request = requestBuilder.post(path: Endpoint.quote, parameters: [product], body: body, authenticated: true)
        else {
            return .failure(.unknown)
        }
        return networkAdapter.perform(request: request)
    }
}
