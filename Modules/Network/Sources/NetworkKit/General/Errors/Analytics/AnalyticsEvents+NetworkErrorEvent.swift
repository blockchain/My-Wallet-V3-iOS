// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import AnalyticsKit
import Foundation

enum NetworkErrorEvent: AnalyticsEvent {
    case unknown
    case clientError(ErrorDetails?)

    struct ErrorDetails {
        var params: [String: String] {
            var parameters: [String: String] = [
                "host": host,
                "path": path
            ]
            if let message {
                parameters["message"] = message
            }
            return parameters
        }

        let host: String
        let path: String
        let message: String?

        init?(request: NetworkRequest, message: String? = nil) {
            guard
                let url = request.urlRequest.url,
                let host = url.host
            else {
                return nil
            }
            self.host = host
            self.path = url.path
            self.message = message
        }
    }

    init?(request: NetworkRequest, error: URLError) {
        self = .clientError(ErrorDetails(request: request, message: String(describing: error)))
    }

    var name: String {
        "network_error"
    }

    var params: [String: String]? {
        switch self {
        case .unknown:
            [:]
        case .clientError(let details):
            details?.params ?? [:]
        }
    }
}
