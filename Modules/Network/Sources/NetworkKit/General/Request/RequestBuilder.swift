// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import DIKit
import Foundation
import ToolKit

public let HTTPHeaderTag = "HTTPHeaderTag"

public struct RequestBuilderQueryParameters {

    public var publisher: AnyPublisher<[URLQueryItem]?, Never>

    public init<P: Publisher>(_ publisher: P) where P.Output == [URLQueryItem]?, P.Failure == Never {
        self.publisher = publisher.eraseToAnyPublisher()
    }
}

public class RequestBuilder {

    private let networkConfig: Network.Config
    private let baseRequestBuilder: BaseRequestBuilder

    public convenience init(
        config: Network.Config = resolve(),
        decoder: NetworkResponseDecoderAPI = NetworkResponseDecoder(),
        headers: HTTPHeaders = [:],
        queryParameters: RequestBuilderQueryParameters = .init(Just(nil))
    ) {
        self.init(config: config, decoder: decoder, resolveHeaders: { headers }, queryParameters: queryParameters)
    }

    public init(
        config: Network.Config = resolve(),
        decoder: NetworkResponseDecoderAPI = NetworkResponseDecoder(),
        resolveHeaders headers: @escaping () -> HTTPHeaders,
        queryParameters: RequestBuilderQueryParameters = .init(Just(nil))
    ) {
        self.networkConfig = config
        self.baseRequestBuilder = BaseRequestBuilder(
            decoder: decoder,
            resolveHeaders: headers,
            queryParameters: queryParameters
        )
    }

    public init(
        config: Network.Config,
        baseRequestBuilder: BaseRequestBuilder
    ) {
        self.networkConfig = config
        self.baseRequestBuilder = baseRequestBuilder
    }

    // MARK: - GET

    public func get(
        path components: [String] = [],
        parameters: [URLQueryItem]? = nil,
        headers: HTTPHeaders = [:],
        authenticated: Bool = false,
        contentType: NetworkRequest.ContentType = .json,
        decoder: NetworkResponseDecoderAPI? = nil,
        recordErrors: Bool = false
    ) -> NetworkRequest? {
        baseRequestBuilder.get(
            networkConfig: networkConfig,
            path: components,
            parameters: parameters,
            headers: headers,
            authenticated: authenticated,
            contentType: contentType,
            decoder: decoder,
            recordErrors: recordErrors
        )
    }

    public func get(
        path: String?,
        parameters: [URLQueryItem]? = nil,
        headers: HTTPHeaders = [:],
        authenticated: Bool = false,
        contentType: NetworkRequest.ContentType = .json,
        decoder: NetworkResponseDecoderAPI? = nil,
        recordErrors: Bool = false
    ) -> NetworkRequest? {
        baseRequestBuilder.get(
            networkConfig: networkConfig,
            path: path,
            parameters: parameters,
            headers: headers,
            authenticated: authenticated,
            contentType: contentType,
            decoder: decoder,
            recordErrors: recordErrors
        )
    }

    // MARK: - PUT

    public func put(
        path components: [String] = [],
        parameters: [URLQueryItem]? = nil,
        body: Data? = nil,
        headers: HTTPHeaders = [:],
        authenticated: Bool = false,
        contentType: NetworkRequest.ContentType = .json,
        decoder: NetworkResponseDecoderAPI? = nil,
        recordErrors: Bool = false
    ) -> NetworkRequest? {
        baseRequestBuilder.put(
            networkConfig: networkConfig,
            path: components,
            parameters: parameters,
            body: body,
            headers: headers,
            authenticated: authenticated,
            contentType: contentType,
            decoder: decoder,
            recordErrors: recordErrors
        )
    }

    public func put(
        path: String?,
        parameters: [URLQueryItem]? = nil,
        body: Data? = nil,
        headers: HTTPHeaders = [:],
        authenticated: Bool = false,
        contentType: NetworkRequest.ContentType = .json,
        decoder: NetworkResponseDecoderAPI? = nil,
        recordErrors: Bool = false
    ) -> NetworkRequest? {
        baseRequestBuilder.put(
            networkConfig: networkConfig,
            path: path,
            parameters: parameters,
            body: body,
            headers: headers,
            authenticated: authenticated,
            contentType: contentType,
            decoder: decoder,
            recordErrors: recordErrors
        )
    }

    // MARK: - POST

    public func post(
        path components: [String] = [],
        parameters: [URLQueryItem]? = nil,
        body: Data? = nil,
        headers: HTTPHeaders = [:],
        authenticated: Bool = false,
        contentType: NetworkRequest.ContentType = .json,
        decoder: NetworkResponseDecoderAPI? = nil,
        recordErrors: Bool = false
    ) -> NetworkRequest? {
        baseRequestBuilder.post(
            networkConfig: networkConfig,
            path: components,
            parameters: parameters,
            body: body,
            headers: headers,
            authenticated: authenticated,
            contentType: contentType,
            decoder: decoder,
            recordErrors: recordErrors
        )
    }

    public func post(
        path: String?,
        parameters: [URLQueryItem]? = nil,
        body: Data? = nil,
        headers: HTTPHeaders = [:],
        authenticated: Bool = false,
        contentType: NetworkRequest.ContentType = .json,
        decoder: NetworkResponseDecoderAPI? = nil,
        recordErrors: Bool = false
    ) -> NetworkRequest? {
        baseRequestBuilder.post(
            networkConfig: networkConfig,
            path: path,
            parameters: parameters,
            body: body,
            headers: headers,
            authenticated: authenticated,
            contentType: contentType,
            decoder: decoder,
            recordErrors: recordErrors
        )
    }

    // MARK: - PATCH

    public func patch(
        path components: [String] = [],
        parameters: [URLQueryItem]? = nil,
        body: Data? = nil,
        headers: HTTPHeaders = [:],
        authenticated: Bool = false,
        contentType: NetworkRequest.ContentType = .json,
        decoder: NetworkResponseDecoderAPI? = nil,
        recordErrors: Bool = false
    ) -> NetworkRequest? {
        baseRequestBuilder.patch(
            networkConfig: networkConfig,
            path: components,
            parameters: parameters,
            body: body,
            headers: headers,
            authenticated: authenticated,
            contentType: contentType,
            decoder: decoder,
            recordErrors: recordErrors
        )
    }

    public func patch(
        path: String?,
        parameters: [URLQueryItem]? = nil,
        body: Data? = nil,
        headers: HTTPHeaders = [:],
        authenticated: Bool = false,
        contentType: NetworkRequest.ContentType = .json,
        decoder: NetworkResponseDecoderAPI? = nil,
        recordErrors: Bool = false
    ) -> NetworkRequest? {
        baseRequestBuilder.patch(
            networkConfig: networkConfig,
            path: path,
            parameters: parameters,
            body: body,
            headers: headers,
            authenticated: authenticated,
            contentType: contentType,
            decoder: decoder,
            recordErrors: recordErrors
        )
    }

    // MARK: - Delete

    public func delete(
        path components: [String] = [],
        parameters: [URLQueryItem]? = nil,
        body: Data? = nil,
        headers: HTTPHeaders = [:],
        authenticated: Bool = false,
        contentType: NetworkRequest.ContentType = .json,
        decoder: NetworkResponseDecoderAPI? = nil,
        recordErrors: Bool = false
    ) -> NetworkRequest? {
        baseRequestBuilder.delete(
            networkConfig: networkConfig,
            path: components,
            parameters: parameters,
            body: body,
            headers: headers,
            authenticated: authenticated,
            contentType: contentType,
            decoder: decoder,
            recordErrors: false
        )
    }

    public static func body(from parameters: [URLQueryItem]) -> Data? {
        BaseRequestBuilder.body(from: parameters)
    }
}

public final class BaseRequestBuilder {

    public enum Error: Swift.Error {
        case buildingRequest
    }

    private func defaultComponents(networkConfig: Network.Config) -> URLComponents {
        var urlComponents = URLComponents()
        urlComponents.scheme = networkConfig.apiScheme
        urlComponents.host = networkConfig.apiHost
        urlComponents.path = BaseRequestBuilder.path(from: networkConfig.pathComponents)
        return urlComponents
    }

    private let decoder: NetworkResponseDecoderAPI
    private let headers: () -> HTTPHeaders

    private var queryParameters: [URLQueryItem]?
    private var subscription: AnyCancellable?

    public convenience init(
        decoder: NetworkResponseDecoderAPI = NetworkResponseDecoder(),
        headers: HTTPHeaders = [:],
        queryParameters: RequestBuilderQueryParameters = .init(Just(nil))
    ) {
        self.init(decoder: decoder, resolveHeaders: { headers }, queryParameters: queryParameters)
    }

    public init(
        decoder: NetworkResponseDecoderAPI = NetworkResponseDecoder(),
        resolveHeaders headers: @escaping () -> HTTPHeaders,
        queryParameters: RequestBuilderQueryParameters = .init(Just(nil))
    ) {
        self.decoder = decoder
        self.headers = headers
        if BuildFlag.isInternal {
            self.subscription = queryParameters.publisher.sink { [weak self] parameters in
                self?.queryParameters = parameters
            }
        }
    }

    // MARK: - GET

    public func get(
        networkConfig: Network.Config,
        path components: [String] = [],
        parameters: [URLQueryItem]? = nil,
        headers: HTTPHeaders = [:],
        authenticated: Bool = false,
        contentType: NetworkRequest.ContentType = .json,
        decoder: NetworkResponseDecoderAPI? = nil,
        recordErrors: Bool = false
    ) -> NetworkRequest? {
        get(
            networkConfig: networkConfig,
            path: BaseRequestBuilder.path(from: components),
            parameters: parameters,
            headers: headers,
            authenticated: authenticated,
            contentType: contentType,
            decoder: decoder,
            recordErrors: recordErrors
        )
    }

    public func get(
        networkConfig: Network.Config,
        path: String?,
        parameters: [URLQueryItem]? = nil,
        headers: HTTPHeaders = [:],
        authenticated: Bool = false,
        contentType: NetworkRequest.ContentType = .json,
        decoder: NetworkResponseDecoderAPI? = nil,
        recordErrors: Bool = false
    ) -> NetworkRequest? {
        buildRequest(
            networkConfig: networkConfig,
            method: .get,
            path: path,
            parameters: parameters,
            headers: headers,
            authenticated: authenticated,
            contentType: contentType,
            decoder: decoder,
            recordErrors: recordErrors
        )
    }

    // MARK: - PUT

    public func put(
        networkConfig: Network.Config,
        path components: [String] = [],
        parameters: [URLQueryItem]? = nil,
        body: Data? = nil,
        headers: HTTPHeaders = [:],
        authenticated: Bool = false,
        contentType: NetworkRequest.ContentType = .json,
        decoder: NetworkResponseDecoderAPI? = nil,
        recordErrors: Bool = false
    ) -> NetworkRequest? {
        put(
            networkConfig: networkConfig,
            path: BaseRequestBuilder.path(from: components),
            parameters: parameters,
            body: body,
            headers: headers,
            authenticated: authenticated,
            contentType: contentType,
            decoder: decoder,
            recordErrors: recordErrors
        )
    }

    public func put(
        networkConfig: Network.Config,
        path: String?,
        parameters: [URLQueryItem]? = nil,
        body: Data? = nil,
        headers: HTTPHeaders = [:],
        authenticated: Bool = false,
        contentType: NetworkRequest.ContentType = .json,
        decoder: NetworkResponseDecoderAPI? = nil,
        recordErrors: Bool = false
    ) -> NetworkRequest? {
        buildRequest(
            networkConfig: networkConfig,
            method: .put,
            path: path,
            parameters: parameters,
            body: body,
            headers: headers,
            authenticated: authenticated,
            contentType: contentType,
            decoder: decoder,
            recordErrors: recordErrors
        )
    }

    // MARK: - POST

    public func post(
        networkConfig: Network.Config,
        path components: [String] = [],
        parameters: [URLQueryItem]? = nil,
        body: Data? = nil,
        headers: HTTPHeaders = [:],
        authenticated: Bool = false,
        contentType: NetworkRequest.ContentType = .json,
        decoder: NetworkResponseDecoderAPI? = nil,
        recordErrors: Bool = false
    ) -> NetworkRequest? {
        post(
            networkConfig: networkConfig,
            path: BaseRequestBuilder.path(from: components),
            parameters: parameters,
            body: body,
            headers: headers,
            authenticated: authenticated,
            contentType: contentType,
            decoder: decoder,
            recordErrors: recordErrors
        )
    }

    public func post(
        networkConfig: Network.Config,
        path: String?,
        parameters: [URLQueryItem]? = nil,
        body: Data? = nil,
        headers: HTTPHeaders = [:],
        authenticated: Bool = false,
        contentType: NetworkRequest.ContentType = .json,
        decoder: NetworkResponseDecoderAPI? = nil,
        recordErrors: Bool = false
    ) -> NetworkRequest? {
        buildRequest(
            networkConfig: networkConfig,
            method: .post,
            path: path,
            parameters: parameters,
            body: body,
            headers: headers,
            authenticated: authenticated,
            contentType: contentType,
            decoder: decoder,
            recordErrors: recordErrors
        )
    }

    // MARK: - Delete

    public func delete(
        networkConfig: Network.Config,
        path components: [String] = [],
        parameters: [URLQueryItem]? = nil,
        body: Data? = nil,
        headers: HTTPHeaders = [:],
        authenticated: Bool = false,
        contentType: NetworkRequest.ContentType = .json,
        decoder: NetworkResponseDecoderAPI? = nil,
        recordErrors: Bool = false
    ) -> NetworkRequest? {
        buildRequest(
            networkConfig: networkConfig,
            method: .delete,
            path: BaseRequestBuilder.path(from: components),
            parameters: parameters,
            body: body,
            headers: headers,
            authenticated: authenticated,
            contentType: contentType,
            decoder: decoder,
            recordErrors: recordErrors
        )
    }

    // MARK: - PATCH

    public func patch(
        networkConfig: Network.Config,
        path components: [String] = [],
        parameters: [URLQueryItem]? = nil,
        body: Data? = nil,
        headers: HTTPHeaders = [:],
        authenticated: Bool = false,
        contentType: NetworkRequest.ContentType = .json,
        decoder: NetworkResponseDecoderAPI? = nil,
        recordErrors: Bool = false
    ) -> NetworkRequest? {
        patch(
            networkConfig: networkConfig,
            path: BaseRequestBuilder.path(from: components),
            parameters: parameters,
            body: body,
            headers: headers,
            authenticated: authenticated,
            contentType: contentType,
            decoder: decoder,
            recordErrors: recordErrors
        )
    }

    public func patch(
        networkConfig: Network.Config,
        path: String?,
        parameters: [URLQueryItem]? = nil,
        body: Data? = nil,
        headers: HTTPHeaders = [:],
        authenticated: Bool = false,
        contentType: NetworkRequest.ContentType = .json,
        decoder: NetworkResponseDecoderAPI? = nil,
        recordErrors: Bool = false
    ) -> NetworkRequest? {
        buildRequest(
            networkConfig: networkConfig,
            method: .patch,
            path: path,
            parameters: parameters,
            body: body,
            headers: headers,
            authenticated: authenticated,
            contentType: contentType,
            decoder: decoder,
            recordErrors: recordErrors
        )
    }

    // MARK: - Utilities

    public static func body(from parameters: [URLQueryItem]) -> Data? {
        var components = URLComponents()
        components.queryItems = parameters
        components.percentEncodedQuery = components.percentEncodedQuery?.replacingOccurrences(of: "+", with: "%2B")
        return components.percentEncodedQuery?.data(using: .utf8)
    }

    // MARK: - Private methods

    private static func path(from components: [String] = []) -> String {
        guard !components.isEmpty else {
            return ""
        }
        var components = components
        if components.first == "/" {
            components.removeFirst()
        }
        return "/" + components.joined(separator: "/")
    }

    private func buildRequest(
        networkConfig: Network.Config,
        method: NetworkRequest.NetworkMethod,
        path: String?,
        parameters: [URLQueryItem]? = nil,
        body: Data? = nil,
        headers: HTTPHeaders = [:],
        authenticated: Bool = false,
        contentType: NetworkRequest.ContentType = .json,
        decoder: NetworkResponseDecoderAPI?,
        recordErrors: Bool = false
    ) -> NetworkRequest? {
        guard let url = buildURL(networkConfig: networkConfig, path: path, parameters: parameters) else {
            return nil
        }
        return NetworkRequest(
            endpoint: url,
            method: method,
            body: body,
            headers: self.headers().merging(headers),
            authenticated: authenticated,
            contentType: contentType,
            decoder: decoder ?? self.decoder,
            recordErrors: recordErrors
        )
    }

    private func buildURL(networkConfig: Network.Config, path: String?, parameters: [URLQueryItem]? = nil) -> URL? {
        var components = defaultComponents(networkConfig: networkConfig)
        if let path {
            components.path += path
        }
        if let parameters {
            components.queryItems = parameters
            components.percentEncodedQuery = components.percentEncodedQuery?.replacingOccurrences(of: "+", with: "%2B")
        }
        if let parameters = queryParameters {
            components.queryItems = components.queryItems.map { $0 + parameters } ?? parameters
        }
        return components.url
    }
}
