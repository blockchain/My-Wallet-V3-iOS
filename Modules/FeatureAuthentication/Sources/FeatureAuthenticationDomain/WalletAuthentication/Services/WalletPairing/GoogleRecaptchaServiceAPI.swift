// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import Foundation
import Localization
import ToolKit

public enum GoogleRecaptchaError: LocalizedError, Equatable {
    case missingRecaptchaTokenError // error code: -1101
    case rcaRecaptchaError(String)
    case recaptchaClientMissing // error code: -1100
    case unknownError

    public var errorDescription: String? {
        switch self {
        case .missingRecaptchaTokenError:
            String(format: LocalizationConstants.Authentication.recaptchaVerificationFailure, "-1101")
        case .rcaRecaptchaError(let errorMessage):
            errorMessage
        case .unknownError:
            String(format: LocalizationConstants.Authentication.recaptchaVerificationFailure, "")
        case .recaptchaClientMissing:
            String(format: LocalizationConstants.Authentication.recaptchaVerificationFailure, "-1100")
        }
    }
}

/// `GoogleRecaptchaServiceAPI` is the interface for using Google's Recaptcha Service
public protocol GoogleRecaptchaServiceAPI {
    func load() async throws -> EmptyValue
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

    public func load() async throws -> EmptyValue {
        .noValue
    }

    public func verifyForLogin() -> AnyPublisher<String, GoogleRecaptchaError> {
        .empty()
    }

    public func verifyForSignup() -> AnyPublisher<String, GoogleRecaptchaError> {
        .empty()
    }
}
