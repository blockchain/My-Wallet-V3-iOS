// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import AnalyticsKit
import Errors
import Extensions
import Foundation

extension NetworkError {

    func analyticsEvent(
        for request: NetworkRequest,
        decodeErrorResponse: ((ServerErrorResponse) -> String?)? = nil
    ) -> AnalyticsEvent? {
        ClientNetworkError(
            error_code: code,
            http_error: String(describing: error),
            http_method: request.urlRequest.httpMethod,
            path: request.urlRequest.url?.path
        )
    }
}

struct ClientNetworkError: AnalyticsEvent {

    var type: AnalyticsEventType { .nabu }
    var name: String { "Client Network Error" }

    private(set) var params: [String: Any]? = [:]

    internal init(
        error_code: Int?,
        http_error: String?,
        http_method: String?,
        path: String?
    ) {
        params?["error_code"] ?= error_code
        params?["http_error"] ?= http_error
        params?["http_method"] ?= http_method
        params?["path"] ?= path
    }
}
