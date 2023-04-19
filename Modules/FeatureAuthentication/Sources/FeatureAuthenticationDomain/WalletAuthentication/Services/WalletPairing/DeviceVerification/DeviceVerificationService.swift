// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import DIKit
import Errors
import Foundation
import ToolKit

final class DeviceVerificationService: DeviceVerificationServiceAPI {

    // MARK: - Properties

    private let pollingQueue: DispatchQueue
    private let deviceVerificationRepository: DeviceVerificationRepositoryAPI
    private let sessionTokenRepository: SessionTokenRepositoryAPI
    private let recaptchaService: GoogleRecaptchaServiceAPI
    private let walletIdentifierValidator: (String) -> Bool

    // MARK: - Setup

    init(
        pollingQueue: DispatchQueue = DispatchQueue(
            label: "com.blockchain.DeviceVerificationPolling",
            qos: .background
        ),
        deviceVerificationRepository: DeviceVerificationRepositoryAPI,
        sessionTokenRepository: SessionTokenRepositoryAPI,
        recaptchaService: GoogleRecaptchaServiceAPI,
        walletIdentifierValidator: @escaping (String) -> Bool = TextValidation.walletIdentifierValidator
    ) {
        self.pollingQueue = pollingQueue
        self.deviceVerificationRepository = deviceVerificationRepository
        self.sessionTokenRepository = sessionTokenRepository
        self.recaptchaService = recaptchaService
        self.walletIdentifierValidator = walletIdentifierValidator
    }

    // MARK: - AuthenticationServiceAPI

    func sendDeviceVerificationEmail(
        to emailAddress: String
    ) -> AnyPublisher<Void, DeviceVerificationServiceError> {
        recaptchaService
            .verifyForLogin()
            .mapError(DeviceVerificationServiceError.recaptchaError)
            .zip(
                sessionTokenRepository
                    .sessionToken
                    .setFailureType(to: DeviceVerificationServiceError.self)
            )
            .flatMap { [deviceVerificationRepository] captcha, sessionTokenOrNil ->
                AnyPublisher<Void, DeviceVerificationServiceError> in
                guard let sessionToken = sessionTokenOrNil else {
                    return .failure(.missingSessionToken)
                }
                return deviceVerificationRepository
                    .sendDeviceVerificationEmail(
                        sessionToken: sessionToken,
                        to: emailAddress,
                        captcha: captcha
                    )
            }
            .eraseToAnyPublisher()
    }

    func authorizeLogin(emailCode: String) -> AnyPublisher<Void, DeviceVerificationServiceError> {
        sessionTokenRepository
            .sessionToken
            .flatMap { token -> AnyPublisher<String, DeviceVerificationServiceError> in
                guard let sessionToken = token else {
                    return .failure(.missingSessionToken)
                }
                return .just(sessionToken)
            }
            .flatMap { [deviceVerificationRepository] sessionToken
                -> AnyPublisher<Void, DeviceVerificationServiceError> in
                deviceVerificationRepository
                    .authorizeLogin(sessionToken: sessionToken, emailCode: emailCode)
            }
            .eraseToAnyPublisher()
    }

    func handleLoginRequestDeeplink(
        url deeplink: URL
    ) -> AnyPublisher<WalletInfo, WalletInfoError> {
        extractWalletInfoFromDeeplink(url: deeplink)
            .flatMap { [sessionTokenRepository] walletInfo -> AnyPublisher<WalletInfo, WalletInfoError> in
                sessionTokenRepository
                    .sessionToken
                    .flatMap { tokenOrNil -> AnyPublisher<WalletInfo, WalletInfoError> in
                        // if wallet info does not have session id, it is not a magic link,
                        // just return wallet info in this case
                        guard let originSession = walletInfo.sessionId else {
                            return .just(walletInfo)
                        }
                        // gracefully handle decode error
                        guard let base64Str = deeplink.absoluteString.components(separatedBy: "/").last else {
                            return .just(walletInfo)
                        }
                        // if current device does not have session token saved,
                        // that means the login request is sent from another device
                        guard let token = tokenOrNil else {
                            return .failure(
                                .missingSessionToken(
                                    originSession: originSession,
                                    base64Str: base64Str.base64URLUnescaped
                                )
                            )
                        }
                        // if current device's session token is not equal to origin device's session,
                        // that means the received login request is sent from another device
                        if originSession != token {
                            return .failure(
                                .sessionTokenMismatch(
                                    originSession: originSession,
                                    base64Str: base64Str.base64URLUnescaped
                                )
                            )
                        }
                        // in other cases, just return wallet info
                        return .just(walletInfo)
                    }
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }

    func pollForWalletInfo()
        -> AnyPublisher<Result<WalletInfo, WalletInfoPollingError>, DeviceVerificationServiceError>
    {
        sessionTokenRepository
            .sessionToken
            .flatMap { token -> AnyPublisher<String, DeviceVerificationServiceError> in
                guard let sessionToken = token else {
                    return .failure(.missingSessionToken)
                }
                return .just(sessionToken)
            }
            .flatMap { [deviceVerificationRepository] sessionToken
                -> AnyPublisher<Result<WalletInfo, WalletInfoPollingError>, DeviceVerificationServiceError> in
                deviceVerificationRepository
                    .pollForWalletInfo(sessionToken: sessionToken)
            }
            .flatMap { result
                -> AnyPublisher<Result<WalletInfo, WalletInfoPollingError>, DeviceVerificationServiceError> in
                switch result {
                // if polled walletinfo, or request denied, stop the retry
                case .success,
                     .failure(.requestDenied):
                    return .just(result)
                // otherwise continue the retry
                case .failure(.continuePolling):
                    return .failure(.missingWalletInfo)
                }
            }
            .retry(max: 100, delay: .seconds(2), scheduler: pollingQueue)
            .eraseToAnyPublisher()
    }

    func authorizeVerifyDevice(
        from sessionToken: String,
        payload: String,
        confirmDevice: Bool?
    ) -> AnyPublisher<Void, AuthorizeVerifyDeviceError> {
        deviceVerificationRepository
            .authorizeVerifyDevice(
                from: sessionToken,
                payload: payload,
                confirmDevice: confirmDevice
            )
    }

    private func extractWalletInfoFromDeeplink(url deeplink: URL) -> AnyPublisher<WalletInfo, WalletInfoError> {
        let walletIdentifierValidator = walletIdentifierValidator
        return Deferred {
            Future { promise in
                let lastPathOrNil = deeplink.absoluteString.components(separatedBy: "/").last
                if let lastPath = lastPathOrNil,
                   walletIdentifierValidator(lastPath)
                {
                    let walletInfo = WalletInfo(wallet: WalletInfo.Wallet(guid: lastPath))
                    promise(.success(walletInfo))
                    return
                }
                guard let base64LastPath = lastPathOrNil?.base64URLUnescaped,
                      let jsonData = Data(base64Encoded: base64LastPath, options: .ignoreUnknownCharacters)
                else {
                    promise(.failure(.failToDecodeBase64Component))
                    return
                }
                do {
                    let walletInfo = try JSONDecoder().decode(WalletInfo.self, from: jsonData)
                    promise(.success(walletInfo))
                } catch {
                    promise(.failure(.failToDecodeToWalletInfo(error)))
                }
            }
        }
        .eraseToAnyPublisher()
    }
}
