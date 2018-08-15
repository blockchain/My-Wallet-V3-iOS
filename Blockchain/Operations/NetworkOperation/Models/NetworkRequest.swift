//
//  NetworkRequest.swift
//  Blockchain
//
//  Created by AlexM on 8/15/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

struct NetworkRequest {

    enum NetworkMethod: String {
        case get = "GET"
        case post = "POST"
        case put = "PUT"
        case delete = "DELETE"
    }

    let method: NetworkMethod
    let endpoint: URL
    let body: Data?

    init(endpoint: URL, method: NetworkMethod, body: Data?) {
        self.endpoint = endpoint
        self.method = method
        self.body = body
    }

    func URLRequest() -> URLRequest? {
        let request: NSMutableURLRequest = NSMutableURLRequest(
            url: endpoint,
            cachePolicy: .reloadIgnoringLocalCacheData,
            timeoutInterval: 30.0
        )

        request.httpMethod = method.rawValue
        request.allHTTPHeaderFields = ["Content-Type":"application/json",
                                       "Accept": "application/json"]

        if let data = body {
            request.httpBody = data
        }

        return request.copy() as? URLRequest
    }

    static func GET(url: URL, body: Data?) -> NetworkRequest {
        return self.init(endpoint: url, method: .get, body: body)
    }

    static func POST(url: URL, body: Data?) -> NetworkRequest {
        return self.init(endpoint: url, method: .post, body: body)
    }

    static func PUT(url: URL, body: Data?) -> NetworkRequest {
        return self.init(endpoint: url, method: .put, body: body)
    }

    static func DELETE(url: URL) -> NetworkRequest {
        return self.init(endpoint: url, method: .delete, body: nil)
    }
}
