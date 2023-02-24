//  Copyright © 2023 Blockchain Luxembourg S.A. All rights reserved.

import BlockchainNamespace
import MoneyKit

enum DexFeature {
    /// - Parameter app: `AppProtocol`
    /// - Parameter cryptoCurrency: Optional `CryptoCurrency`, if a value is given here, an extra check is made to be sure it is supported by DEX.
    static func isEnabled(
        app: AppProtocol,
        cryptoCurrency: CryptoCurrency? = nil
    ) async -> Bool {
        guard app.currentMode == .pkw else {
            return false
        }
        guard isCurrencySupported(cryptoCurrency) else {
            return false
        }
        return await isDexTabEnabled(app: app)
    }

    static func openCurrencyExchangeRouter(
        app: AppProtocol,
        context: Tag.Context = [:]
    ) async throws {
        let routerTag = blockchain.ux.currency.exchange.router
        try await app.set(
            routerTag.entry.paragraph.row.tap.then.enter.into,
            to: routerTag
        )
        app.post(event: routerTag.entry.paragraph.row.tap, context: context)
    }

    /// Dex is enabled if it (`blockchain.ux.currency.exchange.dex`) exists in the tab bar
    private static func isDexTabEnabled(app: AppProtocol) async -> Bool {
        do {
            let tabConfig = try await app.get(
                blockchain.app.configuration.superapp.defi.tabs,
                as: TabConfig.self
            )
            return tabConfig.tabs
                .contains(where: { tab in
                    tab.tag == blockchain.ux.currency.exchange.dex
                })
        } catch {
            return false
        }
    }

    private static func isCurrencySupported(_ cryptoCurrency: CryptoCurrency?) -> Bool {
        cryptoCurrency.flatMap {
            $0 == .ethereum || $0.isERC20
        } ?? true
    }
}
