// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine

public protocol DelegatedCustodySubscriptionsServiceAPI {
    func subscribe() -> AnyPublisher<Void, Error>
    func subscribeToNonDSCAccounts(accounts: [SubscriptionEntry]) -> AnyPublisher<Void, Error>
}

public struct SubscriptionEntry: Encodable, Equatable {

    public struct Account: Encodable, Equatable {
        public let index: Int
        public let name: String

        public init(index: Int, name: String) {
            self.index = index
            self.name = name
        }
    }

    public struct PubKey: Encodable, Equatable {
        public let pubKey: String
        public let style: String
        public let descriptor: Int

        public init(pubKey: String, style: String, descriptor: Int) {
            self.pubKey = pubKey
            self.style = style
            self.descriptor = descriptor
        }
    }

    public let currency: String
    public let account: Account
    public let pubKeys: [PubKey]

    public init(currency: String, account: SubscriptionEntry.Account, pubKeys: [SubscriptionEntry.PubKey]) {
        self.currency = currency
        self.account = account
        self.pubKeys = pubKeys
    }
}
