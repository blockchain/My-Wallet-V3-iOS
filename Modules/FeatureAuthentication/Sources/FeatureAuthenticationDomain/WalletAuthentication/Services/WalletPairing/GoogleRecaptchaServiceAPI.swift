// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import Foundation
import Localization

public enum GoogleRecaptchaError: LocalizedError, Equatable {
    case missingRecaptchaTokenError
    case rcaRecaptchaError(String)
    case unknownError

    public var errorDescription: String? {
        switch self {
        case .missingRecaptchaTokenError:
            return LocalizationConstants.Authentication.recaptchaVerificationFailure
        case .rcaRecaptchaError(let errorMessage):
            return errorMessage
        case .unknownError:
            return LocalizationConstants.Authentication.recaptchaVerificationFailure
        }
    }
}

/// `GoogleRecaptchaServiceAPI` is the interface for using Google's Recaptcha Service
public protocol GoogleRecaptchaServiceAPI {
    func load()
    /// Sends a recaptcha request for the login workflow
    /// - Returns: A combine `Publisher` that emits a Recaptcha Token on success or GoogleRecaptchaError on failure
    func verifyForLogin() -> AnyPublisher<String, GoogleRecaptchaError>

    /// Sends a recaptcha request for the signup workflow
    /// - Returns: A combine `Publisher` that emits a Recaptcha Token on success or GoogleRecaptchaError on failure
    func verifyForSignup() -> AnyPublisher<String, GoogleRecaptchaError>
}

// Noop

public class NoOpGoogleRecatpchaService: GoogleRecaptchaServiceAPI {

    public init() {}

    public func load() {}

    public func verifyForLogin() -> AnyPublisher<String, GoogleRecaptchaError> {
        .empty()
    }

    public func verifyForSignup() -> AnyPublisher<String, GoogleRecaptchaError> {
        .empty()
    }
}
