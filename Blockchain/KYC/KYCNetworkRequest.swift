//
//  KYCNetworkRequest.swift
//  Blockchain
//
//  Created by Maurice A. on 7/30/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift

/// Handles network requests for the KYC flow
final class KYCNetworkRequest {
    
    typealias TaskSuccess = (Data) -> Void
    typealias TaskFailure = (HTTPRequestError) -> Void

    fileprivate static let rootUrl = BlockchainAPI.shared.apiUrl
    private let timeoutInterval = TimeInterval(exactly: 30)!
    private var request: URLRequest!

    // swiftlint:disable nesting
    struct KYCEndpoints {
        enum GET {
            case credentials
            case credentialsForProvider
            case healthCheck
            case listOfCountries
            case nextKYCMethod
            case currentUser

            var pathComponents: [String] {
                switch self {
                case .credentials:
                    return ["kyc", "credentials"]
                case .credentialsForProvider:
                    return ["kyc", "credentials", "provider"]
                case .healthCheck:
                    return ["healthz"]
                case .listOfCountries:
                    return ["countries"]
                case .nextKYCMethod:
                    return ["kyc", "next-method"]
                case .currentUser:
                    return ["users", "current"]
                }
            }

            var parameters: [String: String]? {
                switch self {
                case .credentials,
                     .credentialsForProvider,
                     .healthCheck,
                     .listOfCountries,
                     .nextKYCMethod,
                     .currentUser:
                    return nil
                }
            }
        }

        enum POST {
            case registerUser
            case apiKey(userId: String)
            case sessionToken(userId: String)
            case verifications
            case submitVerification

            var path: String {
                switch self {
                case .registerUser: return "/internal/users"
                case .apiKey: return "/internal/auth"
                case .sessionToken: return "/auth"
                case .verifications: return "/verifications"
                case .submitVerification: return "/kyc/verifications"
                }
            }

            var queryParameters: [String: String]? {
                switch self {
                case .apiKey(let userId),
                     .sessionToken(let userId):
                    return ["userId": userId]
                case .registerUser,
                     .verifications,
                     .submitVerification:
                        return nil
                }
            }
        }

        enum PUT {
            case updateUserDetails(userId: String)
            case updateMobileNumber(userId: String)
            case updateAddress(userId: String)

            var path: String {
                switch self {
                case .updateUserDetails(let userID):
                    return "/users/\(userID)"
                case .updateMobileNumber(let userId):
                    return "/users/\(userId)/mobile"
                case .updateAddress(let userId):
                    return "/users/\(userId)/address"
                }
            }
        }
    }
    // swiftlint:enable nesting

    // MARK: - Initialization

    private init(url: URL, httpMethod: String) {
        self.request = URLRequest(url: url)
        request.httpMethod = httpMethod
        request.addValue(HttpHeaderValue.json, forHTTPHeaderField: HttpHeaderField.accept)
        request.timeoutInterval = timeoutInterval
    }

    /// HTTP GET Request
    @discardableResult convenience init?(
        get url: KYCEndpoints.GET,
        headers: [String: String]? = nil,
        taskSuccess: @escaping TaskSuccess,
        taskFailure: @escaping TaskFailure
    ) {
        guard let base = URL(string: BlockchainAPI.shared.retailCoreUrl) else { return nil }
        guard let endpoint = URL.endpoint(
            base,
            pathComponents: url.pathComponents,
            queryParameters: url.parameters
        ) else { return nil }
        self.init(url: endpoint, httpMethod: "GET")
        request.allHTTPHeaderFields = headers
        send(taskSuccess: taskSuccess, taskFailure: taskFailure)
    }

    /// HTTP POST Request
    @discardableResult convenience init?(
        post url: KYCEndpoints.POST,
        parameters: [String: String],
        headers: [String: String]? = nil,
        taskSuccess: @escaping TaskSuccess,
        taskFailure: @escaping TaskFailure
    ) {
        guard let base = URL(string: BlockchainAPI.shared.retailCoreUrl + url.path) else { return nil }
        guard let endpoint = URL.endpoint(base, pathComponents: nil, queryParameters: url.queryParameters) else { return nil }
        self.init(url: endpoint, httpMethod: "POST")
        do {
            let body = try JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted)
            request.httpBody = body

            var allHeaders = [HttpHeaderField.contentType: HttpHeaderValue.json]
            if let headers = headers {
                for (headerKey, headerValue) in headers {
                    allHeaders[headerKey] = headerValue
                }
            }
            request.allHTTPHeaderFields = allHeaders

            send(taskSuccess: taskSuccess, taskFailure: taskFailure)
        } catch let error {
            taskFailure(HTTPRequestClientError.failedRequest(description: error.localizedDescription))
            return
        }
    }

    /// HTTP PUT Request
    @discardableResult convenience init<T: Encodable>(
        put url: KYCEndpoints.PUT,
        parameters: T,
        taskSuccess: @escaping TaskSuccess,
        taskFailure: @escaping TaskFailure
    ) {
        self.init(url: URL(string: BlockchainAPI.shared.retailCoreUrl + url.path)!, httpMethod: "PUT")
        do {
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .formatted(DateFormatter.birthday)
            let body = try encoder.encode(parameters)
            request.httpBody = body
            request.allHTTPHeaderFields = [
                HttpHeaderField.contentType: HttpHeaderValue.json,
                HttpHeaderField.accept: HttpHeaderValue.json
            ]
            send(taskSuccess: taskSuccess, taskFailure: taskFailure)
        } catch let error {
            taskFailure(HTTPRequestClientError.failedRequest(description: error.localizedDescription))
            return
        }
    }

    // MARK: - Private Methods

    private func send(taskSuccess: @escaping TaskSuccess, taskFailure: @escaping TaskFailure) {
        // Use URLSession.shared instead of NetworkManager.shared.session for debugging on dev
        let task = NetworkManager.shared.session.dataTask(with: request, completionHandler: { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    taskFailure(HTTPRequestClientError.failedRequest(description: error.localizedDescription)); return
                }
                guard let httpResponse = response as? HTTPURLResponse else {
                    taskFailure(HTTPRequestServerError.badResponse); return
                }
                guard (200...299).contains(httpResponse.statusCode) else {
                    taskFailure(HTTPRequestServerError.badStatusCode(code: httpResponse.statusCode)); return
                }
                if let mimeType = httpResponse.mimeType {
                    guard mimeType == HttpHeaderValue.json else {
                        taskFailure(HTTPRequestPayloadError.invalidMimeType(type: mimeType)); return
                    }
                }
                guard let responseData = data else {
                    taskFailure(HTTPRequestPayloadError.emptyData); return
                }
                taskSuccess(responseData)
            }
        })
        task.resume()
    }
}

// MARK: Rx Extensions

extension KYCNetworkRequest {
    static func request<ResponseType: Decodable>(
        post url: KYCNetworkRequest.KYCEndpoints.POST,
        parameters: [String: String],
        headers: [String: String]? = nil,
        type: ResponseType.Type
    ) -> Single<ResponseType> {
        return Single.create(subscribe: { observer -> Disposable in
            KYCNetworkRequest(post: url, parameters: parameters, headers: headers, taskSuccess: { responseData in
                do {
                    let response = try JSONDecoder().decode(type.self, from: responseData)
                    observer(.success(response))
                } catch {
                    observer(.error(error))
                }
            }, taskFailure: { error in
                observer(.error(error))
            })
            return Disposables.create()
        })
    }

    static func request<ResponseType: Decodable>(
        get url: KYCNetworkRequest.KYCEndpoints.GET,
        headers: [String: String]? = nil,
        type: ResponseType.Type
    ) -> Single<ResponseType> {
        return Single.create(subscribe: { observer -> Disposable in
            KYCNetworkRequest(get: url, headers: headers, taskSuccess: { responseData in
                do {
                    let response = try JSONDecoder().decode(type.self, from: responseData)
                    observer(.success(response))
                } catch {
                    observer(.error(error))
                }
            }, taskFailure: { error in
                observer(.error(error))
            })
            return Disposables.create()
        })
    }
}
