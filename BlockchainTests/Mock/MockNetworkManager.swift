//
//  MockNetworkManager.swift
//  BlockchainTests
//
//  Created by Chris Arriola on 6/1/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation
import RxSwift

class MockNetworkManager: NetworkManager {

    private static let mockUrlString = "http://testurl.com"

    private var mockResponse: (HTTPURLResponse, Any)?

    // MARK: - Test Methods

    func mockRequestJsonOrStringResponse(_ response: (HTTPURLResponse, Any)) {
        mockResponse = response
    }

    func mockHTTPURLResponse(
        statusCode: Int = 400,
        urlString: String = MockNetworkManager.mockUrlString
    ) -> HTTPURLResponse {
        let url = URL(string: urlString)!
        return HTTPURLResponse(url: url, statusCode: statusCode, httpVersion: nil, headerFields: nil)!
    }

    // MARK: - Overriden Methods

    override func requestJsonOrString(
        _ url: String,
        method: HttpMethod,
        parameters: URLParameters? = nil,
        headers: [String: String]? = nil
    ) -> Single<(HTTPURLResponse, Any)> {
        guard let mockResponse = mockResponse else {
            print("No mock response set, performing actual network call")
            return super.requestJsonOrString(url, method: method, parameters: parameters)
        }
        return Single.just(mockResponse)
    }

}
