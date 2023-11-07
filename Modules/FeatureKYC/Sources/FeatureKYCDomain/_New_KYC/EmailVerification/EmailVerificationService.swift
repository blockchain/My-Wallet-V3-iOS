// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import Errors

public enum EmailVerificationCheckError: Error, Equatable {
    case unknown(Error)

    public static func == (lhs: EmailVerificationCheckError, rhs: EmailVerificationCheckError) -> Bool {
        String(describing: lhs) == String(describing: rhs)
    }
}

public enum UpdateEmailAddressError: Error, Equatable {
    case missingCredentials
    case networkError(NetworkError)
    case unknown(Error)

    public static func == (lhs: UpdateEmailAddressError, rhs: UpdateEmailAddressError) -> Bool {
        String(describing: lhs) == String(describing: rhs)
    }
}

/// An type representing the email verification status of a user using a nomenclature that's semantically closer to the business domain
public struct EmailVerificationResponse: Equatable {
    public enum Status {
        case verified, unverified
    }

    public let emailAddress: String
    public let status: Status

    public init(emailAddress: String, status: Status) {
        self.emailAddress = emailAddress
        self.status = status
    }
}

/// `EmailVerificationServiceAPI` is the interface the UI should use to interface to the email verification APIs.
public protocol EmailVerificationServiceAPI {

    /// Fetches the current user's email verification status
    /// - Returns: A Combine `Publisher` that emits an `EmailVerificationStatus` on success or a `ServiceError` on failure
    func checkEmailVerificationStatus() -> AnyPublisher<EmailVerificationResponse, EmailVerificationCheckError>

    /// Re-sends a verification email to the passed-in `emailAddress
    /// - Parameter emailAddress: The email address of the user.
    /// - Returns: A Combine `Publisher` that emits no value on success or a `ServiceError` on failure
    func sendVerificationEmail(to emailAddress: String) -> AnyPublisher<Void, UpdateEmailAddressError>

    /// Updates the user's email address to the passed-in value. This action will also invalidate the email verification status of a user and send a verification email to the new address.
    /// - Parameter emailAddress: The email address of the user.
    /// - Returns: A Combine `Publisher` that emits no value on success or a `ServiceError` on failure
    func updateEmailAddress(to emailAddress: String) -> AnyPublisher<Void, UpdateEmailAddressError>
}

/// An implementation of `EmailVerificationServiceAPI`
public class EmailVerificationService: EmailVerificationServiceAPI {

    private let apiClient: EmailVerificationAPI

    public init(apiClient: EmailVerificationAPI) {
        self.apiClient = apiClient
    }

    public func checkEmailVerificationStatus() -> AnyPublisher<EmailVerificationResponse, EmailVerificationCheckError> {
        apiClient.fetchEmailVerificationStatus(force: true)
            .map {
                EmailVerificationResponse(
                    emailAddress: $0.email,
                    status: $0.isEmailVerified ? .verified : .unverified
                )
            }
            .mapError(EmailVerificationCheckError.unknown)
            .eraseToAnyPublisher()
    }

    public func sendVerificationEmail(to emailAddress: String) -> AnyPublisher<Void, UpdateEmailAddressError> {
        // NOTE: our backend doesn't have a specific "re-send verification email" API. Attempting an update of the email address will trigger a re-send, though.
        updateEmailAddress(to: emailAddress)
    }

    public func updateEmailAddress(to emailAddress: String) -> AnyPublisher<Void, UpdateEmailAddressError> {
        apiClient.update(email: emailAddress)
            .mapError { error in
                switch error {
                case .networkError(let error):
                    .networkError(error)
                case .unauthenticated:
                    .missingCredentials
                case .unknown(let error):
                    .unknown(error)
                }
            }
            .eraseToAnyPublisher()
    }
}
