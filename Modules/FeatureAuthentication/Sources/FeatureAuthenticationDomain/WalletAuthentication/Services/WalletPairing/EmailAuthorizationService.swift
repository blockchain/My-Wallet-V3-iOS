// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import Foundation
import ToolKit

public enum EmailAuthorizationServiceError: Error {
    /// Session token is missing
    case missingSessionToken

    /// Guid is missing
    case missingGuid

    /// Instance of self was deallocated
    case unretainedSelf

    /// Authorization is already active
    case authorizationAlreadyActive

    /// Cancellation error
    case authorizationCancelled

    /// Guid Service Error
    case guidService(GuidServiceError)
}

public protocol EmailAuthorizationServiceAPI {

    func cancel()

    /// Checks whether the email authorization has been approved by checking the existence of GUID set at the backend
    /// - Returns: A Combine `Publisher`that returns Void on success (GUID exist) or
    ///  EmailAuthorizationServiceError on failure (including GUID not exist case)
    func authorizeEmailPublisher() -> AnyPublisher<Void, EmailAuthorizationServiceError>
}

final class EmailAuthorizationService: EmailAuthorizationServiceAPI {

    private let lock = NSRecursiveLock()
    private var _isActive = false
    private var isActive: Bool {
        get {
            lock.lock()
            defer { lock.unlock() }
            return _isActive
        }
        set {
            lock.lock()
            defer { lock.unlock() }
            _isActive = newValue
        }
    }

    // MARK: - Injected

    private let guidService: GuidServiceAPI

    // MARK: - Setup

    init(guidService: GuidServiceAPI) {
        self.guidService = guidService
    }

    /// Cancels the authorization by sending interrupt to stop polling
    func cancel() {
        isActive = false
    }

    // MARK: - Accessors

    func authorizeEmailPublisher() -> AnyPublisher<Void, EmailAuthorizationServiceError> {
        guidService
            .guid
            .mapToVoid()
            .catch { error -> AnyPublisher<Void, EmailAuthorizationServiceError> in
                switch error {
                case .missingGuid:
                    .failure(.missingGuid)
                case .missingSessionToken:
                    .failure(.missingSessionToken)
                case .networkError(let networkError):
                    .failure(.guidService(.networkError(networkError)))
                }
            }
            .eraseToAnyPublisher()
    }
}
