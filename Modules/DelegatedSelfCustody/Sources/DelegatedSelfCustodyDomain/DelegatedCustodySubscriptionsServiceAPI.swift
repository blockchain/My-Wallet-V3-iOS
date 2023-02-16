// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine

public protocol DelegatedCustodySubscriptionsServiceAPI {
    func subscribe() -> AnyPublisher<Void, Error>
    func subscribeToNonDSCAccounts(accounts: [SubscriptionEntry]) -> AnyPublisher<Void, Error>
}

public struct SubscriptionEntry: Codable, Equatable, Hashable {

    public struct Account: Codable, Equatable, Hashable {
        public let index: Int
        public let name: String

        public init(index: Int, name: String) {
            self.index = index
            self.name = name
        }
    }

    public struct PubKey: Codable, Equatable, Hashable {
        public let pubKey: String
        public let style: String
        public let descriptor: Int

        public init(pubKey: String, style: String, descriptor: Int) {
            self.pubKey = pubKey
            self.style = style
            self.descriptor = descriptor
        }
    }

    public let account: Account
    public let currency: String
    public let pubKeys: [PubKey]

    public init(
        account: SubscriptionEntry.Account,
        currency: String,
        pubKeys: [SubscriptionEntry.PubKey]
    ) {
        self.account = account
        self.currency = currency
        self.pubKeys = pubKeys
    }
}
