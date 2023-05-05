// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import Errors
import FeatureProductsDomain
import Foundation
import NetworkKit

public protocol ProductsClientAPI {

    func fetchProductsData() -> AnyPublisher<[String: ProductValue?], NabuNetworkError>
}

public final class ProductsAPIClient: ProductsClientAPI {

    private enum Path {
        static let products: [String] = ["products"]
    }

    public let networkAdapter: NetworkAdapterAPI
    public let requestBuilder: RequestBuilder
    let decoder: NetworkResponseDecoderAPI = NetworkResponseDecoder(NetworkResponseDecoder.anyDecoder)

    public init(networkAdapter: NetworkAdapterAPI, requestBuilder: RequestBuilder) {
        self.networkAdapter = networkAdapter
        self.requestBuilder = requestBuilder
    }

    public func fetchProductsData() -> AnyPublisher<[String: ProductValue?], NabuNetworkError> {
        let queryItem = URLQueryItem(name: "product", value: "SIMPLEBUY")
        let request = requestBuilder.get(
            path: Path.products,
            parameters: [queryItem],
            authenticated: true,
            decoder: decoder
        )!
        return networkAdapter.perform(request: request)
    }
}
