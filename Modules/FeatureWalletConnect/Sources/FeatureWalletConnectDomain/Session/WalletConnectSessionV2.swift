// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation
import WalletConnectSign

/// Since `WalletConnect`'s `Session` does not conform to Codable nor expose a public init method
/// we created this 1:1 map of the model that conforms to `Codable` so we can store it on metadata
public struct WalletConnectSession: Codable, Equatable, Hashable {

    public let topic: String
    public let pairingTopic: String
    public let peer: AppMetadata
    public let namespaces: [String: SessionNamespace]
    public let expiryDate: Date

    public struct AppMetadata: Codable, Equatable {
        public struct Redirect: Codable, Equatable {
            public let native: String?
            public let universal: String?

            public init(native: String?, universal: String?) {
                self.native = native
                self.universal = universal
            }
        }

        public let name: String
        public let description: String
        public let url: String
        public let icons: [String]
        public let redirect: Redirect?

        public init(
            name: String,
            description: String,
            url: String,
            icons: [String],
            redirect: WalletConnectSession.AppMetadata.Redirect? = nil
        ) {
            self.name = name
            self.description = description
            self.url = url
            self.icons = icons
            self.redirect = redirect
        }
    }

    public struct SessionNamespace: Codable, Equatable, Hashable {
        public struct Blockchain: Codable, Equatable, Hashable {
            public let namespace: String
            public let reference: String

            public init(
                namespace: String,
                reference: String
            ) {
                self.namespace = namespace
                self.reference = reference
            }
        }

        public struct Account: Codable, Equatable, Hashable {
            public let namespace: String
            public let reference: String
            public let address: String

            public init(namespace: String, reference: String, address: String) {
                self.namespace = namespace
                self.reference = reference
                self.address = address
            }
        }

        public var chains: Set<Blockchain>?
        public var accounts: Set<Account>
        public var methods: Set<String>
        public var events: Set<String>

        public init(
            chains: Set<Blockchain>? = nil,
            accounts: Set<Account>,
            methods: Set<String>,
            events: Set<String>
        ) {
            self.chains = chains
            self.accounts = accounts
            self.methods = methods
            self.events = events
        }
    }

    public init(
        topic: String,
        pairingTopic: String,
        peer: AppMetadata,
        namespaces: [String: SessionNamespace],
        expiryDate: Date
    ) {
        self.topic = topic
        self.pairingTopic = pairingTopic
        self.peer = peer
        self.namespaces = namespaces
        self.expiryDate = expiryDate
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(topic)
        hasher.combine(pairingTopic)
    }
}

// MARK: Helpers

extension WalletConnectSession {
    init(session: WalletConnectSign.Session) {
        self = .init(
            topic: session.topic,
            pairingTopic: session.pairingTopic,
            peer: .init(metadata: session.peer),
            namespaces: session.namespaces.mapValues(WalletConnectSession.SessionNamespace.init(sessionNamespace:)),
            expiryDate: session.expiryDate
        )
    }
}

extension WalletConnectSession.AppMetadata {
    init(metadata: WalletConnectSign.AppMetadata) {
        self = .init(
            name: metadata.name,
            description: metadata.description,
            url: metadata.url,
            icons: metadata.icons,
            redirect: .init(native: metadata.redirect?.native, universal: metadata.redirect?.universal)
        )
    }
}

extension WalletConnectSession.SessionNamespace {
    init(sessionNamespace: WalletConnectSign.SessionNamespace) {
        let chains = sessionNamespace.chains?.map(WalletConnectSession.SessionNamespace.Blockchain.init(blockchain:))
        let accounts = sessionNamespace.accounts.map(WalletConnectSession.SessionNamespace.Account.init(account:))
        self = .init(
            chains: chains?.set,
            accounts: Set(accounts),
            methods: sessionNamespace.methods,
            events: sessionNamespace.events
        )
    }
}

extension WalletConnectSession.SessionNamespace.Blockchain {
    init(blockchain: Blockchain) {
        self = .init(
            namespace: blockchain.namespace,
            reference: blockchain.reference
        )
    }
}

extension WalletConnectSession.SessionNamespace.Account {
    init(account: Account) {
        self = .init(
            namespace: account.namespace,
            reference: account.reference,
            address: account.address
        )
    }
}
