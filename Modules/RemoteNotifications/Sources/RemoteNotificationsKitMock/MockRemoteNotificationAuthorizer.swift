// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
@testable import RemoteNotificationsKit
import UserNotifications

final class MockRemoteNotificationAuthorizer {
    private let expectedAuthorizationStatus: UNAuthorizationStatus
    private let authorizationRequestExpectedStatus: Result<
        Void,
        RemoteNotificationAuthorizerError
    >

    var requestAuthorizationIfNeededCalled = false

    init(
        expectedAuthorizationStatus: UNAuthorizationStatus,
        authorizationRequestExpectedStatus: Result<
            Void,
            RemoteNotificationAuthorizerError
        >
    ) {
        self.expectedAuthorizationStatus = expectedAuthorizationStatus
        self.authorizationRequestExpectedStatus = authorizationRequestExpectedStatus
    }
}

// MARK: - RemoteNotificationAuthorizationStatusProviding

extension MockRemoteNotificationAuthorizer: RemoteNotificationAuthorizationStatusProviding {
    var status: AnyPublisher<UNAuthorizationStatus, Never> {
        .just(expectedAuthorizationStatus)
    }
}

// MARK: - RemoteNotificationRegistering

extension MockRemoteNotificationAuthorizer: RemoteNotificationRegistering {
    func registerForRemoteNotificationsIfAuthorized() -> AnyPublisher<
        Void,
        RemoteNotificationAuthorizerError
    > {
        if expectedAuthorizationStatus == .authorized {
            return .just(())
        } else {
            return .failure(.unauthorizedStatus)
        }
    }
}

// MARK: - RemoteNotificationAuthorizing

extension MockRemoteNotificationAuthorizer: RemoteNotificationAuthorizationRequesting {
    func requestAuthorizationIfNeeded() -> AnyPublisher<
        Void,
        RemoteNotificationAuthorizerError
    > {
        requestAuthorizationIfNeededCalled = true
        return authorizationRequestExpectedStatus
            .publisher
            .eraseToAnyPublisher()
    }

    func requestAuthorization() -> AnyPublisher<
        Void,
        RemoteNotificationAuthorizerError
    > {
        .just(())
    }
}
