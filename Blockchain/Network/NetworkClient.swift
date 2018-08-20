//
//  NetworkClient.swift
//  Blockchain
//
//  Created by Justin on 8/18/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//


import Foundation

infix operator -=>

enum ApiResult<T : Decodable> {
    case success(T)
    case failure(ApiError)
}

enum ApiError : Error {
    case notFound    // 404
    case serverError(Int) // 5xx
    case requestError // 4xx
    case responseFormatInvalid(String)
    case connectionError(Error)
}

typealias ApiCompletionBlock<T : Decodable> = (ApiResult<T>) -> Void

class NetworkClient {
    let session: URLSession
    
    init(session: URLSession) {
        self.session = session
    }
    
    func getAndParse<T: Decodable>(request: URLRequest, model: T.Type, completion: @escaping ApiCompletionBlock<T>) {
        let task = session.dataTask(with: request) { (data, response, error) in
            if let err = error {
                ApiResult.failure(.connectionError(err)) -=> completion
            } else {
                let http = response as! HTTPURLResponse
                switch http.statusCode {
                case 200:
                    let jsonDecoder = JSONDecoder()
                    do {
                        let genericModel = try jsonDecoder.decode(T.self, from: data!)
                        ApiResult.success(genericModel) -=> completion
                    } catch let err {
                        print(err)
                        let bodyString = String(data: data!, encoding: .utf8)
                        ApiResult.failure(.responseFormatInvalid(bodyString ?? "<no body>")) -=> completion
                    }
                    
                default:
                    ApiResult.failure(.serverError(http.statusCode)) -=> completion
                }
            }
        }
        task.resume()
    }
}

func -=><T>(result: ApiResult<T>, completion: @escaping ApiCompletionBlock<T>) {
    DispatchQueue.main.async {
        completion(result)
    }
}
