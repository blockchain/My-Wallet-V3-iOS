//
//  NetworkCommunicator.swift
//  Blockchain
//
//  Created by Jack on 07/05/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation
import RxSwift

public protocol NetworkCommunicatorAPI {
    func perform<ResponseType: Decodable>(request: NetworkRequest, responseType: ResponseType.Type) -> Completable
    func perform<ResponseType: Decodable>(request: NetworkRequest) -> Single<ResponseType>
}

public enum NetworkCommunicatorError: Error {
    case clientError(HTTPRequestClientError)
    case serverError(HTTPRequestServerError)
    case payloadError(HTTPRequestPayloadError)
}

// TODO:
// * Handle network reachability

final public class NetworkCommunicator: NetworkCommunicatorAPI {
    public static let shared = NetworkCommunicator()
    
    private let session: URLSession
    
    init(session: URLSession = URLSession.shared) {
        self.session = session
    }
    
    public func perform<ResponseType: Decodable>(request: NetworkRequest, responseType: ResponseType.Type) -> Completable {
        let requestSingle: Single<ResponseType> = perform(request: request)
        return requestSingle.asCompletable()
    }
    
    public func perform<ResponseType: Decodable>(request: NetworkRequest) -> Single<ResponseType> {
        return Single<ResponseType>.from { [weak self] completed in
            self?.execute(request: request.URLRequest, expecting: ResponseType.self) { result in
                completed(result)
            }
        }
    }
    
    // swiftlint:disable:next function_body_length
    private func execute<ResponseType: Decodable>(
        request: URLRequest,
        expecting: ResponseType.Type,
        completion: @escaping (NewResult<ResponseType, NetworkCommunicatorError>) -> Void) {
        
        let task = session.dataTask(with: request) { payload, response, error in
            
            if let error = error {
                completion(.failure(.clientError(.failedRequest(description: error.localizedDescription))))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                completion(.failure(.serverError(.badResponse)))
                return
            }
            
            guard let responseData = payload else {
                completion(.failure(.payloadError(.emptyData)))
                return
            }
            
            guard (200...299).contains(httpResponse.statusCode) else {
                let errorPayload = try? JSONDecoder().decode(NabuNetworkError.self, from: responseData)
                let errorStatusCode = HTTPRequestServerError.badStatusCode(code: httpResponse.statusCode, error: errorPayload)
                completion(.failure(.serverError(errorStatusCode)))
                return
            }
            
            // No need to decode if desired type is Void
            guard ResponseType.self != EmptyNetworkResponse.self else {
                let emptyResponse: ResponseType = EmptyNetworkResponse() as! ResponseType
                completion(.success(emptyResponse))
                return
            }
            
            if let payload = payload, error == nil {
                do {
                    let decoder = JSONDecoder()
                    decoder.dateDecodingStrategy = .secondsSince1970
                    let final = try decoder.decode(ResponseType.self, from: payload)
                    completion(.success(final))
                } catch let decodingError {
                    Logger.shared.debug("Payload decoding error: \(decodingError)")
                    completion(.failure(.payloadError(.badData)))
                }
            }
        }
        
        task.resume()
    }
}
