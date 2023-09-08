// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainNamespace
import Combine
import Foundation

protocol SweepImportedAddressesRepositoryAPI {
    var sweptBalances: [String] { get }
    /// Loads previous stored swept imported accounts, or clears them after a certain threshold
    func prepare()
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

    func prepare() {
        clearIfNeeded()
        if let previousSwept: [String] = try? app.state.get(blockchain.ux.sweep.imported.addresses.swept.addresses) {
            sweptBalances = previousSwept
        }
    }

    func clearIfNeeded() {
        if let lastUpdate: Date = try? app.state.get(blockchain.ux.sweep.imported.addresses.swept.last.update) {
            let hourDiff = Calendar.current.dateComponents([.second], from: lastUpdate, to: Date()).second ?? 0
            if hourDiff >= 2 * 60 * 60 {
                sweptBalances = []
                app.state.clear(blockchain.ux.sweep.imported.addresses.swept.addresses)
                app.state.clear(blockchain.ux.sweep.imported.addresses.swept.last.update)
            }
        }
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
