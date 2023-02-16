// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
@testable import DelegatedSelfCustodyData
import DelegatedSelfCustodyDomain
import Errors
import MoneyKit

final class GuidServiceMock: DelegatedCustodyGuidServiceAPI {
    var result: Result<String?, Never>!
    var guid: AnyPublisher<String?, Never> {
        result.publisher.eraseToAnyPublisher()
    }
}

final class SharedKeyServiceMock: DelegatedCustodySharedKeyServiceAPI {
    var result: Result<String?, Never>!
    var sharedKey: AnyPublisher<String?, Never> {
        result.publisher.eraseToAnyPublisher()
    }
}

final class AccountRepositoryMock: AccountRepositoryAPI {
    var result: Result<[Account], Error>!
    var accounts: AnyPublisher<[Account], Error> {
        result.publisher.eraseToAnyPublisher()
    }

    var delegatedCustodyAccounts: AnyPublisher<[DelegatedCustodyAccount], Error> {
        result
            .publisher
            .map { accounts -> [DelegatedCustodyAccount] in
                accounts
            }
            .eraseToAnyPublisher()
    }
}

final class SubscriptionsStateServiceMock: SubscriptionsStateServiceAPI {

    var isSubscribedParamsAccounts: [SubscriptionEntry]!
    var isSubscribedReturn: Bool!
    func isSubscribed(to accounts: [SubscriptionEntry]) -> AnyPublisher<Bool, Never> {
        isSubscribedParamsAccounts = accounts
        return .just(isSubscribedReturn)
    }

    var recordSubscriptionParamsAccounts: [SubscriptionEntry]!
    func recordSubscription(accounts: [SubscriptionEntry]) -> AnyPublisher<Void, Never> {
        recordSubscriptionParamsAccounts = accounts
        return .just(())
    }
}

final class AuthenticationDataRepositoryMock: DelegatedCustodyAuthenticationDataRepositoryAPI {
    var initialAuthenticationDataResult: Result<InitialAuthenticationDataPayload, AuthenticationDataRepositoryError>!
    var initialAuthenticationData: AnyPublisher<InitialAuthenticationDataPayload, AuthenticationDataRepositoryError> {
        initialAuthenticationDataResult.publisher.eraseToAnyPublisher()
    }

    var authenticationDataResult: Result<AuthenticationDataPayload, AuthenticationDataRepositoryError>!
    var authenticationData: AnyPublisher<AuthenticationDataPayload, AuthenticationDataRepositoryError> {
        authenticationDataResult.publisher.eraseToAnyPublisher()
    }
}

final class AuthenticationClientMock: AuthenticationClientAPI {
    var authResult: Result<Void, NetworkError>!
    var authParams: (guid: String, sharedKeyHash: String)!
    func auth(guid: String, sharedKeyHash: String) -> AnyPublisher<Void, NetworkError> {
        authParams = (guid: guid, sharedKeyHash: sharedKeyHash)
        return authResult.publisher.eraseToAnyPublisher()
    }
}

final class SubscriptionsClientMock: SubscriptionsClientAPI {
    var subscribeResult: Result<Void, NetworkError>!
    var subscribeParams: (guidHash: String, sharedKeyHash: String, subscriptions: [SubscriptionEntry])!
    func subscribe(
        guidHash: String,
        sharedKeyHash: String,
        subscriptions: [SubscriptionEntry]
    ) -> AnyPublisher<Void, NetworkError> {
        subscribeParams = (guidHash: guidHash, sharedKeyHash: sharedKeyHash, subscriptions: subscriptions)
        return subscribeResult.publisher.eraseToAnyPublisher()
    }

    var unsubscribeResult: Result<Void, NetworkError>!
    func unsubscribe(
        guidHash: String,
        sharedKeyHash: String,
        currency: String
    ) -> AnyPublisher<Void, NetworkError> {
        unsubscribeResult.publisher.eraseToAnyPublisher()
    }

    var subscriptionsResult: Result<SubscriptionsResponse, NetworkError>!
    func subscriptions(
        guidHash: String,
        sharedKeyHash: String
    ) -> AnyPublisher<SubscriptionsResponse, NetworkError> {
        subscriptionsResult.publisher.eraseToAnyPublisher()
    }
}
