// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import DIKit
import ToolKit
import WalletPayloadKit

final class WalletPayloadService: WalletPayloadServiceAPI {

    // MARK: - Properties

    private let repository: WalletPayloadRepositoryAPI
    private let walletRepo: WalletRepoAPI
    private let credentialsRepository: CredentialsRepositoryAPI

    // MARK: - Setup

    init(
        repository: WalletPayloadRepositoryAPI,
        walletRepo: WalletRepoAPI,
        credentialsRepository: CredentialsRepositoryAPI
    ) {
        self.repository = repository
        self.walletRepo = walletRepo
        self.credentialsRepository = credentialsRepository
    }

    func requestUsingSessionToken() -> AnyPublisher<WalletAuthenticatorType, WalletPayloadServiceError> {
        let request = request(guid:sessionToken:)
        return walletRepo
            .credentials
            .first()
            .flatMap { credentials -> AnyPublisher<(guid: String, sessionToken: String), WalletPayloadServiceError> in
                guard !credentials.guid.isEmpty else {
                    return .failure(.missingCredentials(.guid))
                }
                guard !credentials.sessionToken.isEmpty else {
                    return .failure(.missingCredentials(.sessionToken))
                }
                return .just((credentials.guid, credentials.sessionToken))
            }
            .flatMap { credentials -> AnyPublisher<WalletAuthenticatorType, WalletPayloadServiceError> in
                request(credentials.guid, credentials.sessionToken)
            }
            .eraseToAnyPublisher()
    }

    func requestUsingSharedKey() -> AnyPublisher<Void, WalletPayloadServiceError> {
        let request = request(guid:sharedKey:)
        return credentialsRepository
            .credentials
            .first()
            .mapError(WalletPayloadServiceError.missingCredentials)
            .flatMap { credentials -> AnyPublisher<Void, WalletPayloadServiceError> in
                request(credentials.guid, credentials.sharedKey)
            }
            .eraseToAnyPublisher()
    }

    func request(
        guid: String,
        sharedKey: String
    ) -> AnyPublisher<Void, WalletPayloadServiceError> {
        let cacheWalletData = cacheWalletData(from:)
        return repository
            .payload(guid: guid, identifier: .sharedKey(sharedKey))
            .flatMap { payload -> AnyPublisher<Void, WalletPayloadServiceError> in
                cacheWalletData(payload)
                    .mapToVoid()
            }
            .eraseToAnyPublisher()
    }

    func request(
        guid: String,
        sessionToken: String
    ) -> AnyPublisher<WalletAuthenticatorType, WalletPayloadServiceError> {
        let cacheWalletData = cacheWalletData(from:)
        return repository
            .payload(guid: guid, identifier: .sessionToken(sessionToken))
            .flatMap { payload -> AnyPublisher<WalletPayload, WalletPayloadServiceError> in
                cacheWalletData(payload)
            }
            .flatMap { payload -> AnyPublisher<WalletAuthenticatorType, WalletPayloadServiceError> in
                guard let type = WalletAuthenticatorType(rawValue: payload.authType) else {
                    return .failure(.unsupported2FAType)
                }
                return .just(type)
            }
            .catch { error -> AnyPublisher<WalletAuthenticatorType, WalletPayloadServiceError> in
                switch error {
                case .emailAuthorizationRequired:
                    .just(.email)
                default:
                    .failure(error)
                }
            }
            .eraseToAnyPublisher()
    }

    private func cacheWalletData(
        from payload: WalletPayload
    ) -> AnyPublisher<WalletPayload, WalletPayloadServiceError> {
        // cache essentials
        walletRepo.set(keyPath: \.credentials.guid, value: payload.guid)
        walletRepo.set(keyPath: \.properties.language, value: payload.language)
        walletRepo.set(keyPath: \.properties.syncPubKeys, value: payload.shouldSyncPubKeys)
        guard let authenticatorType = WalletAuthenticatorType(rawValue: payload.authType) else {
            // fail on unkonwn auth type
            return .failure(.unsupported2FAType)
        }
        walletRepo.set(keyPath: \.properties.authenticatorType, value: authenticatorType)
        // payload might be missing when we haven't fully authenticated, eg 2FA required
        // we still save `WalletPayload` and will update the inner wrapper on `TwoFAWalletService`
        return walletRepo.set(keyPath: \.walletPayload, value: payload)
            .get()
            .mapError(to: WalletPayloadServiceError.self)
            .map { _ in payload }
            .eraseToAnyPublisher()
    }
}
