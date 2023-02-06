// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Extensions
import Foundation

/// A networking error returned by the network layer, this can be mapped to user facing errors at a high level
public struct NetworkError: Error, TimeoutFailure {

    public enum ErrorType {
        case urlError(URLError)
        case serverError(HTTPRequestServerError)
        case rawServerError(ServerErrorResponse)
        case payloadError(HTTPRequestPayloadError, response: HTTPURLResponse? = nil)
        case authentication(Error)
    }

    public let request: URLRequest?
    public let type: ErrorType

    public init(request: URLRequest?, type: NetworkError.ErrorType) {
        self.request = request
        self.type = type
    }
}

extension NetworkError: FromNetworkError {

    public static let unknown = NetworkError(request: nil, type: .serverError(.badResponse))
    public static var timeout = NetworkError(request: nil, type: .urlError(.init(.timedOut)))

    public static func from(_ networkError: NetworkError) -> NetworkError {
        networkError
    }
}

extension NetworkError: ExpressibleByError {

    public init(_ error: some Error) {
        self.request = nil
        self.type = error as? ErrorType ?? .serverError(.badResponse)
    }
}

/// A simple implementation of `Equatable` for now. I might make sense to improve this, eventually.
extension NetworkError: Equatable {

    public static func == (lhs: NetworkError, rhs: NetworkError) -> Bool {
        String(describing: lhs) == String(describing: rhs)
    }
}

extension NetworkError: CustomStringConvertible {

    public var label: String {
        Mirror(reflecting: self).children.first?.label ?? String(describing: self)
    }

    public var endpoint: String? {
        request?.url?.path
    }

    public var payload: Data? {
        switch type {
        case .authentication, .payloadError, .serverError, .urlError:
            return nil
        case .rawServerError(let error):
            return error.payload
        }
    }

    public var response: HTTPURLResponse? {
        switch type {
        case .authentication, .serverError, .urlError:
            return nil
        case .payloadError(_, let o):
            return o
        case .rawServerError(let error):
            return error.response
        }
    }

    public var code: Int? {
        switch type {
        case .authentication, .serverError:
            return nil
        case .payloadError(_, let response):
            return response?.statusCode
        case .urlError(let error):
            return error.errorCode
        case .rawServerError(let error):
            return error.response.statusCode
        }
    }

    public var description: String {
        switch type {
        case .authentication(let error), .urlError(let error as Error):
            return error.localizedDescription
        case .payloadError(let error as Error, _), .serverError(let error as Error):
            #if DEBUG
            return """
            request: \(endpoint ?? "nil")
            error: \(error)
            """
            #else
            return label
            #endif
        case .rawServerError(let error):
            do {
                guard let payload = error.payload else { throw error }
                guard let string = String(data: payload, encoding: .utf8) else { throw error }
                return
                    """
                    HTTP \(error.response.statusCode)
                    \(string)
                    """
            } catch _ {
                return
                    """
                    HTTP \(error.response.statusCode)
                    """
            }
        }
    }
}
