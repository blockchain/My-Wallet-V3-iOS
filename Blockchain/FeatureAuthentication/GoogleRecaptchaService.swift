// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import DIKit
import FeatureAuthenticationDomain
import RecaptchaEnterprise
import ToolKit

final class GoogleRecaptchaService: GoogleRecaptchaServiceAPI {

    private var recaptchaClient: RecaptchaClient?
    private let siteKey: String

    private var bypassApplied: Bool {
        BuildFlag.isInternal && InfoDictionaryHelper.valueIfExists(for: .recaptchaBypass).isNotNilOrEmpty
    }

    init(siteKey: String) {
        self.siteKey = siteKey
    }

    func load() {
        guard !bypassApplied else {
            return
        }
        DispatchQueue.main.async { [siteKey] in
            Recaptcha.getClient(siteKey: siteKey) { [weak self] client, error in
                if let error {
                    print("RecaptchaClient creation error: \(error).")
                }
                if let client {
                    self?.recaptchaClient = client
                }
            }
        }
    }

    func verifyForLogin() -> AnyPublisher<String, GoogleRecaptchaError> {
        verify(action: .login)
    }

    func verifyForSignup() -> AnyPublisher<String, GoogleRecaptchaError> {
        verify(action: .signup)
    }

    private func verify(action: RecaptchaActionType) -> AnyPublisher<String, GoogleRecaptchaError> {
        guard !bypassApplied else {
            return .just("")
        }
        guard let recaptchaClient else {
            return .failure(.unknownError)
        }
        return Deferred {
            Future { promise in
                recaptchaClient
                    .execute(RecaptchaAction(action: action)) { token, error in
                        if token == nil, error == nil {
                            promise(.failure(GoogleRecaptchaError.unknownError))
                        }
                        if let recaptchaToken = token {
                            promise(.success(recaptchaToken.recaptchaToken))
                        } else {
                            promise(.failure(GoogleRecaptchaError.missingRecaptchaTokenError))
                        }
                        if let recaptchaError = error {
                            promise(.failure(GoogleRecaptchaError.rcaRecaptchaError(recaptchaError.localizedDescription)))
                        }
                    }
            }
        }
        .eraseToAnyPublisher()
    }
}
