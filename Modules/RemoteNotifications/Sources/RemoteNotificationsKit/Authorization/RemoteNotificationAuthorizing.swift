// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import UserNotifications

public typealias RemoteNotificationAuthorizing = RemoteNotificationRegistering
    & RemoteNotificationAuthorizationRequesting
    & RemoteNotificationAuthorizationStatusProviding

/// Any potential error that may be risen during authorization request
public enum RemoteNotificationAuthorizerError: Error {

    /// Any system error
    case system(Error)

    /// End-user has not granted
    case permissionDenied

    /// Thrown if the authorization status should be `.authorized` but it's not
    case unauthorizedStatus

    /// Authorization was already granted / refused
    case statusWasAlreadyDetermined

    /// End-user dismissed the pre-authorization modal
    case dismissed

    /// Unknowned error
    case unknowned
}

/// A protocol that encapsulates the registration to any notification service
/// The app delegate should hold its instance and inform it about registration events.
public protocol RemoteNotificationRegistering: AnyObject {
    /// Registers for remote notifications ONLY if the authorization status is `.authorized`.
    /// Should be called at the application startup after first initializing Firebase Messaging.
    func registerForRemoteNotificationsIfAuthorized() -> AnyPublisher<
        Void,
        RemoteNotificationAuthorizerError
    >
}

/// A protocol that defines remote-notification authorization / registration methods
public protocol RemoteNotificationAuthorizationRequesting: AnyObject {
    /// Request authorization for remote notifications if the status is not yet determined.
    func requestAuthorizationIfNeeded() -> AnyPublisher<
        Void,
        RemoteNotificationAuthorizerError
    >
}

/// A protocol that defines remote-notification auth-status reading abilities
public protocol RemoteNotificationAuthorizationStatusProviding {
    /// Streams the authorization status of the notifications, on demand.
    var status: AnyPublisher<UNAuthorizationStatus, Never> { get }
    /// Streams a boolean value indicating whether `status` is authorized.
    var isAuthorized: AnyPublisher<Bool, Never> { get }
}

extension RemoteNotificationAuthorizationStatusProviding {
    public var isAuthorized: AnyPublisher<Bool, Never> {
        status
            .map { $0 == .authorized }
            .eraseToAnyPublisher()
    }
}
