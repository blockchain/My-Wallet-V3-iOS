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
        ClientNetworkErrorEvent(
            error_code: code,
            http_error: String(describing: error),
            http_method: request.urlRequest.httpMethod,
            path: request.urlRequest.url?.path
        )
    }
}

extension NetworkRequest {
    func analyticsEvent() -> AnalyticsEvent {
        ClientNetworkRequestEvent(http_method: urlRequest.httpMethod, path: urlRequest.url?.path)
    }
}

struct ClientNetworkRequestEvent: AnalyticsEvent {

    var type: AnalyticsEventType { .nabu }
    var name: String { "Client Network Request" }

    private(set) var params: [String: Any]? = [:]

    init(
        http_method: String?,
        path: String?
    ) {
        params?["http_method"] ?= http_method
        params?["path"] ?= path
    }
}

struct ClientNetworkResponseEvent: AnalyticsEvent {

    var type: AnalyticsEventType { .nabu }
    var name: String { "Client Network Response" }

    private(set) var params: [String: Any]? = [:]

    init(
        http_method: String?,
        path: String?,
        response: String?
    ) {
        params?["http_method"] ?= http_method
        params?["path"] ?= path
        params?["status_code"] ?= response
    }
}


struct ClientNetworkErrorEvent: AnalyticsEvent {

    var type: AnalyticsEventType { .nabu }
    var name: String { "Client Network Error" }

    private(set) var params: [String: Any]? = [:]

    init(
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
