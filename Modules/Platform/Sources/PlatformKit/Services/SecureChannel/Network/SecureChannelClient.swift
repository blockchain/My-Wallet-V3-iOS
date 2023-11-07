// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import DIKit
import NetworkKit
import RxSwift

/// Secure Channel network service
final class SecureChannelClient {

    // MARK: - Types

    private struct SendMessageResponse: Decodable {
        let success: Bool
    }

    private struct GetIpResponse: Decodable {
        let ip: String
    }

    // MARK: - Properties

    private let networkAdapter: NetworkAdapterAPI
    private let requestBuilder: RequestBuilder

    // MARK: - Setup

    init(
        networkAdapter: NetworkAdapterAPI = resolve(tag: DIKitContext.wallet),
        requestBuilder: RequestBuilder = resolve(tag: DIKitContext.wallet)
    ) {
        self.networkAdapter = networkAdapter
        self.requestBuilder = requestBuilder
    }
}

// MARK: - SecureChannelClientAPI

extension SecureChannelClient: SecureChannelClientAPI {

    private func sendMessageRequest(msg: SecureChannel.PairingResponse) -> NetworkRequest? {
        let encoded = try? JSONEncoder().encode(msg)
        let serialised = String(data: encoded!, encoding: .utf8)!
        return requestBuilder.post(
            path: ["wallet"],
            parameters: [
                URLQueryItem(name: "method", value: "send-secure-channel"),
                URLQueryItem(name: "payload", value: serialised),
                URLQueryItem(name: "length", value: "\(serialised.count)"),
                URLQueryItem(name: "api_code", value: BlockchainAPI.Parameters.apiCode)
            ]
        )
    }

    func sendMessage(
        msg: SecureChannel.PairingResponse
    ) -> AnyPublisher<Void, SendSecureChannelError> {
        guard let request = sendMessageRequest(msg: msg) else {
            return Fail(error: .networkFailure).eraseToAnyPublisher()
        }
        return networkAdapter.perform(request: request)
            .mapError { _ in SendSecureChannelError.networkFailure }
            .flatMap { (response: SendMessageResponse) -> AnyPublisher<Void, SendSecureChannelError> in
                if !response.success {
                    Fail(error: SendSecureChannelError.networkFailure)
                        .eraseToAnyPublisher()
                } else {
                    Just(())
                        .setFailureType(to: SendSecureChannelError.self)
                        .eraseToAnyPublisher()
                }
            }
            .eraseToAnyPublisher()
    }

    private func getIPRequest() -> NetworkRequest? {
        requestBuilder.get(
            path: ["wallet", "get-ip"]
        )
    }

    func getIp() -> AnyPublisher<String, SendSecureChannelError> {
        guard let request = getIPRequest() else {
            return Fail(error: .networkFailure).eraseToAnyPublisher()
        }
        return networkAdapter.perform(request: request)
            .mapError { _ in SendSecureChannelError.networkFailure }
            .map { (response: GetIpResponse) -> String in
                response.ip
            }
            .eraseToAnyPublisher()
    }
}
