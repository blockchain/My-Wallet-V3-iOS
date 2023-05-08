// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

public struct WalletConnectEntryPayload: MetadataNodeEntry, Hashable {

    public enum CodingKeys: String, CodingKey {
        case sessions
    }

    public static let type: EntryType = .walletConnect

    public let sessions: [String: [WalletConnectSession]]?

    public init(
        sessions: [String: [WalletConnectSession]]?
    ) {
        self.sessions = sessions
    }
}

public enum WalletConnectVersionedModel: Codable {
    case v1(WalletConnectSession)
    case v2(WalletConnectSessionV2)
}

// MARK: - Version 2

/// Since `WalletConnect`'s `Session` does not conform to Codable nor expose a public init method
/// we created this 1:1 map of the model that conforms to `Codable` so we can store it on metadata
///
public struct WalletConnectSessionV2: Codable, Equatable {
    
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
            redirect: WalletConnectSessionV2.AppMetadata.Redirect? = nil
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
}

// MARK: - Version 1

public struct WalletConnectSession: Codable, Equatable, Hashable {
    public let url: String
    public let dAppInfo: DAppInfo
    public let walletInfo: WalletInfo

    public struct WalletInfo: Codable, Equatable, Hashable {
        public let clientId: String
        public let sourcePlatform: String

        public init(
            clientId: String,
            sourcePlatform: String
        ) {
            self.clientId = clientId
            self.sourcePlatform = sourcePlatform
        }
    }

    public struct DAppInfo: Codable, Equatable, Hashable {
        public let peerId: String
        public let peerMeta: ClientMeta
        public let chainId: Int?

        public init(
            peerId: String,
            peerMeta: WalletConnectSession.ClientMeta,
            chainId: Int?
        ) {
            self.peerId = peerId
            self.peerMeta = peerMeta
            self.chainId = chainId
        }
    }

    public struct ClientMeta: Codable, Equatable, Hashable {
        public let description: String
        public let url: String
        public let icons: [String]
        public let name: String

        public init(
            description: String,
            url: String,
            icons: [String],
            name: String
        ) {
            self.description = description
            self.url = url
            self.icons = icons
            self.name = name
        }
    }

    public init(
        url: String,
        dAppInfo: WalletConnectSession.DAppInfo,
        walletInfo: WalletConnectSession.WalletInfo
    ) {
        self.url = url
        self.dAppInfo = dAppInfo
        self.walletInfo = walletInfo
    }
}
