// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation
import MetadataKit
import WalletConnectSign
import Web3Wallet

extension WalletConnectSession {
    /// Returns a `Session` from `WalletConnect`
    ///
    /// This searches the `getSessions()` method on `Web3Wallet`
    /// 
    public func session() -> WalletConnectSign.Session? {
        Web3Wallet.instance
            .getSessions()
            .first { session -> Bool in
                self.topic == session.topic && self.pairingTopic == session.pairingTopic
            }
    }
}

extension WalletConnectSign.Session.Proposal: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(self.id)
        hasher.combine(self.pairingTopic)
    }
}
