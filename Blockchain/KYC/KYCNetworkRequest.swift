//
//  KYCNetworkRequest.swift
//  Blockchain
//
//  Created by Maurice A. on 7/30/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

/// Handles network requests for the KYC flow
final class KYCNetworkRequest {
    
    typealias TaskSuccess = (Data) -> Void
    typealias TaskFailure = (HTTPRequestError) -> Void

    private let timeoutInterval = TimeInterval(exactly: 30)!
    private var request: URLRequest

    // swiftlint:disable nesting
    struct KYCEndpoints {
        enum GET {
            case credentials
            case credentialsForProvider
            case healthCheck
            case listOfCountries
            case nextKYCMethod
            case users(userID: String)

            var path: String {
                switch self {
                case .credentials:
                    return "/kyc/credentials"
                case .credentialsForProvider:
                    return "/kyc/credentials/provider"
                case .healthCheck:
                    return "/healthz"
                case .listOfCountries:
                    return "/countries?filter=eea"
                case .nextKYCMethod:
                    return "/kyc/next-method"
                case .users(let userID):
                    return "/users/\(userID)"
                }
            }
        }

        enum POST: String {
            case registerUser = "/users"
            case verifications = "/verifications"
            case submitVerification = "/kyc/verifications"
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
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.timeoutInterval = timeoutInterval
    }

    /// HTTP GET Request
    @discardableResult convenience init(
        get url: KYCEndpoints.GET,
        taskSuccess: @escaping TaskSuccess,
        taskFailure: @escaping TaskFailure
    ) {
        self.init(url: URL(string: BlockchainAPI.shared.retailCoreUrl + url.path)!, httpMethod: "GET")
        send(taskSuccess: taskSuccess, taskFailure: taskFailure)
    }

    /// HTTP POST Request
    @discardableResult convenience init(
        post url: KYCEndpoints.POST,
        parameters: [String: String],
        taskSuccess: @escaping TaskSuccess,
        taskFailure: @escaping TaskFailure
    ) {
        self.init(url: URL(string: BlockchainAPI.shared.retailCoreUrl + url.rawValue)!, httpMethod: "POST")
        let postBody = parameters.reduce("", { initialResult, nextPartialResult in
            let delimeter = initialResult.count > 0 ? "&" : ""
            return "\(initialResult)\(delimeter)\(nextPartialResult.key)=\(nextPartialResult.value)"
        })
        let data = postBody.data(using: .utf8)
        request.httpBody = data
        request.addValue(String(describing: data?.count), forHTTPHeaderField: "Content-Length")
        request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        send(taskSuccess: taskSuccess, taskFailure: taskFailure)
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
            request.allHTTPHeaderFields = ["Content-Type":"application/json",
                                           "Accept": "application/json"]
            send(taskSuccess: taskSuccess, taskFailure: taskFailure)
        } catch let error {
            taskFailure(HTTPRequestClientError.failedRequest(description: error.localizedDescription))
            return
        }
    }

    // MARK: - Private Methods

    private func send(taskSuccess: @escaping TaskSuccess, taskFailure: @escaping TaskFailure) {
        let task = URLSession.shared.dataTask(with: request, completionHandler: { data, response, error in
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
                    guard mimeType == "application/json" else {
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
