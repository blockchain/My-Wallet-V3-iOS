// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import FeatureAuthenticationDomain
import ToolKit

class MockRecaptchaService: GoogleRecaptchaServiceAPI {

    func load() async throws -> EmptyValue {
        .noValue
    }

    func verifyForSignup() -> AnyPublisher<String, GoogleRecaptchaError> {
        .just("")
    }

    func verifyForLogin() -> AnyPublisher<String, GoogleRecaptchaError> {
        .just("")
    }
}
