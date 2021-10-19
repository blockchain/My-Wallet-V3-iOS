// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import AnalyticsKit
import Combine
import DIKit
import Foundation
import NetworkError
import ToolKit

public protocol NetworkCommunicatorAPI {

    /// Performs network requests
    /// - Parameter request: the request object describes the network request to be performed
    func dataTaskPublisher(
        for request: NetworkRequest
    ) -> AnyPublisher<ServerResponse, NetworkError>
}

final class NetworkCommunicator: NetworkCommunicatorAPI {

    // MARK: - Private properties

    private let session: NetworkSession
    private let authenticator: AuthenticatorAPI?
    private let eventRecorder: AnalyticsEventRecorderAPI?

    // MARK: - Setup

    init(
        session: NetworkSession = resolve(),
        sessionDelegate: SessionDelegateAPI = resolve(),
        sessionHandler: NetworkSessionDelegateAPI = resolve(),
        authenticator: AuthenticatorAPI? = nil,
        eventRecorder: AnalyticsEventRecorderAPI? = nil
    ) {
        self.session = session
        self.authenticator = authenticator
        self.eventRecorder = eventRecorder

        sessionDelegate.delegate = sessionHandler
    }

    // MARK: - Internal methods

    func dataTaskPublisher(
        for request: NetworkRequest
    ) -> AnyPublisher<ServerResponse, NetworkError> {
        guard request.authenticated else {
            return execute(request: request)
        }
        guard let authenticator = authenticator else {
            fatalError("Authenticator missing")
        }
        let _execute = execute
        return authenticator
            .authenticate { [execute = _execute] token in
                execute(request.adding(authenticationToken: token))
            }
    }

    // MARK: - Private methods

    private func execute(
        request: NetworkRequest
    ) -> AnyPublisher<ServerResponse, NetworkError> {
        session.erasedDataTaskPublisher(
            for: request.peek("🌎", \.urlRequest.cURLCommand, if: \.isDebugging.request).urlRequest
        )
        .mapError(NetworkError.urlError)
        .flatMap { elements -> AnyPublisher<ServerResponse, NetworkError> in
            request.responseHandler.handle(elements: elements, for: request)
        }
        .eraseToAnyPublisher()
        .recordErrors(on: eventRecorder, request: request) { request, error -> AnalyticsEvent? in
            error.analyticsEvent(for: request) { serverErrorResponse in
                request.decoder.decodeFailureToString(errorResponse: serverErrorResponse)
            }
        }
        .eraseToAnyPublisher()
    }
}

protocol NetworkSession {

    func erasedDataTaskPublisher(
        for request: URLRequest
    ) -> AnyPublisher<(data: Data, response: URLResponse), URLError>
}

extension URLSession: NetworkSession {

    func erasedDataTaskPublisher(
        for request: URLRequest
    ) -> AnyPublisher<(data: Data, response: URLResponse), URLError> {
        dataTaskPublisher(for: request)
            .eraseToAnyPublisher()
    }
}

extension AnyPublisher where Output == ServerResponse,
    Failure == NetworkError
{

    fileprivate func recordErrors(
        on recorder: AnalyticsEventRecorderAPI?,
        request: NetworkRequest,
        errorMapper: @escaping (NetworkRequest, NetworkError) -> AnalyticsEvent?
    ) -> AnyPublisher<ServerResponse, NetworkError> {
        handleEvents(
            receiveCompletion: { completion in
                guard case .failure(let communicatorError) = completion else {
                    return
                }
                guard let event = errorMapper(request, communicatorError) else {
                    return
                }
                recorder?.record(event: event)
            }
        )
        .eraseToAnyPublisher()
    }
}

#if DEBUG
public class ReplayNetworkCommunicator: NetworkCommunicatorAPI {

    public struct Key: Hashable {

        public let url: URL
        public let method: String

        init(_ request: URLRequest) {
            url = request.url!
            method = request.httpMethod.or(default: "GET")
        }
    }

    public var data: LazyDictionary<Key, Data?>

    public private(set) var requests: [Key] = []

    public init(_ data: [URLRequest: Data], in directory: String = NSTemporaryDirectory()) {
        let sanitized = data.reduce(into: [:]) { result, x in
            result[Key(x.key)] = x.value
        }
        self.data = .init(sanitized) { request in
            try? Data(
                contentsOf: __filePath(for: request.url, method: request.method, in: directory)
            )
        }
    }

    public func dataTaskPublisher(
        for request: NetworkRequest
    ) -> AnyPublisher<ServerResponse, NetworkError> {
        let key = Key(request.urlRequest)
        requests.append(key)
        guard
            let url = request.urlRequest.url,
            let value = data[key]
        else {
            return Fail(
                error: .urlError(URLError(.unsupportedURL))
            ).eraseToAnyPublisher()
        }
        let response = HTTPURLResponse(
            url: url,
            statusCode: 200,
            httpVersion: nil,
            headerFields: [:]
        )!
        return Just(ServerResponse(payload: value, response: response))
            .setFailureType(to: NetworkError.self)
            .eraseToAnyPublisher()
    }
}

public class EphemeralNetworkCommunicator: NetworkCommunicatorAPI {

    public var session: URLSession
    public var isRecording: Bool
    public var directory: String
    public var responseHandler: NetworkResponseHandlerAPI = NetworkResponseHandler()

    public init(
        session: URLSession = .shared,
        isRecording: Bool = false,
        directory: String = NSTemporaryDirectory()
    ) {
        self.session = session
        self.isRecording = isRecording
        self.directory = directory
    }

    public func dataTaskPublisher(
        for request: NetworkRequest
    ) -> AnyPublisher<ServerResponse, NetworkError> {
        session.erasedDataTaskPublisher(
            for: request.peek("🌎", \.urlRequest.cURLCommand, if: \.isDebugging.request).urlRequest
        )
        .handleEvents(receiveOutput: { [weak self] data, _ in
            guard let self = self else { return }
            if self.isRecording {
                let request = request.urlRequest
                do {
                    let filePath = __filePath(for: request.url!, method: request.httpMethod, in: self.directory)
                    try FileManager.default.createDirectory(
                        at: filePath.deletingLastPathComponent(),
                        withIntermediateDirectories: true,
                        attributes: [:]
                    )
                    try data.write(
                        to: filePath,
                        options: .atomicWrite
                    )
                } catch {
                    assertionFailure("‼️ Failed to write \(request) because \(error)")
                }
            }
        })
        .mapError(NetworkError.urlError)
        .flatMap { [responseHandler] elements -> AnyPublisher<ServerResponse, NetworkError> in
            responseHandler.handle(elements: elements, for: request)
        }
        .eraseToAnyPublisher()
    }
}

private func __filePath(for url: URL, method: String?, in directory: String) -> URL {
    URL(fileURLWithPath: directory)
        .appendingPathComponent(#fileID.replacingOccurrences(of: ".swift", with: ""))
        .appendingPathComponent(method.or(default: "GET"))
        .appendingPathComponent(
            url.absoluteString
                .replacingOccurrences(of: "://", with: "__")
                .replacingOccurrences(of: ".", with: "_")
                .replacingOccurrences(of: "/", with: "-")
        )
}

#endif
