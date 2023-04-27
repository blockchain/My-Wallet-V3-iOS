// Copyright © Blockchain Luxembourg S.A. All rights reserved.

@testable import BlockchainApp
import Combine
import Errors
import FirebaseMessaging
@testable import RemoteNotificationsKit

final class MockMessagingService: FirebaseCloudMessagingServiceAPI {

    enum FakeError: Error {
        case subscriptionFailure
    }

    var apnsToken: Data?

    private let expectedTokenResult: RemoteNotificationTokenFetchResult

    private(set) var topics = Set<String>()

    private let shouldSubscribeToTopicsSuccessfully: Bool

    init(expectedTokenResult: RemoteNotificationTokenFetchResult, shouldSubscribeToTopicsSuccessfully: Bool = true) {
        self.expectedTokenResult = expectedTokenResult
        self.shouldSubscribeToTopicsSuccessfully = shouldSubscribeToTopicsSuccessfully
    }

    @discardableResult
    func appDidReceiveMessage(_ message: [AnyHashable: Any]) -> MessagingMessageInfo {
        MessagingMessageInfo()
    }

    func subscribe(toTopic topic: String, completion: ((Error?) -> Void)?) {
        if shouldSubscribeToTopicsSuccessfully {
            topics.insert(topic)
            completion!(nil)
        } else {
            completion!(FakeError.subscriptionFailure)
        }
    }

    func token(handler: @escaping (RemoteNotificationTokenFetchResult) -> Void) {
        handler(expectedTokenResult)
    }
}

final class MockIterableService: IterableServiceAPI {
    func updateToken(_ token: String) -> AnyPublisher<Void, NabuNetworkError> {
        .just(())
    }
}
