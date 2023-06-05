// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation
import MetadataKit
import WalletConnectSign
import Web3Wallet

extension WalletConnectSessionV2 {
    /// Returns a `Session` from `WalletConnect`
    ///
    /// This searches the `getSessions()` method on `Web3Wallet`
    /// 
    public func session() -> WalletConnectSign.Session? {
        nil
    }
}

extension WalletConnectSign.Session.Proposal: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(self.id)
        hasher.combine(self.pairingTopic)
    }
}
