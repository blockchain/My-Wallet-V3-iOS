// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainNamespace
import Combine
import DelegatedSelfCustodyDomain

protocol SubscriptionsStateServiceAPI {

    func isSubscribed(to accounts: [SubscriptionEntry]) -> AnyPublisher<Bool, Never>

    func recordSubscription(accounts: [SubscriptionEntry]) -> AnyPublisher<Void, Never>
}

final class SubscriptionsStateService: SubscriptionsStateServiceAPI {

    static let namespaceKey = blockchain.app.configuration.pubkey.service.auth

    private let app: AppProtocol

    init(app: AppProtocol) {
        self.app = app
    }

    func isSubscribed(to accounts: [SubscriptionEntry]) -> AnyPublisher<Bool, Never> {
        currentlySubscribedAccounts
            .map(Set.init)
            .map { currentAccounts in
                Set(accounts).isSubset(of: currentAccounts)
            }
            .eraseToAnyPublisher()
    }

    private var currentlySubscribedAccounts: AnyPublisher<[SubscriptionEntry], Never> {
        Deferred { [app] in
            app
                .publisher(for: Self.namespaceKey, as: [SubscriptionEntry].self)
                .prefix(1)
                .map(\.value)
                .replaceNil(with: [])
                .eraseToAnyPublisher()
        }
        .eraseToAnyPublisher()
    }

    func recordSubscription(accounts: [SubscriptionEntry]) -> AnyPublisher<Void, Never> {
        currentlySubscribedAccounts
            .map { currentAccounts in
                currentAccounts + accounts
            }
            .map(\.unique)
            .handleEvents(receiveOutput: { [app] accounts in
                app.state.set(Self.namespaceKey, to: accounts)
            })
            .mapToVoid()
    }
}
