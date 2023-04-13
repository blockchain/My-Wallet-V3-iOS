// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainNamespace
import Combine
import DIKit
import Foundation
import NetworkKit
import ToolKit
import WalletPayloadKit

public protocol NabuAuthenticationExecutorAPI {
    /// Runs authentication flow if needed and passes it to the `networkResponsePublisher`
    /// - Parameter networkResponsePublisher: the closure taking a token and returning a publisher for a request
    func authenticate(
        _ networkResponsePublisher: @escaping NetworkResponsePublisher
    ) -> AnyPublisher<ServerResponse, NetworkError>
}

public typealias NabuAuthenticationExecutorProvider = () -> NabuAuthenticationExecutorAPI
public typealias NabuUserEmailProvider = () -> AnyPublisher<String, Error>
public typealias CheckAuthenticated = (NetworkError) -> AnyPublisher<Bool, Never>

public enum NabuAuthenticationExecutorError: Error {
    case failedToCreateUser(NetworkError)
    case failedToRetrieveJWTToken(JWTServiceError)
    case failedToRecoverUser(NetworkError)
    case failedToFetchEmail(Error)
    case failedToGetSessionToken(NetworkError)
    case sessionTokenFetchTimedOut
    case missingCredentials(MissingCredentialsError)
    case failedToSaveOfflineToken(CredentialWritingError)
    case communicatorError(NetworkError)
}

struct NabuAuthenticationExecutor: NabuAuthenticationExecutorAPI {

    private struct Token {
        let sessionToken: NabuSessionToken
        let offlineToken: NabuOfflineToken
    }

    private let app: AppProtocol
    private let store: NabuTokenRepositoryAPI
    private let errorBroadcaster: UserAlreadyRestoredHandlerAPI
    private let credentialsRepository: CredentialsRepositoryAPI
    private let nabuOfflineTokenRepository: NabuOfflineTokenRepositoryAPI
    private let nabuRepository: NabuRepositoryAPI
    private let nabuUserEmailProvider: NabuUserEmailProvider
    private let deviceInfo: DeviceInfo
    private let jwtService: JWTServiceAPI
    private let siftService: SiftServiceAPI
    private let checkAuthenticated: CheckAuthenticated
    private let queue: DispatchQueue

    private let fetchTokensPublisher: Atomic<AnyPublisher<Token, NabuAuthenticationExecutorError>?> = Atomic(nil)

    init(
        app: AppProtocol = resolve(),
        store: NabuTokenRepositoryAPI = resolve(),
        errorBroadcaster: UserAlreadyRestoredHandlerAPI = resolve(),
        nabuRepository: NabuRepositoryAPI = resolve(),
        nabuUserEmailProvider: @escaping NabuUserEmailProvider = resolve(),
        siftService: SiftServiceAPI = resolve(),
        checkAuthenticated: @escaping CheckAuthenticated = resolve(),
        jwtService: JWTServiceAPI = resolve(),
        credentialsRepository: CredentialsRepositoryAPI = resolve(),
        nabuOfflineTokenRepository: NabuOfflineTokenRepositoryAPI = resolve(),
        deviceInfo: DeviceInfo = resolve(),
        queue: DispatchQueue = DispatchQueue(
            label: "com.blockchain.NabuAuthenticationExecutor",
            qos: .background
        )
    ) {
        self.app = app
        self.store = store
        self.errorBroadcaster = errorBroadcaster
        self.nabuRepository = nabuRepository
        self.nabuUserEmailProvider = nabuUserEmailProvider
        self.siftService = siftService
        self.checkAuthenticated = checkAuthenticated
        self.credentialsRepository = credentialsRepository
        self.nabuOfflineTokenRepository = nabuOfflineTokenRepository
        self.jwtService = jwtService
        self.deviceInfo = deviceInfo
        self.queue = queue
    }

    func authenticate(
        _ networkResponsePublisher: @escaping NetworkResponsePublisher
    ) -> AnyPublisher<ServerResponse, NetworkError> {
        getToken()
            .mapError { error in
                NetworkError(request: nil, type: .authentication(error))
            }
            .flatMap { payload -> AnyPublisher<ServerResponse, NetworkError> in
                networkResponsePublisher(payload.sessionToken.token)
                    .catch { communicatorError -> AnyPublisher<ServerResponse, NetworkError> in
                        refreshOrReturnError(
                            communicatorError: communicatorError,
                            offlineToken: payload.offlineToken,
                            publisherProvider: networkResponsePublisher
                        )
                    }
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }

    // MARK: - Private methods

    private func getToken() -> AnyPublisher<Token, NabuAuthenticationExecutorError> {
        Publishers
            .Zip(
                store.sessionTokenPublisher.prefix(1).mapError(),
                retrieveOfflineTokenResponse()
            )
            .map { sessionToken, offlineToken
                -> (sessionToken: NabuSessionToken?, offlineToken: NabuOfflineToken) in
                (sessionToken: sessionToken, offlineToken: offlineToken)
            }
            .catch { _ -> AnyPublisher<(sessionToken: NabuSessionToken?, offlineToken: NabuOfflineToken), NabuAuthenticationExecutorError> in
                fetchTokens()
                    .map { token -> (sessionToken: NabuSessionToken?, offlineToken: NabuOfflineToken) in
                        (token.sessionToken, token.offlineToken)
                    }
                    .eraseToAnyPublisher()
            }
            .flatMap { payload -> AnyPublisher<Token, NabuAuthenticationExecutorError> in
                guard let token = payload.sessionToken else {
                    return fetchTokens()
                }
                return .just(Token(sessionToken: token, offlineToken: payload.offlineToken))
            }
            .eraseToAnyPublisher()
    }

    private func fetchTokens() -> AnyPublisher<Token, NabuAuthenticationExecutorError> {
        // Case A: We are already performing a token fetch, return current fetch publisher
        if let publisher = fetchTokensPublisher.value {
            return publisher
        }

        // Case B: We are not currently performing a token fetch, create a new fetch publisher
        let publisher = createFetchTokens()
            .handleEvents(receiveCompletion: { _ in
                // We are done fetching the token, reset state
                fetchTokensPublisher.mutate { $0 = nil }
            })
            .eraseToAnyPublisher()

        fetchTokensPublisher.mutate { $0 = publisher }

        return publisher
    }

    private func createFetchTokens() -> AnyPublisher<Token, NabuAuthenticationExecutorError> {
        createUserIfNeeded()
            .flatMap { offlineToken -> AnyPublisher<Token, NabuAuthenticationExecutorError> in
                currentToken(offlineToken: offlineToken)
                    .map { Token(sessionToken: $0, offlineToken: offlineToken) }
                    .eraseToAnyPublisher()
            }
            .shareReplay()
            .eraseToAnyPublisher()
    }

    private func currentToken(
        offlineToken: NabuOfflineToken
    ) -> AnyPublisher<NabuSessionToken, NabuAuthenticationExecutorError> {
        store.requiresRefresh
            .mapError()
            .flatMap { requiresRefresh -> AnyPublisher<NabuSessionToken, NabuAuthenticationExecutorError> in
                guard !requiresRefresh else {
                    return refreshToken(offlineToken: offlineToken)
                }
                return store
                    .sessionTokenPublisher
                    .prefix(1)
                    .mapError()
                    .flatMap { sessionToken
                        -> AnyPublisher<NabuSessionToken, NabuAuthenticationExecutorError> in
                        guard let sessionToken else {
                            return .failure(.missingCredentials(MissingCredentialsError.sessionToken))
                        }
                        return .just(sessionToken)
                    }
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }

    private func refreshOrReturnError(
        communicatorError: NetworkError,
        offlineToken: NabuOfflineToken,
        publisherProvider: @escaping (String) -> AnyPublisher<ServerResponse, NetworkError>
    ) -> AnyPublisher<ServerResponse, NetworkError> {
        checkAuthenticated(communicatorError)
            .mapError()
            .flatMap { unauthenticated -> AnyPublisher<Void, NetworkError> in
                guard unauthenticated else {
                    return .failure(communicatorError)
                }
                return clearAccessToken()
                    .mapError()
                    .eraseToAnyPublisher()
            }
            .flatMap { _ -> AnyPublisher<ServerResponse, NetworkError> in
                refreshToken(offlineToken: offlineToken)
                    .mapError { error in
                        NetworkError(request: nil, type: .authentication(error))
                    }
                    .flatMap { sessionToken -> AnyPublisher<ServerResponse, NetworkError> in
                        publisherProvider(sessionToken.token)
                    }
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }

    private func refreshToken(
        offlineToken: NabuOfflineToken
    ) -> AnyPublisher<NabuSessionToken, NabuAuthenticationExecutorError> {
        getSessionToken(offlineTokenResponse: offlineToken)
            .flatMap { sessionToken -> AnyPublisher<NabuSessionToken, Never> in
                store.store(sessionToken)
            }
            .catch { error -> AnyPublisher<NabuSessionToken, NabuAuthenticationExecutorError> in
                broadcastOrReturnError(error: error)
                    .ignoreOutput(setOutputType: NabuSessionToken.self)
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }

    private func clearAccessToken() -> AnyPublisher<Void, Never> {
        store
            .invalidate()
            .mapError()
            .eraseToAnyPublisher()
    }

    private func getSessionToken(
        offlineTokenResponse: NabuOfflineToken
    ) -> AnyPublisher<NabuSessionToken, NabuAuthenticationExecutorError> {

        let email = nabuUserEmailProvider()
            .mapError(NabuAuthenticationExecutorError.failedToFetchEmail)
            .eraseToAnyPublisher()

        let guid = credentialsRepository.guid
            .flatMap { guid -> AnyPublisher<String, NabuAuthenticationExecutorError> in
                guard let guid else {
                    return .failure(.missingCredentials(MissingCredentialsError.guid))
                }
                return .just(guid)
            }
            .eraseToAnyPublisher()

        return Publishers.Zip(email, guid)
            .flatMap { email, guid -> AnyPublisher<NabuSessionToken, NabuAuthenticationExecutorError> in
                nabuRepository
                    .sessionToken(
                        for: guid,
                        userToken: offlineTokenResponse.token,
                        userIdentifier: offlineTokenResponse.userId,
                        deviceId: deviceInfo.uuidString,
                        email: email
                    )
                    .mapError(NabuAuthenticationExecutorError.failedToGetSessionToken)
                    .eraseToAnyPublisher()
            }
            .handleEvents(receiveOutput: { nabuSessionTokenResponse in
                siftService.set(
                    userId: nabuSessionTokenResponse.userId
                )
            })
            .eraseToAnyPublisher()
    }

    private func broadcastOrReturnError(
        error: NabuAuthenticationExecutorError
    ) -> AnyPublisher<Void, NabuAuthenticationExecutorError> {
        guard case .failedToGetSessionToken(let networkError) = error else {
            return .failure(error)
        }
        return userAlreadyRestored(error: networkError)
            .setFailureType(to: NabuAuthenticationExecutorError.self)
            .broadcastErrorWithHint(
                error: error,
                errorBroadcaster: errorBroadcaster
            )
    }

    private func userAlreadyRestored(
        error: NetworkError
    ) -> AnyPublisher<String?, Never> {
        guard let authenticationError = NabuAuthenticationError(error: error),
              case .alreadyRegistered(_, let walletIdHint) = authenticationError
        else {
            return .just(nil)
        }
        return .just(walletIdHint)
    }

    // MARK: - User Creation

    private func createUserIfNeeded() -> AnyPublisher<NabuOfflineToken, NabuAuthenticationExecutorError> {
        nabuOfflineTokenRepository
            .offlineToken
            .catch { _ -> AnyPublisher<NabuOfflineToken, NabuAuthenticationExecutorError> in
                createUser()
            }
            .eraseToAnyPublisher()
    }

    private func createUser() -> AnyPublisher<NabuOfflineToken, NabuAuthenticationExecutorError> {
        jwtToken()
            .flatMap { jwtToken -> AnyPublisher<NabuOfflineToken, NabuAuthenticationExecutorError> in
                nabuRepository
                    .createUser(for: jwtToken)
                    .mapError(NabuAuthenticationExecutorError.failedToCreateUser)
                    .eraseToAnyPublisher()
            }
            .flatMap { offlineToken
                -> AnyPublisher<NabuOfflineToken, NabuAuthenticationExecutorError> in
                nabuOfflineTokenRepository
                    .set(offlineToken: offlineToken)
                    .replaceOutput(with: offlineToken)
                    .mapError(NabuAuthenticationExecutorError.failedToSaveOfflineToken)
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }

    // MARK: - Conveniences

    private func jwtToken() -> AnyPublisher<String, NabuAuthenticationExecutorError> {
        jwtService
            .token
            .mapError(NabuAuthenticationExecutorError.failedToRetrieveJWTToken)
            .eraseToAnyPublisher()
    }

    private func retrieveOfflineTokenResponse()
        -> AnyPublisher<NabuOfflineToken, NabuAuthenticationExecutorError>
    {
        nabuOfflineTokenRepository
            .offlineToken
            .mapError(NabuAuthenticationExecutorError.missingCredentials)
            .eraseToAnyPublisher()
    }
}

// MARK: - Extension

extension Publisher where Output == String?, Failure == NabuAuthenticationExecutorError {

    fileprivate func broadcastErrorWithHint(
        error: NabuAuthenticationExecutorError,
        errorBroadcaster: UserAlreadyRestoredHandlerAPI
    ) -> AnyPublisher<Void, NabuAuthenticationExecutorError> {
        flatMap { walletIdHint
            -> AnyPublisher<Void, NabuAuthenticationExecutorError> in
            guard let hint = walletIdHint else {
                return .failure(error)
            }
            return errorBroadcaster.send(walletIdHint: hint)
        }
        .mapToVoid()
    }
}
