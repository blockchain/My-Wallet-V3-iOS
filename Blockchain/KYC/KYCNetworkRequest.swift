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

    fileprivate let rootUrl = "https://api.dev.blockchain.info/nabu-app"
    private let timeoutInterval = TimeInterval(exactly: 30)!

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

        enum PUT: String {
            case updateUserDetails = "/users"
        }
    }
    // swiftlint:enable nesting

    // MARK: - Initialization

    /// HTTP GET Request
    init(get url: KYCEndpoints.GET, success: @escaping TaskSuccess, error: @escaping TaskFailure) {
        var request = URLRequest(url: URL(string: rootUrl + url.rawValue)!)
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.timeoutInterval = timeoutInterval
        doTask(with: request, success, error)
    }

    /// HTTP POST Request
    init(post url: KYCEndpoints.POST, parameters: [String: String], success: @escaping TaskSuccess, error: @escaping TaskFailure) {
        let postBody = parameters.reduce("", { initialResult, nextPartialResult in
            let delimeter = initialResult.count > 0 ? "&" : ""
            return "\(initialResult)\(delimeter)\(nextPartialResult.key)=\(nextPartialResult.value)"
        })
        let data = postBody.data(using: .utf8)
        var request = URLRequest(url: URL(string: rootUrl + url.rawValue)!)
        request.httpMethod = "POST"
        request.httpBody = data
        request.timeoutInterval = timeoutInterval
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue(String(describing: data?.count), forHTTPHeaderField: "Content-Length")
        request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        doTask(with: request, success, error)
    }

    /// HTTP PUT Request
    init(put url: KYCEndpoints.PUT, parameters: [String: String], success: @escaping TaskSuccess, error: @escaping TaskFailure) {
        // TODO: implement method body
    }

    // MARK: - Private Methods

    private func doTask(with request: URLRequest, _ taskSuccess: @escaping TaskSuccess, _ taskFailure: @escaping TaskFailure) {
        let task = URLSession.shared.dataTask(with: request, completionHandler: { data, response, error in
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
        })
        task.resume()
    }
}
