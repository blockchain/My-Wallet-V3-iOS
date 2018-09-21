//
//  NetworkRequest.swift
//  Blockchain
//
//  Created by Alex McGregor on 8/28/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift

/// TICKET: IOS-1242 - Condense HttpHeaderField
/// and HttpHeaderValue into enums and inject in a token
struct NetworkRequest {
    
    enum NetworkError: Error {
        case generic
    }
    
    enum NetworkMethod: String {
        case get = "GET"
        case post = "POST"
        case put = "PUT"
        case delete = "DELETE"
    }
    
    let method: NetworkMethod
    let endpoint: URL
    let token: String?
    let body: Data?
    private let session: URLSession? = {
        guard let session = NetworkManager.shared.session else { return nil }
        return session
    }()
    private var task: URLSessionDataTask?
    
    init(endpoint: URL, method: NetworkMethod, body: Data?, authToken: String? = nil) {
        self.endpoint = endpoint
        self.token = authToken
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
        request.allHTTPHeaderFields = [HttpHeaderField.contentType: HttpHeaderValue.json,
                                       HttpHeaderField.accept: HttpHeaderValue.json]
        if let auth = token {
            request.addValue(
                auth,
                forHTTPHeaderField: HttpHeaderField.authorization
            )
        }
        
        if let data = body {
            request.httpBody = data
        }
        
        return request.copy() as? URLRequest
    }
    
    fileprivate mutating func execute<T: Decodable>(expecting: T.Type, withCompletion: @escaping ((Result<T>, _ responseCode: Int) -> Void)) {
        var responseCode: Int = 0
        
        guard let urlRequest = URLRequest() else {
            withCompletion(.error(nil), responseCode)
            return
        }
        guard let session = session else {
            withCompletion(.error(nil), responseCode)
            return
        }
        
        task = session.dataTask(with: urlRequest) { (payload, response, error) in

            if let error = error {
                withCompletion(.error(HTTPRequestClientError.failedRequest(description: error.localizedDescription)), responseCode)
                return
            }

            guard let httpResponse = response as? HTTPURLResponse else {
                withCompletion(.error(HTTPRequestServerError.badResponse), responseCode)
                return
            }

            guard (200...299).contains(httpResponse.statusCode) else {
                withCompletion(.error(HTTPRequestServerError.badStatusCode(code: httpResponse.statusCode)), httpResponse.statusCode)
                return
            }
            
            if let payload = payload, error == nil {
                do {
                    let decoder = JSONDecoder()
                    decoder.dateDecodingStrategy = .secondsSince1970
                    let final = try decoder.decode(T.self, from: payload)
                    withCompletion(.success(final), httpResponse.statusCode)
                } catch let decodingError {
                    Logger.shared.debug("Payload decoding error: \(decodingError)")
                    withCompletion(.error(HTTPRequestPayloadError.badData), httpResponse.statusCode)
                }
            }
        }
        
        task?.resume()
    }
    
    static func GET<ResponseType: Decodable>(
        url: URL,
        body: Data?,
        token: String?,
        type: ResponseType.Type
        ) -> Single<ResponseType> {
        var request = self.init(endpoint: url, method: .get, body: body, authToken: token)
        return Single.create(subscribe: { (observer) -> Disposable in
            request.execute(expecting: ResponseType.self, withCompletion: { (result, responseCode) in
                switch result {
                case .success(let value):
                    observer(.success(value))
                case .error(let error):
                    observer(.error(error ?? NetworkError.generic))
                }
            })
            return Disposables.create()
        })
    }
    
    static func POST<ResponseType: Decodable>(
        url: URL,
        body: Data?,
        token: String?,
        type: ResponseType.Type
        ) -> Single<ResponseType> {
        var request = self.init(endpoint: url, method: .post, body: body, authToken: token)
        return Single.create(subscribe: { (observer) -> Disposable in
            request.execute(expecting: ResponseType.self, withCompletion: { (result, responseCode) in
                switch result {
                case .success(let value):
                    observer(.success(value))
                case .error(let error):
                    observer(.error(error ?? NetworkError.generic))
                }
            })
            return Disposables.create()
        })
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
