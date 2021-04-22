//
//  NetworkAdapterAPI.swift
//  NetworkKit
//
//  Created by Jack Pooley on 05/04/2021.
//  Copyright © 2021 Blockchain Luxembourg S.A. All rights reserved.
//

import Combine
import DIKit
import RxCombine
import RxSwift
import ToolKit

/// Provides a bridge to so clients can continue consuming the `RxSwift` APIs temporarily
public protocol NetworkAdapterRxAPI {
    
    @available(*, deprecated, message: "Don't use this. Clients should use the new publisher contract.")
    func perform(request: NetworkRequest) -> Completable
    
    @available(*, deprecated, message: "Don't use this. Clients should use the new publisher contract.")
    func perform<ErrorResponseType: ErrorResponseConvertible>(
        request: NetworkRequest,
        errorResponseType: ErrorResponseType.Type
    ) -> Completable
    
    @available(*, deprecated, message: "Don't use this. Clients should use the new publisher contract.")
    func perform<ResponseType: Decodable>(request: NetworkRequest) -> Single<ResponseType>
    
    @available(*, deprecated, message: "Don't use this. Clients should use the new publisher contract.")
    func perform<ResponseType: Decodable>(
        request: NetworkRequest,
        responseType: ResponseType.Type
    ) -> Single<ResponseType>
    
    @available(*, deprecated, message: "Don't use this. Clients should use the new publisher contract.")
    func perform<ResponseType: Decodable, ErrorResponseType: ErrorResponseConvertible>(
        request: NetworkRequest,
        errorResponseType: ErrorResponseType.Type
    ) -> Single<ResponseType>
    
    @available(*, deprecated, message: "Don't use this. Clients should use the new publisher contract.")
    func perform<ResponseType: Decodable, ErrorResponseType: ErrorResponseConvertible>(
        request: NetworkRequest,
        responseType: ResponseType.Type,
        errorResponseType: ErrorResponseType.Type
    ) -> Single<ResponseType>
    
    @available(*, deprecated, message: "Don't use this. Clients should use the new publisher contract.")
    func performOptional<ResponseType: Decodable>(
        request: NetworkRequest,
        responseType: ResponseType.Type
    ) -> Single<ResponseType?>
    
    @available(*, deprecated, message: "Don't use this. Clients should use the new publisher contract.")
    func performOptional<ResponseType: Decodable, ErrorResponseType: ErrorResponseConvertible>(
        request: NetworkRequest,
        responseType: ResponseType.Type,
        errorResponseType: ErrorResponseType.Type
    ) -> Single<ResponseType?>
}

/// The `Combine` network adapter API, all new uses of networking should consume this API
public protocol NetworkAdapterAPI: NetworkAdapterRxAPI {
    
    /// Performs a request and maps the response or error response
    /// - Parameter request: the request to perform
    func perform<ResponseType: Decodable, ErrorResponseType: ErrorResponseConvertible>(
        request: NetworkRequest
    ) -> AnyPublisher<ResponseType, ErrorResponseType>
    
    /// Performs a request and maps the response or error response
    /// - Parameter request: the request to perform
    func perform<ResponseType: Decodable>(
        request: NetworkRequest
    ) -> AnyPublisher<ResponseType, NetworkCommunicatorError>
    
    /// Performs a request and maps the response or error response
    /// - Parameters:
    /// - Parameter request: the request to perform
    ///   - responseType: the type of the response to map to
    func perform<ResponseType: Decodable, ErrorResponseType: ErrorResponseConvertible>(
        request: NetworkRequest,
        responseType: ResponseType.Type
    ) -> AnyPublisher<ResponseType, ErrorResponseType>
    
    /// Performs a request and maps the response and returns any errors
    /// - Parameters:
    /// - Parameter request: the request to perform
    ///   - responseType: the type of the response to map to
    func perform<ResponseType: Decodable>(
        request: NetworkRequest,
        responseType: ResponseType.Type
    ) -> AnyPublisher<ResponseType, NetworkCommunicatorError>
    
    /// Performs a request and maps the response or error response
    /// - Parameters:
    /// - Parameter request: the request to perform
    ///   - errorResponseType: the type of the error response to map to
    func perform<ResponseType: Decodable, ErrorResponseType: ErrorResponseConvertible>(
        request: NetworkRequest,
        errorResponseType: ErrorResponseType.Type
    ) -> AnyPublisher<ResponseType, ErrorResponseType>
    
    /// Performs a request and maps the response or error response
    /// - Parameters:
    /// - Parameter request: the request to perform
    ///   - responseType: the type of the response to map to
    ///   - errorResponseType: the type of the error response to map to
    func perform<ResponseType: Decodable, ErrorResponseType: ErrorResponseConvertible>(
        request: NetworkRequest,
        responseType: ResponseType.Type,
        errorResponseType: ErrorResponseType.Type
    ) -> AnyPublisher<ResponseType, ErrorResponseType>
    
    /// Performs a request and if there is content maps the response and always maps the error type
    /// - Parameters:
    ///   - responseType: the type of the response to map to
    ///   - errorResponseType: the type of the error response to map to
    func performOptional<ResponseType: Decodable, ErrorResponseType: ErrorResponseConvertible>(
        request: NetworkRequest,
        responseType: ResponseType.Type
    ) -> AnyPublisher<ResponseType?, ErrorResponseType>
    
    /// Performs a request and if there is content maps the response and returns any errors
    /// - Parameters:
    ///   - responseType: the type of the response to map to
    func performOptional<ResponseType: Decodable>(
        request: NetworkRequest,
        responseType: ResponseType.Type
    ) -> AnyPublisher<ResponseType?, NetworkCommunicatorError>
    
    /// Performs a request and if there is content maps the response and always maps the error type
    /// - Parameters:
    ///   - responseType: the type of the response to map to
    ///   - errorResponseType: the type of the error response to map to
    func performOptional<ResponseType: Decodable, ErrorResponseType: ErrorResponseConvertible>(
        request: NetworkRequest,
        responseType: ResponseType.Type,
        errorResponseType: ErrorResponseType.Type
    ) -> AnyPublisher<ResponseType?, ErrorResponseType>
}

extension NetworkAdapterAPI {
    
    // MARK: - NetworkAdapterRxAPI
    
    func perform(request: NetworkRequest) -> Completable {
        perform(
            request: request,
            responseType: EmptyNetworkResponse.self
        )
        .asObservable()
        .ignoreElements()
    }
    
    func perform<ErrorResponseType: ErrorResponseConvertible>(
        request: NetworkRequest,
        errorResponseType: ErrorResponseType.Type
    ) -> Completable {
        perform(
            request: request,
            responseType: EmptyNetworkResponse.self,
            errorResponseType: errorResponseType
        )
        .asObservable()
        .ignoreElements()
    }
    
    func perform<ResponseType: Decodable>(request: NetworkRequest) -> Single<ResponseType> {
        perform(request: request, responseType: ResponseType.self)
    }
    
    func perform<ResponseType: Decodable>(
        request: NetworkRequest,
        responseType: ResponseType.Type
    ) -> Single<ResponseType> {
        
        func performPublisher(
            request: NetworkRequest
        ) -> AnyPublisher<ResponseType, NetworkCommunicatorError> {
            perform(request: request)
        }
        
        return performPublisher(request: request)
            .asObservable()
            .take(1)
            .asSingle()
    }
    
    func perform<ResponseType: Decodable, ErrorResponseType: ErrorResponseConvertible>(
        request: NetworkRequest,
        errorResponseType: ErrorResponseType.Type
    ) -> Single<ResponseType> {
        perform(
            request: request,
            responseType: ResponseType.self,
            errorResponseType: errorResponseType
        )
    }
    
    func perform<ResponseType: Decodable, ErrorResponseType: ErrorResponseConvertible>(
        request: NetworkRequest,
        responseType: ResponseType.Type,
        errorResponseType: ErrorResponseType.Type
    ) -> Single<ResponseType> {
        
        func performPublisher(
            request: NetworkRequest
        ) -> AnyPublisher<ResponseType, ErrorResponseType> {
            perform(request: request)
        }
        
        return performPublisher(request: request)
            .asObservable()
            .take(1)
            .asSingle()
    }
    
    func performOptional<ResponseType: Decodable>(
        request: NetworkRequest,
        responseType: ResponseType.Type
    ) -> Single<ResponseType?> {
        
        func performOptionalPublisher(
            request: NetworkRequest
        ) -> AnyPublisher<ResponseType?, NetworkCommunicatorError> {
            performOptional(request: request, responseType: ResponseType.self)
        }

        return performOptionalPublisher(request: request)
            .asObservable()
            .take(1)
            .asSingle()
    }
    
    func performOptional<ResponseType: Decodable, ErrorResponseType: ErrorResponseConvertible>(
        request: NetworkRequest,
        responseType: ResponseType.Type,
        errorResponseType: ErrorResponseType.Type
    ) -> Single<ResponseType?> {
        
        func performOptionalPublisher(
            request: NetworkRequest
        ) -> AnyPublisher<ResponseType?, ErrorResponseType> {
            performOptional(request: request, responseType: ResponseType.self)
        }

        return performOptionalPublisher(request: request)
            .asObservable()
            .take(1)
            .asSingle()
    }
}

extension NetworkAdapterAPI {
    
    func perform<ResponseType: Decodable, ErrorResponseType: ErrorResponseConvertible>(
        request: NetworkRequest,
        responseType: ResponseType.Type
    ) -> AnyPublisher<ResponseType, ErrorResponseType> {
        perform(request: request)
    }
    
    func perform<ResponseType: Decodable>(
        request: NetworkRequest,
        responseType: ResponseType.Type
    ) -> AnyPublisher<ResponseType, NetworkCommunicatorError> {
        perform(request: request)
    }
    
    func perform<ResponseType: Decodable, ErrorResponseType: ErrorResponseConvertible>(
        request: NetworkRequest,
        errorResponseType: ErrorResponseType.Type
    ) -> AnyPublisher<ResponseType, ErrorResponseType> {
        perform(request: request)
    }
    
    func perform<ResponseType: Decodable, ErrorResponseType: ErrorResponseConvertible>(
        request: NetworkRequest,
        responseType: ResponseType.Type,
        errorResponseType: ErrorResponseType.Type
    ) -> AnyPublisher<ResponseType, ErrorResponseType> {
        perform(request: request)
    }
    
    func performOptional<ResponseType: Decodable, ErrorResponseType: ErrorResponseConvertible>(
        request: NetworkRequest,
        responseType: ResponseType.Type,
        errorResponseType: ErrorResponseType.Type
    ) -> AnyPublisher<ResponseType?, ErrorResponseType> {
        performOptional(request: request, responseType: responseType)
    }
}