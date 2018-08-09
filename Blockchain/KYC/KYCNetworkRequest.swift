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

    /*
     let kycUrl = BlockchainAPI.shared.kycCredentials
     guard let url = URL(string: kycUrl) else {
     fatalError("Failed to get kyc url from Bundle.")
     }
     */
    // TODO: read from .xcconfig
    fileprivate static let rootUrl = "https://api.dev.blockchain.info/nabu-app"
    private let timeoutInterval = TimeInterval(exactly: 30)!
    private var request: URLRequest

    // swiftlint:disable nesting
    struct KYCEndpoints {
        enum GET: String {
            case credentials = "/kyc/credentials"
            case credentialsForProvider = "/kyc/credentials/provider"
            case healthCheck = "/healthz"
            case listOfCountries = "/countries?filter=eea"
            case nextKYCMethod = "/kyc/next-method"
            case users, userDetails = "/users"
        }

        enum POST: String {
            case registerUser = "/users"
            case verifications = "/verifications"
            case submitVerification = "/kyc/verifications"
        }

        enum PUT {
            case updateMobileNumber(userId: String)
            case updateAddress(userId: String)

            var path: String {
                switch self {
                case let .updateMobileNumber(userId): return "/users/\(userId)/mobile"
                case let .updateAddress(userId): return "/users/\(userId)/address"
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
        self.init(url: URL(string: KYCNetworkRequest.rootUrl + url.rawValue)!, httpMethod: "GET")
        send(taskSuccess: taskSuccess, taskFailure: taskFailure)
    }

    /// HTTP POST Request
    @discardableResult convenience init(
        post url: KYCEndpoints.POST,
        parameters: [String: String],
        taskSuccess: @escaping TaskSuccess,
        taskFailure: @escaping TaskFailure
    ) {
        self.init(url: URL(string: KYCNetworkRequest.rootUrl + url.rawValue)!, httpMethod: "POST")
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
    @discardableResult convenience init(
        put url: KYCEndpoints.PUT,
        parameters: [String: String],
        taskSuccess: @escaping TaskSuccess,
        taskFailure: @escaping TaskFailure
    ) {
        self.init(url: URL(string: KYCNetworkRequest.rootUrl + url.path)!, httpMethod: "PUT")
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
