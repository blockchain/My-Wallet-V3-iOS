// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import Foundation
import NetworkKit
import ToolKit
import WalletPayloadKit

protocol CreateWalletClientAPI {
    func createWallet(
        email: String,
        payload: WalletCreationPayload,
        recaptchaToken: String?,
        siteKey: String
    ) -> AnyPublisher<Void, NetworkError>
}

final class CreateWalletClient: CreateWalletClientAPI {
    private let networkAdapter: NetworkAdapterAPI
    private let requestBuilder: RequestBuilder
    private let apiCodeProvider: () -> String

    init(
        networkAdapter: NetworkAdapterAPI,
        requestBuilder: RequestBuilder,
        apiCodeProvider: @escaping () -> String
    ) {
        self.networkAdapter = networkAdapter
        self.requestBuilder = requestBuilder
        self.apiCodeProvider = apiCodeProvider
    }

    func createWallet(
        email: String,
        payload: WalletCreationPayload,
        recaptchaToken: String?,
        siteKey: String
    ) -> AnyPublisher<Void, NetworkError> {
        var parameters = provideDefaultParameters(
            with: email,
            time: Int(Date().timeIntervalSince1970 * 1000.0)
        )
        if let recaptchaToken {
            parameters.append(
                URLQueryItem(
                    name: "captcha",
                    value: recaptchaToken
                )
            )
            parameters.append(
                URLQueryItem(
                    name: "siteKey",
                    value: siteKey
                )
            )
        }

        let wrapperParameters = provideWrapperParameters(from: payload)
        let body = RequestBuilder.body(from: parameters + wrapperParameters)
        let request = requestBuilder.post(
            path: ["wallet"],
            body: body,
            headers: [:],
            contentType: .formUrlEncoded
        )!
        return networkAdapter.perform(request: request)
    }

    func provideDefaultParameters(with email: String, time: Int) -> [URLQueryItem] {
        [
            URLQueryItem(
                name: "method",
                value: "insert"
            ),
            URLQueryItem(
                name: "ct",
                value: String(time)
            ),
            URLQueryItem(
                name: "email",
                value: email
            ),
            URLQueryItem(
                name: "format",
                value: "plain"
            ),
            URLQueryItem(
                name: "api_code",
                value: apiCodeProvider()
            )
        ]
    }

    func provideWrapperParameters(from payload: WalletCreationPayload) -> [URLQueryItem] {
        [
            URLQueryItem(
                name: "guid",
                value: payload.guid
            ),
            URLQueryItem(
                name: "sharedKey",
                value: payload.sharedKey
            ),
            URLQueryItem(
                name: "checksum",
                value: payload.checksum
            ),
            URLQueryItem(
                name: "language",
                value: payload.language
            ),
            URLQueryItem(
                name: "length",
                value: String(payload.length)
            ),
            URLQueryItem(
                name: "old_checksum",
                value: payload.oldChecksum
            ),
            URLQueryItem(
                name: "payload",
                value: String(decoding: payload.innerPayload, as: UTF8.self)
            )
        ]
    }
}
