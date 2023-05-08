// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import Foundation
import Web3Wallet

/// convenience while WC v1 still exists
public typealias SessionV2 = WalletConnectSign.Session

public enum SessionV2Event {
    
}

public protocol WalletConnectServiceV2API {

    var sessionEvents: AnyPublisher<SessionV2Event, Never> { get }

    var sessions: AnyPublisher<[SessionV2], Never> { get }

    /// Attempts a pairing between wallet and dApp
    func pair(uri: WalletConnectURI) async throws

    func disconnect(topic: String) async throws

    func approve(proposal: SessionV2.Proposal) async throws
    func reject(proposal: SessionV2.Proposal) async throws
}
