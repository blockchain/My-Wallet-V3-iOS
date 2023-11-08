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

    func load() async throws -> EmptyValue {
        do {
            let client = try await Recaptcha.getClient(withSiteKey: siteKey, withTimeout: 15000)
            self.recaptchaClient = client
            return .noValue
        } catch let error as RecaptchaError {
            throw GoogleRecaptchaError.rcaRecaptchaError(String(describing: error.errorMessage))
        }
    }

    func verifyForLogin() -> AnyPublisher<String, GoogleRecaptchaError> {
        guard !bypassApplied else {
            return .just("")
        }
        return verify(action: .login)
    }

    func verifyForSignup() -> AnyPublisher<String, GoogleRecaptchaError> {
        verify(action: .signup)
    }

    private func verify(action: RecaptchaAction) -> AnyPublisher<String, GoogleRecaptchaError> {
        guard let recaptchaClient else {
            return .failure(.unknownError)
        }

        return Deferred {
            Future { promise in
                Task(priority: .userInitiated) {
                    do {
                        let token = try await recaptchaClient.execute(withAction: action, withTimeout: 15000)
                        promise(.success(token))
                    } catch let error as RecaptchaError {
                        promise(.failure(GoogleRecaptchaError.rcaRecaptchaError(String(describing: error.errorMessage))))
                    }
                }
            }
        }
        .eraseToAnyPublisher()
    }
}
