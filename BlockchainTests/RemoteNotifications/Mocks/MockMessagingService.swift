// Copyright © Blockchain Luxembourg S.A. All rights reserved.

@testable import Blockchain
import FirebaseMessaging
@testable import RemoteNotificationsKit

final class MockMessagingService: FirebaseCloudMessagingServiceAPI {

    enum FakeError: Error {
        case subscriptionFailure
    }

    var apnsToken: Data?

    private let expectedTokenResult: RemoteNotificationTokenFetchResult

    private(set) var topics = Set<RemoteNotification.Topic>()

    private let shouldSubscribeToTopicsSuccessfully: Bool

    init(expectedTokenResult: RemoteNotificationTokenFetchResult, shouldSubscribeToTopicsSuccessfully: Bool = true) {
        self.expectedTokenResult = expectedTokenResult
        self.shouldSubscribeToTopicsSuccessfully = shouldSubscribeToTopicsSuccessfully
    }

    @discardableResult
    func appDidReceiveMessage(_ message: [AnyHashable: Any]) -> MessagingMessageInfo {
        MessagingMessageInfo()
    }

    func subscribe(toTopic topic: String, completion: FIRMessagingTopicOperationCompletion?) {
        if shouldSubscribeToTopicsSuccessfully {
            topics.insert(RemoteNotification.Topic(rawValue: topic)!)
            completion!(nil)
        } else {
            completion!(FakeError.subscriptionFailure)
        }
    }

    func token(handler: @escaping (RemoteNotificationTokenFetchResult) -> Void) {
        handler(expectedTokenResult)
    }
}
