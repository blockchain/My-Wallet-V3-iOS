// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import DIKit
import NetworkKit
import RxSwift
import WalletPayloadKit

public enum CurrencyUpdateError: LocalizedError {
    case credentialsError(MissingCredentialsError)
    case clientError(NetworkError)
    case fetchError(SettingsServiceError)

    public var errorDescription: String? {
        switch self {
        case .credentialsError(let error):
            error.localizedDescription
        case .clientError(let error):
            error.localizedDescription
        case .fetchError(let error):
            error.localizedDescription
        }
    }
}

final class SettingsClient: SettingsClientAPI {
    /// Enumerates the API methods supported by the wallet settings endpoint.
    enum Method: String {
        case getInfo = "get-info"
        case verifyEmail = "verify-email"
        case verifySms = "verify-sms"
        case updateNotificationType = "update-notifications-type"
        case updateNotificationOn = "update-notifications-on"
        case updateSms = "update-sms"
        case updateEmail = "update-email"
        case updateBtcCurrency = "update-btc-currency"
        case updateCurrency = "update-currency"
        case updatePasswordHint = "update-password-hint1"
        case updateAuthType = "update-auth-type"
        case updateBlockTorIps = "update-block-tor-ips"
        case updateLastTxTime = "update-last-tx-time"
    }

    // MARK: - Private Properties

    private let apiCode: String
    private let networkAdapter: NetworkAdapterAPI

    // MARK: - Setup

    init(
        apiCode: String = BlockchainAPI.Parameters.apiCode,
        networkAdapter: NetworkAdapterAPI = resolve()
    ) {
        self.apiCode = apiCode
        self.networkAdapter = networkAdapter
    }

    /// Fetches the wallet settings from the backend.
    /// - Parameter guid: The wallet identifier that must be valid.
    /// - Parameter sharedKey: A shared key that must be valid.
    /// - Returns: a `Single` that wraps a `SettingsResponse`.
    func settings(
        by guid: String,
        sharedKey: String
    ) -> AnyPublisher<SettingsResponse, NetworkError> {
        let url = URL(string: BlockchainAPI.shared.walletSettingsUrl)!
        let payload = SettingsRequest(
            method: Method.getInfo.rawValue,
            guid: guid,
            sharedKey: sharedKey,
            apiCode: apiCode
        )
        let data = try? JSONEncoder().encode(payload)
        let request = NetworkRequest(
            endpoint: url,
            method: .post,
            body: data,
            contentType: .formUrlEncoded
        )
        return networkAdapter.perform(request: request)
    }

    /// Updates the last tx time.
    /// - Parameter guid: The wallet identifier that must be valid.
    /// - Parameter sharedKey: A shared key that must be valid.
    /// - Returns: a `Completable`.
    func updateLastTransactionTime(
        guid: String,
        sharedKey: String
    ) -> AnyPublisher<Void, NetworkError> {
        let currentTime = "\(Int(Date().timeIntervalSince1970))"
        return update(
            guid: guid,
            sharedKey: sharedKey,
            method: .updateLastTxTime,
            payload: currentTime
        )
        .mapToVoid()
    }

    func update(
        currency: String,
        context: FlowContext,
        guid: String,
        sharedKey: String
    ) -> AnyPublisher<Void, NetworkError> {
        update(
            guid: guid,
            sharedKey: sharedKey,
            method: .updateCurrency,
            payload: currency,
            context: context
        )
        .mapToVoid()
    }

    func updatePublisher(
        currency: String,
        context: FlowContext,
        guid: String,
        sharedKey: String
    ) -> AnyPublisher<Void, CurrencyUpdateError> {
        update(
            guid: guid,
            sharedKey: sharedKey,
            method: .updateCurrency,
            payload: currency,
            context: context
        )
        .mapToVoid()
        .mapError(CurrencyUpdateError.clientError)
        .eraseToAnyPublisher()
    }

    /// Updates the user's email.
    /// - Parameter email: The email value.
    /// - Parameter context: The context in which the update is happening.
    /// - Parameter guid: The wallet identifier that must be valid.
    /// - Parameter sharedKey: A shared key that must be valid.
    /// - Returns: a `Completable`.
    func update(
        email: String,
        context: FlowContext?,
        guid: String,
        sharedKey: String
    ) -> AnyPublisher<String, NetworkError> {
        update(
            guid: guid,
            sharedKey: sharedKey,
            method: .updateEmail,
            payload: email,
            context: context
        )
    }

    /// Updates the sms number
    /// - Parameter smsNumber: The mobile number value.
    /// - Parameter context: The context in which the update is happening.
    /// - Parameter guid: The wallet identifier that must be valid.
    /// - Parameter sharedKey: A shared key that must be valid.
    /// - Returns: a `Completable`.
    func update(
        smsNumber: String,
        context: FlowContext?,
        guid: String,
        sharedKey: String
    ) -> AnyPublisher<Void, NetworkError> {
        update(
            guid: guid,
            sharedKey: sharedKey,
            method: .updateSms,
            payload: smsNumber,
            context: context
        )
        .mapToVoid()
    }

    func emailNotifications(
        enabled: Bool,
        guid: String,
        sharedKey: String
    ) -> AnyPublisher<Void, NetworkError> {
        update(
            guid: guid,
            sharedKey: sharedKey,
            method: .updateNotificationType,
            payload: enabled ? "1" : "0"
        )
        .mapToVoid()
        .flatMap { _ in
            self.update(
                guid: guid,
                sharedKey: sharedKey,
                method: .updateNotificationOn,
                payload: enabled ? "1" : "0"
            )
            .mapToVoid()
        }
        .eraseToAnyPublisher()
    }

    func verifySMS(
        code: String,
        guid: String,
        sharedKey: String
    ) -> AnyPublisher<Void, NetworkError> {
        update(
            guid: guid,
            sharedKey: sharedKey,
            method: .verifySms,
            payload: code
        )
        .mapToVoid()
    }

    func smsTwoFactorAuthentication(
        enabled: Bool,
        guid: String,
        sharedKey: String
    ) -> AnyPublisher<Void, NetworkError> {
        update(
            guid: guid,
            sharedKey: sharedKey,
            method: .updateAuthType,
            payload: enabled ? "5" : "0"
        )
        .mapToVoid()
    }

    /// A generic update method that is able to update email, mobile number, etc.
    /// - Parameter guid: The wallet identifier that must be valid.
    /// - Parameter sharedKey: A shared key that must be valid.
    /// - Parameter method: A method indicating the updated user information.
    /// - Parameter payload: A raw payload associated with the type of updated content.
    /// - Parameter context: The context in which the update is happening.
    /// - Returns: a `Completable`.
    private func update(
        guid: String,
        sharedKey: String,
        method: Method,
        payload: String,
        context: FlowContext? = nil
    ) -> AnyPublisher<String, NetworkError> {
        networkAdapter.perform(
            request: request(
                guid: guid,
                sharedKey: sharedKey,
                method: method,
                payload: payload,
                context: context
            )
        )
    }
}

extension SettingsClient {

    private func request(
        guid: String,
        sharedKey: String,
        method: Method,
        payload: String,
        context: FlowContext? = nil
    ) -> NetworkRequest {
        let url = URL(string: BlockchainAPI.shared.walletSettingsUrl)!
        let requestPayload = SettingsRequest(
            method: method.rawValue,
            guid: guid,
            sharedKey: sharedKey,
            apiCode: apiCode,
            payload: payload,
            length: "\(payload.count)",
            format: SettingsRequest.Formats.plain,
            context: context?.rawValue
        )
        let data = try? JSONEncoder().encode(requestPayload)
        return NetworkRequest(
            endpoint: url,
            method: .post,
            body: data,
            contentType: .formUrlEncoded
        )
    }
}
