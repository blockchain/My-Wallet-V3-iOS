// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import RxRelay
import RxSwift
import UIKit

@testable import RemoteNotificationsKit

class MockRemoteNotificationServiceContainer: RemoteNotificationServiceContaining,
                                              RemoteNotificationTokenSending,
                                              RemoteNotificationDeviceTokenReceiving, RemoteNotificationBackgroundReceiving {

    var authorizer: RemoteNotificationAuthorizing

    var backgroundReceiver: RemoteNotificationBackgroundReceiving {
        self
    }

    var tokenSender: RemoteNotificationTokenSending {
        self
    }

    var tokenReceiver: RemoteNotificationDeviceTokenReceiving {
        self
    }

    public init(authorizer: RemoteNotificationAuthorizing) {
        self.authorizer = authorizer
    }

    func sendTokenIfNeeded() -> Single<Void> {
        .just(())
    }

    var sendTokenIfNeededSubject = PassthroughSubject<Never, Error>()
    func sendTokenIfNeededPublisher() -> AnyPublisher<Never, Error> {
        sendTokenIfNeededSubject
            .eraseToAnyPublisher()
    }

    var appDidFailToRegisterForRemoteNotificationsCalled = false
    func appDidFailToRegisterForRemoteNotifications(with error: Error) {
        appDidFailToRegisterForRemoteNotificationsCalled = true
    }

    var appDidRegisterForRemoteNotificationsCalled: (called: Bool, token: Data?) = (false, nil)
    func appDidRegisterForRemoteNotifications(with deviceToken: Data) {
        appDidRegisterForRemoteNotificationsCalled = (true, deviceToken)
    }

    func didReceiveRemoteNotification(
        _ userInfo: [AnyHashable : Any],
        onApplicationState applicationState: UIApplication.State,
        fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void
    ) {
    }
}
