// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import Foundation
import MetadataKit
import Web3Wallet

/// convenience while WC v1 still exists
public typealias SessionV2 = WalletConnectSign.Session

public enum SessionV2Event {
    case pairRequest(WalletConnectProposal)
    case pairSettled(WalletConnectSessionV2)
//    case authResponse(Result<Cacao, AuthError>)
    case failure(String?, AppMetadata)
}

public protocol WalletConnectServiceV2API {

    var sessionEvents: AnyPublisher<SessionV2Event, Never> { get }

    var userEvents: AnyPublisher<WalletConnectUserEvent, Never> { get }

    var sessions: AnyPublisher<[SessionV2], Never> { get }

    /// Attempts a pairing between wallet and dApp
    func pair(uri: WalletConnectURI) async throws

    func disconnect(topic: String) async throws
    func disconnectPairing(topic: String) async throws

    func disconnectAll() async throws

    func approve(proposal: SessionV2.Proposal) async throws
    func reject(proposal: SessionV2.Proposal) async throws

    func authApprove(request: AuthRequest) async throws
    func authReject(request: AuthRequest) async throws

    func getPairings() -> [WalletConnectSign.Pairing]

    func cleanup()
}
