// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import WalletPayloadKit

final class LoginService: LoginServiceAPI {

    // MARK: - Properties

    let authenticator: AnyPublisher<WalletAuthenticatorType, Never>

    private let payloadService: WalletPayloadServiceAPI
    private let twoFAPayloadService: TwoFAWalletServiceAPI
    private let guidRepository: GuidRepositoryAPI

    /// Keeps authenticator type. Defaults to `.none` unless
    /// `func login() -> AnyPublisher<Void, LoginServiceError>` sets it to a different value
    private let authenticatorSubject: CurrentValueSubject<WalletAuthenticatorType, Never>

    // MARK: - Setup

    init(
        payloadService: WalletPayloadServiceAPI,
        twoFAPayloadService: TwoFAWalletServiceAPI,
        repository: GuidRepositoryAPI
    ) {
        self.payloadService = payloadService
        self.twoFAPayloadService = twoFAPayloadService
        self.guidRepository = repository

        self.authenticatorSubject = CurrentValueSubject(WalletAuthenticatorType.standard)
        self.authenticator = authenticatorSubject.eraseToAnyPublisher()
    }

    // MARK: - API

    func login(walletIdentifier: String) -> AnyPublisher<Void, LoginServiceError> {
        guidRepository
            .set(guid: walletIdentifier)
            .first()
            .flatMap { [payloadService] _ -> AnyPublisher<WalletAuthenticatorType, WalletPayloadServiceError> in
                payloadService.requestUsingSessionToken()
            }
            .mapError(LoginServiceError.walletPayloadServiceError)
            .handleEvents(receiveOutput: { [authenticatorSubject] type in
                authenticatorSubject.send(type)
            })
            .flatMap { type -> AnyPublisher<Void, LoginServiceError> in
                switch type {
                case .standard:
                    .just(())
                case .google, .yubiKey, .email, .yubikeyMtGox, .sms:
                    .failure(.twoFactorOTPRequired(type))
                }
            }
            .eraseToAnyPublisher()
    }

    func login(walletIdentifier: String, code: String) -> AnyPublisher<Void, LoginServiceError> {
        twoFAPayloadService
            .send(code: code)
            .mapError(LoginServiceError.twoFAWalletServiceError)
            .eraseToAnyPublisher()
    }
}
