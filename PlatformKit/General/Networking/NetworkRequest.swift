//
//  NetworkRequest.swift
//  Blockchain
//
//  Created by Alex McGregor on 8/28/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift

public typealias HTTPHeaders = [String: String]

public struct NetworkRequest {
    
    public enum NetworkError: Error {
        case generic
    }
    
    public enum NetworkMethod: String {
        case get = "GET"
        case post = "POST"
        case put = "PUT"
        case delete = "DELETE"
    }

    public enum ContentType: String {
        case json = "application/json"
        case formUrlEncoded = "application/x-www-form-urlencoded"
    }
    
    public var URLRequest: URLRequest {
        let request: NSMutableURLRequest = NSMutableURLRequest(
            url: endpoint,
            cachePolicy: .reloadIgnoringLocalCacheData,
            timeoutInterval: 30.0
        )
        
        request.httpMethod = method.rawValue
        request.addValue(HttpHeaderValue.json, forHTTPHeaderField: HttpHeaderField.accept)
        request.addValue(contentType.rawValue, forHTTPHeaderField: HttpHeaderField.contentType)
        
        if let headers = headers {
            headers.forEach {
                request.addValue($1, forHTTPHeaderField: $0)
            }
        }
        
        addHttpBody(to: request)
        
        return request.copy() as! URLRequest
    }
    
    let method: NetworkMethod
    let endpoint: URL
    let headers: HTTPHeaders?
    let contentType: ContentType

    // TODO: modify this to be an Encodable type so that JSON serialization is done in this class
    // vs. having to serialize outside of this class
    let body: Data?

    private let session: URLSession? = {
        guard let session = NetworkManager.shared.session else { return nil }
        return session
    }()
    private var task: URLSessionDataTask?
    
    public init(
        endpoint: URL,
        method: NetworkMethod,
        body: Data? = nil,
        headers: HTTPHeaders? = nil,
        contentType: ContentType = .json
    ) {
        self.endpoint = endpoint
        self.method = method
        self.body = body
        self.headers = headers
        self.contentType = contentType
    }
    
    private func addHttpBody(to request: NSMutableURLRequest) {
        guard let data = body else {
            return
        }

        switch contentType {
        case .json:
            request.httpBody = data
        case .formUrlEncoded:
            if let params = try? JSONDecoder().decode([String: String].self, from: data) {
                request.encode(params: params)
            } else {
                request.httpBody = data
            }
        }
    }
    
    public static func POST(url: URL, body: Data?) -> NetworkRequest {
        return self.init(endpoint: url, method: .post, body: body)
    }
    
    public static func PUT(url: URL, body: Data?) -> NetworkRequest {
        return self.init(endpoint: url, method: .put, body: body)
    }
    
    public static func DELETE(url: URL) -> NetworkRequest {
        return self.init(endpoint: url, method: .delete, body: nil)
    }
}

// MARK: - Rx

extension NetworkRequest {
    
    public static func GET<ResponseType: Decodable>(
        url: URL,
        body: Data? = nil,
        headers: HTTPHeaders? = nil,
        type: ResponseType.Type
    ) -> Single<ResponseType> {
        let request = self.init(endpoint: url, method: .get, body: body, headers: headers)
        return NetworkCommunicator.shared.perform(request: request)
    }

    public static func POST(
        url: URL,
        body: Data?,
        headers: HTTPHeaders? = nil,
        contentType: ContentType = .json
    ) -> Completable {
        let request = self.init(endpoint: url, method: .post, body: body, headers: headers, contentType: contentType)
        return NetworkCommunicator.shared.perform(request: request, responseType: EmptyNetworkResponse.self)
    }

    public static func POST<ResponseType: Decodable>(
        url: URL,
        body: Data?,
        type: ResponseType.Type,
        headers: HTTPHeaders? = nil,
        contentType: ContentType = .json
    ) -> Single<ResponseType> {
        let request = self.init(endpoint: url, method: .post, body: body, headers: headers, contentType: contentType)
        return NetworkCommunicator.shared.perform(request: request)
    }
    
    public static func PUT(
        url: URL,
        body: Data?,
        headers: HTTPHeaders? = nil
    ) -> Completable {
        let request = self.init(endpoint: url, method: .put, body: body, headers: headers)
        return NetworkCommunicator.shared.perform(request: request, responseType: EmptyNetworkResponse.self)
    }

    public static func PUT<ResponseType: Decodable>(
        url: URL,
        body: Data?,
        type: ResponseType.Type,
        headers: HTTPHeaders? = nil
    ) -> Single<ResponseType> {
        let request = self.init(endpoint: url, method: .put, body: body, headers: headers)
        return NetworkCommunicator.shared.perform(request: request)
    }
}

extension NSMutableURLRequest {

    public func encode(params: [String : String]) {
        let encodedParamsArray = params.map { keyPair -> String in
            let (key, value) = keyPair
            return "\(key)=\(self.percentEscapeString(value))"
        }
        self.httpBody = encodedParamsArray.joined(separator: "&").data(using: .utf8)
    }

    private func percentEscapeString(_ stringToEscape: String) -> String {
        let characterSet = NSMutableCharacterSet.alphanumeric()
        characterSet.addCharacters(in: "-._* ")
        return stringToEscape
            .addingPercentEncoding(withAllowedCharacters: characterSet as CharacterSet)?
            .replacingOccurrences(of: " ", with: "+", options: [], range: nil) ?? stringToEscape
    }
}
