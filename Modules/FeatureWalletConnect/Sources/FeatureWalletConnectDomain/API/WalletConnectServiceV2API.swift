// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import Foundation
import Web3Wallet

public enum SessionEvent {
    case pairRequest(WalletConnectProposal)
    case pairSettled(WalletConnectSession)
    case failure(String?, AppMetadata)
}

public protocol WalletConnectServiceV2API {

    var sessionEvents: AnyPublisher<SessionEvent, Never> { get }

    var userEvents: AnyPublisher<WalletConnectUserEvent, Never> { get }

    var sessions: AnyPublisher<[Session], Never> { get }

    /// Attempts a pairing between wallet and dApp
    func pair(uri: WalletConnectURI) async throws

    func disconnect(topic: String) async throws
    func disconnectPairing(topic: String) async throws

    func disconnectAll() async throws

    func approve(proposal: Session.Proposal) async throws
    func reject(proposal: Session.Proposal) async throws

    func authApprove(request: AuthRequest) async throws
    func authReject(request: AuthRequest) async throws

    func getPairings() -> [WalletConnectSign.Pairing]

    func cleanup()
}
