// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import EthereumKit
import Foundation
import MoneyKit
import PlatformKit
import WalletConnectSwift

public enum WalletConnectSessionEvent {
    case didFailToConnect(Session)
    case shouldStart(Session, (Session.WalletInfo) -> Void)
    case didConnect(Session)
    case didDisconnect(Session)
    case didUpdate(Session)
    case shouldChangeChainID(Session, Request, EVMNetwork)
}

public enum WalletConnectUserEvent {
    case signMessage(SingleAccount, TransactionTarget)
    case signTransaction(SingleAccount, TransactionTarget)
    case sendTransaction(SingleAccount, TransactionTarget)
}

public enum WalletConnectResponseEvent {
    case empty(Request)
    case invalid(Request)
    case rejected(Request)
    case signature(String, Request)
    case transactionHash(String, Request)
}

public protocol WalletConnectServiceAPI {
    var sessionEvents: AnyPublisher<WalletConnectSessionEvent, Never> { get }
    var userEvents: AnyPublisher<WalletConnectUserEvent, Never> { get }

    func connect(_ url: String)
    func disconnect(_ session: Session)
    func acceptConnection(
        session: Session,
        completion: @escaping (Session.WalletInfo) -> Void
    )
    func denyConnection(
        session: Session,
        completion: @escaping (Session.WalletInfo) -> Void
    )

    /// Change the chain ID from the given Session.
    func respondToChainIDChangeRequest(
        session: Session,
        request: Request,
        network: EVMNetwork,
        approved: Bool
    )
}
