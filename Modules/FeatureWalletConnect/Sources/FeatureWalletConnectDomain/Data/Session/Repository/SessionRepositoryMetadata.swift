// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import DIKit
import Foundation
import MetadataKit
import WalletPayloadKit

final class SessionRepositoryMetadata: SessionRepositoryAPI {

    private let walletConnectFetcher: WalletConnectFetcherAPI

    private let internalCache = PassthroughSubject<[WalletConnectSession], Never>()

    var sessions: AnyPublisher<[WalletConnectSession], Never> {
        internalCache.eraseToAnyPublisher()
    }

    init(
        walletConnectFetcher: WalletConnectFetcherAPI
    ) {
        self.walletConnectFetcher = walletConnectFetcher
    }

    func contains(session: WalletConnectSession) -> AnyPublisher<Bool, Never> {
        loadSessions()
            .map { sessions in
                sessions
                    .contains(where: { $0.isEqual(session) })
            }
            // in some cases WC tries to reconnect when Metadata is not yet available
            // in this case we don't want to display a first connection popup
            // the session is an existing one as it's a reconnect event
            .replaceError(with: true)
            .eraseToAnyPublisher()
    }

    func store(session: WalletConnectSession) -> AnyPublisher<Void, Never> {
        retrieve()
            .map { sessions -> [WalletConnectSession] in
                var sessions = sessions
                    .filter { item in
                        !item.isEqual(session)
                    }
                sessions.append(session)
                return sessions
            }
            .handleEvents(receiveOutput: internalCache.send(_:))
            .flatMap { [store] sessions -> AnyPublisher<Void, Never> in
                store(sessions)
            }
            .eraseToAnyPublisher()
    }

    func remove(session: WalletConnectSession) -> AnyPublisher<Void, Never> {
        retrieve()
            .map { sessions in
                sessions.filter { item in
                    !item.isEqual(session)
                }
            }
            .handleEvents(receiveOutput: internalCache.send(_:))
            .flatMap { [store] sessions -> AnyPublisher<Void, Never> in
                store(sessions)
            }
            .eraseToAnyPublisher()
    }

    func removeAll() -> AnyPublisher<Void, Never> {
        store(sessions: [])
    }

    func retrieve() -> AnyPublisher<[WalletConnectSession], Never> {
        loadSessions()
            .replaceError(with: [])
            .handleEvents(receiveOutput: internalCache.send(_:))
            .eraseToAnyPublisher()
    }

    private func loadSessions() -> AnyPublisher<[WalletConnectSession], WalletConnectMetadataError> {
        walletConnectFetcher.fetchSessions()
            .mapError { _ in WalletConnectMetadataError.unavailable }
            .compactMap { wrapper in
                wrapper.retrieveSessions(version: .v1)
            }
            .eraseToAnyPublisher()
    }

    private func store(sessions: [WalletConnectSession]) -> AnyPublisher<Void, Never> {
        walletConnectFetcher
            .update(v1Sessions: sessions)
            .replaceError(with: ())
            .mapToVoid()
            .eraseToAnyPublisher()
    }
}
