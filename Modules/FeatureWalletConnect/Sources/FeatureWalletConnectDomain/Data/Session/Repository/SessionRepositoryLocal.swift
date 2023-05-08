// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import Foundation
import MetadataKit

final class SessionRepositoryLocal: SessionRepositoryAPI {

    private enum Constants {
        static let userDefaultsKey = "com.blockchain.wallet-connect.sessions"
    }

    struct SessionStorageModel: Codable {
        let sessions: [WalletConnectSession]
    }

    private let userDefaults: UserDefaults = .standard

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
            .flatMap { [store] sessions in
                store(sessions)
            }
            .eraseToAnyPublisher()
    }

    func removeAll() -> AnyPublisher<Void, Never> {
        Result<Void, Never>
            .success(())
            .map { [userDefaults] _ in
                userDefaults.removeObject(forKey: Constants.userDefaultsKey)
            }
            .publisher
            .eraseToAnyPublisher()
    }

    func retrieve() -> AnyPublisher<[WalletConnectSession], Never> {
        loadSessions()
            .map(\.sessions)
            .eraseToAnyPublisher()
    }

    func contains(session: WalletConnectSession) -> AnyPublisher<Bool, Never> {
        retrieve()
            .map { sessions in
                sessions
                    .contains(where: { $0.isEqual(session) })
            }
            .eraseToAnyPublisher()
    }

    private func loadSessions() -> AnyPublisher<SessionStorageModel, Never> {
        Result<Void, Never>
            .success(())
            .map { [userDefaults] _ in
                userDefaults.codable(SessionStorageModel.self, forKey: Constants.userDefaultsKey)
                    ?? SessionStorageModel(sessions: [])
            }
            .publisher
            .eraseToAnyPublisher()
    }

    private func store(sessions: [WalletConnectSession]) -> AnyPublisher<Void, Never> {
        Result<Void, Never>
            .success(())
            .map { [userDefaults] _ in
                let model = SessionStorageModel(sessions: sessions)
                userDefaults.set(codable: model, forKey: Constants.userDefaultsKey)
            }
            .publisher
            .eraseToAnyPublisher()
    }
}
