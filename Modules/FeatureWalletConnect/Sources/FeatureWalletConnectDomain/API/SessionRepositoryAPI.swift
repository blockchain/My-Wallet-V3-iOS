// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import Foundation
import MetadataKit
import WalletConnectSwift
import WalletPayloadKit

public protocol SessionRepositoryAPI {
    /// Streams wallet connect sessions
    var sessions: AnyPublisher<[WalletConnectSession], Never> { get }
    func contains(session: WalletConnectSession) -> AnyPublisher<Bool, Never>
    func store(session: WalletConnectSession) -> AnyPublisher<Void, Never>
    func remove(session: WalletConnectSession) -> AnyPublisher<Void, Never>
    func removeAll() -> AnyPublisher<Void, Never>
    func retrieve() -> AnyPublisher<[WalletConnectSession], Never>
}

extension SessionRepositoryAPI {
    public func retrieveConnectedApps() -> AnyPublisher<Int, Never> {
        retrieve()
            .map(\.count)
            .eraseToAnyPublisher()
    }
}

extension SessionRepositoryAPI {

    public func contains(session: Session) -> AnyPublisher<Bool, Never> {
        contains(
            session: WalletConnectSession(session: session)
        )
    }

    public func store(session: Session) -> AnyPublisher<Void, Never> {
        store(
            session: WalletConnectSession(session: session)
        )
    }

    public func remove(session: Session) -> AnyPublisher<Void, Never> {
        remove(
            session: WalletConnectSession(session: session)
        )
    }
}
