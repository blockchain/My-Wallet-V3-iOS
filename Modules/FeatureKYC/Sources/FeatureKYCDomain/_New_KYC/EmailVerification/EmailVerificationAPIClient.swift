// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import Errors

public protocol EmailVerificationAPI {

    /// Fetches data about the email verification status of the user.
    /// - Parameter force: A flag that indicates whether we need to force a network call or we're OK receiving cached data, which may not be the latest.
    /// - Returns: A `Combine.Publisher` streaming a single value representing the email address and verification status of that email address for the authenticated user.
    func fetchEmailVerificationStatus(force: Bool) -> AnyPublisher<EmailVerificationStatusResponse, EmailVerificationError>

    /// Updates the stored email address for the authenticated user. Calling this method invalidates the verification status of the user's email address.
    /// - Parameter email: The user's up-to-date email address.
    /// - Returns: A `Combine.Publisher` streaming a single `Void` value, confirming the request to update the user's email address has succeeded.
    /// - Note: Updating the user's email address will trigger  the backend to send a verification email to the user, no matter if the passed-in email matches the one already in record.
    func update(email: String) -> AnyPublisher<Void, EmailVerificationError>
}

public struct EmailVerificationStatusResponse: Codable {
    public let email: String
    public let isEmailVerified: Bool

    public init(email: String, isEmailVerified: Bool) {
        self.email = email
        self.isEmailVerified = isEmailVerified
    }
}

public enum EmailVerificationError: Error, Equatable {
    case networkError(NetworkError)
    case unauthenticated
    case unknown(Error)

    public static func == (lhs: EmailVerificationError, rhs: EmailVerificationError) -> Bool {
        let isEqual: Bool = switch (lhs, rhs) {
        case (.unknown(let lhsError), .unknown(let rhsError)):
            String(describing: lhsError) == String(describing: rhsError)
        case (.networkError(let lhsError), .networkError(let rhsError)):
            lhsError == rhsError
        case (.unauthenticated, .unauthenticated):
            true
        default:
            false
        }
        return isEqual
    }
}
