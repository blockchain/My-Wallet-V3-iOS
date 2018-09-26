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
            case credentialsForOnfido
            case healthCheck
            case listOfCountries
            case nextKYCMethod
            case currentUser

            var pathComponents: [String] {
                switch self {
                case .credentials:
                    return ["kyc", "credentials"]
                case .credentialsForOnfido:
                    return ["kyc", "credentials", "onfido"]
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
                     .credentialsForOnfido,
                     .healthCheck,
                     .listOfCountries,
                     .nextKYCMethod,
                     .currentUser:
                    return nil
                }
            }
        }

        enum POST {
            case createUser
            case country
            case sessionToken(userId: String)
            case verifications
            case submitVerification

            var path: String {
                switch self {
                case .createUser: return "/users"
                case .country: return "/users/current/country"
                case .sessionToken: return "/auth"
                case .verifications: return "/verifications"
                case .submitVerification: return "/kyc/verifications"
                }
            }

            var queryParameters: [String: String]? {
                switch self {
                case .sessionToken(let userId):
                    return ["userId": userId]
                case .createUser,
                     .country,
                     .verifications,
                     .submitVerification:
                        return nil
                }
            }
        }

        enum PUT {
            case updateAddress
            case updateUserDetails
            case updateWalletInformation

            var path: String {
                switch self {
                case .updateUserDetails:
                    return "/users/current"
                case .updateAddress:
                    return "/users/current/address"
                case .updateWalletInformation:
                    return "/users/current/walletInfo"
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
            Logger.shared.debug("POST body: \(String(data: body, encoding: .utf8) ?? "")")
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
        headers: [String: String]? = nil,
        taskSuccess: @escaping TaskSuccess,
        taskFailure: @escaping TaskFailure
    ) {
        self.init(url: URL(string: BlockchainAPI.shared.retailCoreUrl + url.path)!, httpMethod: "PUT")
        do {
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .formatted(DateFormatter.birthday)

            let body = try encoder.encode(parameters)
            Logger.shared.debug("PUT body: \(String(data: body, encoding: .utf8) ?? "")")
            request.httpBody = body

            var allHeaders = [
                HttpHeaderField.accept: HttpHeaderValue.json,
                HttpHeaderField.contentType: HttpHeaderValue.json
            ]
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

    // MARK: - Private Methods

    private func send(taskSuccess: @escaping TaskSuccess, taskFailure: @escaping TaskFailure) {
        Logger.shared.debug("Sending \(request.httpMethod ?? "") request to '\(request.url?.absoluteString ?? "")'")
        let task = NetworkManager.shared.session.dataTask(with: request, completionHandler: { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    taskFailure(HTTPRequestClientError.failedRequest(description: error.localizedDescription)); return
                }
                guard let httpResponse = response as? HTTPURLResponse else {
                    taskFailure(HTTPRequestServerError.badResponse); return
                }
                guard let responseData = data else {
                    taskFailure(HTTPRequestPayloadError.emptyData); return
                }

                // Debugging
                if let responseString = String(data: responseData, encoding: .utf8) {
                    Logger.shared.debug("Response received: \(responseString)")
                }

                guard (200...299).contains(httpResponse.statusCode) else {
                    let errorPayload = try? JSONDecoder().decode(NabuNetworkError.self, from: responseData)
                    taskFailure(HTTPRequestServerError.badStatusCode(code: httpResponse.statusCode, error: errorPayload)); return
                }
                if let mimeType = httpResponse.mimeType {
                    guard mimeType == HttpHeaderValue.json else {
                        taskFailure(HTTPRequestPayloadError.invalidMimeType(type: mimeType)); return
                    }
                }
                taskSuccess(responseData)
            }
        })
        task.resume()
    }
}

// MARK: Rx Extensions

extension KYCNetworkRequest {
    static func request<RequestPayload: Encodable>(
        put url: KYCNetworkRequest.KYCEndpoints.PUT,
        parameters: RequestPayload,
        headers: [String: String]? = nil
    ) -> Completable {
        return Completable.create(subscribe: { observer -> Disposable in
            KYCNetworkRequest(put: url, parameters: parameters, headers: headers, taskSuccess: { _ in
                observer(.completed)
            }, taskFailure: {
                observer(.error($0))
            })
            return Disposables.create()
        })
    }

    static func request<ResponseType: Decodable>(
        put url: KYCNetworkRequest.KYCEndpoints.PUT,
        parameters: [String: String],
        headers: [String: String]? = nil,
        type: ResponseType.Type
    ) -> Single<ResponseType> {
        return Single.create(subscribe: { observer -> Disposable in
            KYCNetworkRequest(put: url, parameters: parameters, headers: headers, taskSuccess: { responseData in
                do {
                    let response = try JSONDecoder().decode(type.self, from: responseData)
                    observer(.success(response))
                } catch {
                    observer(.error(error))
                }
            }, taskFailure: {
                observer(.error($0))
            })
            return Disposables.create()
        })
    }

    static func request(
        post url: KYCNetworkRequest.KYCEndpoints.POST,
        parameters: [String: String],
        headers: [String: String]? = nil
    ) -> Completable {
        return Completable.create(subscribe: { observer -> Disposable in
            KYCNetworkRequest(post: url, parameters: parameters, headers: headers, taskSuccess: { _ in
                observer(.completed)
            }, taskFailure: {
                observer(.error($0))
            })
            return Disposables.create()
        })
    }

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
