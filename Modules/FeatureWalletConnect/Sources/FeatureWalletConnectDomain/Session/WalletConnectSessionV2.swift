// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation
import MetadataKit
import WalletConnectSign

public typealias WCSessionV2 = MetadataKit.WalletConnectSessionV2

extension WalletConnectSessionV2 {
    init(session: WalletConnectSign.Session) {
        self = .init(
            topic: session.topic,
            pairingTopic: session.pairingTopic,
            peer: .init(metadata: session.peer),
            namespaces: session.namespaces.mapValues(WalletConnectSessionV2.SessionNamespace.init(sessionNamespace:)),
            expiryDate: session.expiryDate
        )
    }
}

extension WalletConnectSessionV2.AppMetadata {
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

extension WalletConnectSessionV2.SessionNamespace {
    init(sessionNamespace: WalletConnectSign.SessionNamespace) {
        let chains = sessionNamespace.chains?.map(WalletConnectSessionV2.SessionNamespace.Blockchain.init(blockchain:))
        let accounts = sessionNamespace.accounts.map(WalletConnectSessionV2.SessionNamespace.Account.init(account:))
        self = .init(
            chains: chains?.set,
            accounts: Set(accounts),
            methods: sessionNamespace.methods,
            events: sessionNamespace.events
        )
    }
}

extension WalletConnectSessionV2.SessionNamespace.Blockchain {
    init(blockchain: Blockchain) {
        self = .init(
            namespace: blockchain.namespace,
            reference: blockchain.reference
        )
    }
}

extension WalletConnectSessionV2.SessionNamespace.Account {
    init(account: Account) {
        self = .init(
            namespace: account.namespace,
            reference: account.reference,
            address: account.address
        )
    }
}
