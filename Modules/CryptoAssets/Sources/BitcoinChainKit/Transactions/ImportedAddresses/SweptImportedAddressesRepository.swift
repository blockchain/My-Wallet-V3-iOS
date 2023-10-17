// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainNamespace
import Combine
import Foundation

public protocol SweepImportedAddressesRepositoryAPI {
    /// Loads previous stored swept imported accounts, or clears them after a certain threshold
    func prepare() -> AnyPublisher<[String], Never>
    /// Store a new swept identifier
    func update(result: TxPairResult)
    /// `true` if the passed result's identifier exists, otherwise `false`
    func contains(result: TxPairResult) -> Bool
    /// set the last time a sweep attempted
    func setLastSweptAttempt()
}

final class SweepImportedAddressesRepository: SweepImportedAddressesRepositoryAPI {

    private let app: AppProtocol
    private let now: () -> Date

    /// Contains any identifiers from swept balances
    private(set) var sweptBalances: [String] = []

    init(app: AppProtocol, now: @escaping () -> Date = { Date() }) {
        self.app = app
        self.now = now
    }

    func prepare() -> AnyPublisher<[String], Never> {
        app.publisher(for: blockchain.ux.sweep.imported.addresses.swept.last.update, as: Date.self)
            .first()
            .flatMap { [weak self, app] result -> AnyPublisher<[String], Never> in
                guard let self else {
                    return .just([])
                }
                return clearIfNeeded(result.value)
                    .flatMap { _ -> AnyPublisher<[String], Never> in
                        app.publisher(for: blockchain.ux.sweep.imported.addresses.swept.addresses, as: [String].self)
                            .map(\.value)
                            .replaceNil(with: [])
                            .first()
                            .eraseToAnyPublisher()
                    }
                    .eraseToAnyPublisher()
            }
            .handleEvents(
                receiveOutput: { [weak self] value in
                    guard let self else { return }
                    sweptBalances = value
                }
            )
            .eraseToAnyPublisher()
    }

    func clearIfNeeded(_ lastUpdate: Date?) -> AnyPublisher<Void, Never> {
        guard let lastUpdate else {
            return .just(())
        }
        let hourDiff = Calendar.current.dateComponents([.second], from: lastUpdate, to: Date()).second ?? 0
        if hourDiff >= 2 * 60 * 60 {
            sweptBalances = []
            app.state.clear(blockchain.ux.sweep.imported.addresses.swept.addresses)
            app.state.clear(blockchain.ux.sweep.imported.addresses.swept.last.update)
        }
        return .just(())
    }

    func update(result: TxPairResult) {
        if !contains(result: result) {
            sweptBalances.append(result.accountIdentifier)
            app.state.set(blockchain.ux.sweep.imported.addresses.swept.addresses, to: sweptBalances)
        }
    }

    func contains(result: TxPairResult) -> Bool {
        sweptBalances.contains(where: { $0 == result.accountIdentifier })
    }

    func setLastSweptAttempt() {
        app.state.set(blockchain.ux.sweep.imported.addresses.swept.last.update, to: now())
    }
}
