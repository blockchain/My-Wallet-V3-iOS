// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import AnalyticsKit
import Combine
import DIKit
import Errors
import Foundation
import ToolKit

#if DEBUG
public class ReplayNetworkCommunicator: NetworkCommunicatorAPI {

    public struct Key: Hashable {

        public let url: URL
        public let method: String

        var filePath: String

        init(_ request: URLRequest, in directory: String) {
            self.init(
                request,
                __filePath(
                    for: request,
                    method: request.httpMethod.or(default: "GET"),
                    in: directory
                ).path
            )
        }

        init(_ request: URLRequest, in bundle: Bundle) {
            self.init(
                request,
                __filePath(
                    for: request,
                    method: request.httpMethod.or(default: "GET"),
                    in: bundle.resourcePath!
                ).lastPathComponent
            )
        }

        init(_ request: URLRequest, _ path: String) {
            self.url = request.url!
            self.method = request.httpMethod.or(default: "GET")
            self.filePath = path
        }
    }

    public var data: LazyDictionary<Key, Data?>

    public private(set) var requests: [NetworkRequest] = []

    private var errors: [Key: URLError.Code] = [:]
    private let makeKey: (URLRequest) -> Key

    public init(_ data: [URLRequest: Data], in bundle: Bundle) {
        let makeKey = { Key($0, in: bundle) }
        let sanitized = data.reduce(into: [:]) { result, x in
            result[makeKey(x.key)] = x.value
        }
        self.data = .init(sanitized) { request in
            try? Data(contentsOf: bundle.resourceURL!.appendingPathComponent(request.filePath))
        }
        self.makeKey = makeKey
    }

    public init(_ data: [URLRequest: Data], in directory: String = NSTemporaryDirectory()) {
        let makeKey = { Key($0, in: directory) }
        let sanitized = data.reduce(into: [:]) { result, x in
            result[makeKey(x.key)] = x.value
        }
        self.data = .init(sanitized) { request in
            try? Data(contentsOf: URL(fileURLWithPath: request.filePath))
        }
        self.makeKey = makeKey
    }

    public subscript(request: URLRequest) -> Data? {
        get { data[makeKey(request)] }
        set { data[makeKey(request)] = newValue }
    }

    public subscript(request: NetworkRequest) -> Data? {
        get { self[request.urlRequest] }
        set { self[request.urlRequest] = newValue }
    }

    public func error(_ request: URLRequest) {
        errors[makeKey(request)] = .badServerResponse
    }

    public func dataTaskPublisher(
        for request: NetworkRequest
    ) -> AnyPublisher<ServerResponse, NetworkError> {
        let key = makeKey(request.urlRequest)
        if let code = errors[makeKey(request.urlRequest)] {
            return Fail(
                error: NetworkError(
                    request: request.urlRequest,
                    type: .urlError(URLError(code))
                )
            )
            .eraseToAnyPublisher()
        }
        requests.append(request)
        guard
            let url = request.urlRequest.url,
            let value = data[key]
        else {
            return Fail(
                error: NetworkError(
                    request: request.urlRequest,
                    type: .urlError(URLError(.unsupportedURL))
                )
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

    public func dataTaskWebSocketPublisher(
        for request: NetworkRequest
    ) -> AnyPublisher<ServerResponse, NetworkError> {
        dataTaskPublisher(for: request)
    }
}

extension ReplayNetworkCommunicator.Key {

    public static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.url == rhs.url && lhs.method == rhs.method
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(url)
        hasher.combine(method)
    }
}

public class EphemeralNetworkCommunicator: NetworkCommunicatorAPI {
    public var session: URLSession
    public var isRecording: Bool
    public var directory: String
    public var responseHandler: NetworkResponseHandlerAPI = NetworkResponseHandler()

    public init(
        session: URLSession,
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
            for: request.peek("🌎", \.urlRequest.cURLCommand).urlRequest
        )
        .handleEvents(receiveOutput: { [weak self] data, _ in
            guard let self else { return }
            if isRecording {
                let request = request.urlRequest
                do {
                    let filePath = __filePath(for: request, method: request.httpMethod, in: directory)
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
        .mapError { error in
            NetworkError(request: request.urlRequest, type: .urlError(error))
        }
        .flatMap { [responseHandler] elements -> AnyPublisher<ServerResponse, NetworkError> in
            responseHandler.handle(elements: elements, for: request)
        }
        .eraseToAnyPublisher()
    }

    public func dataTaskWebSocketPublisher(
        for request: NetworkRequest
    ) -> AnyPublisher<ServerResponse, NetworkError> {

        session.erasedWebSocketTaskPublisher(
            for: request.peek("🌎", \.urlRequest.cURLCommand).urlRequest
        )
        .handleEvents(receiveOutput: { [weak self] message in
            guard let self else { return }
            if isRecording {
                let request = request.urlRequest
                do {
                    let filePath = __filePath(for: request, method: request.httpMethod, in: directory)
                    try FileManager.default.createDirectory(
                        at: filePath.deletingLastPathComponent(),
                        withIntermediateDirectories: true,
                        attributes: [:]
                    )

                    try message.toData()?.write(
                        to: filePath,
                        options: .atomicWrite
                    )
                } catch {
                    assertionFailure("‼️ Failed to write \(request) because \(error)")
                }
            }
        })
        .mapError { error in
            NetworkError(request: request.urlRequest, type: .urlError(error))
        }
        .flatMap { [responseHandler] elements -> AnyPublisher<ServerResponse, NetworkError> in
            responseHandler.handle(message: elements, for: request)
        }
        .eraseToAnyPublisher()
    }
}

private func __filePath(for request: URLRequest, method: String?, in directory: String) -> URL {
    var filePath = __filePath(for: request.url!, method: method, in: directory)
    if request.value(forHTTPHeaderField: "Accept") == "application/json" {
        filePath.appendPathExtension("json")
    }
    return filePath
}

private func __filePath(for url: URL, method: String?, in directory: String) -> URL {
    let filePath = URL(fileURLWithPath: directory)
        .appendingPathComponent(method.or(default: "GET"))
        .appendingPathComponent(url.path)
        .appendingPathComponent(
            url.queryArgs
                .reduce(into: "") { string, next in
                    string.append("/\(next.key)/\(next.value)")
                }
        )

    return filePath
        .appendingPathComponent(
            filePath.path
                .dropPrefix(directory)
                .dropPrefix("/")
                .dropSuffix("/")
                .replacingOccurrences(of: "/", with: "_")
        )
}

#endif

extension URLSessionWebSocketTask.Message {
    func toData() -> Data? {
        switch self {

        case .data(let data):
            return data

        case .string(let string):
            return Data(string.utf8)

        default:
            return nil
        }
    }
}
