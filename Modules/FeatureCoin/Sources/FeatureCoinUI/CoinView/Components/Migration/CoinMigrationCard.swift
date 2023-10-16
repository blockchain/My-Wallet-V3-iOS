//Copyright © Blockchain Luxembourg S.A. All rights reserved.

import SwiftUI
import BlockchainUI
import Localization
import FeatureCoinDomain

struct CoinMigrationCard: View {
    @BlockchainApp var app
    typealias L10n = LocalizationConstants.Coin.Migration
    var migrationInfo: CoinMigrationInfo
    var body: some View {
        CalloutCard(
            leading: {
                currencyMigrationImage(
                    currency1: migrationInfo.old,
                    currency2: migrationInfo.new
                )
            },
            title: L10n.title(currency: migrationInfo.old.displayCode),
            message: L10n.message(oldCurrency: migrationInfo.old.displayCode,
                                          newCurrency: migrationInfo.new.displayCode),
            control: .init(
                title: L10n.viewButton,
                action: {
                    $app.post(event: blockchain.ux.coinview.migration.view,
                              context: [blockchain.ux.asset.id: migrationInfo.new.code])
                }
            )
        )
        .batch {
            set(blockchain.ux.coinview.migration.view.then.enter.into, to: blockchain.ux.asset)
        }
    }

    @ViewBuilder
    func currencyMigrationImage(
        currency1: CryptoCurrency,
        currency2: CryptoCurrency
    ) -> some View {
        ZStack(alignment: .bottomTrailing) {
            Circle()
                .fill(Color.semantic.background)
                .inscribed(
                    currency1.logo()
                )
                .offset(x: 7, y: 7)

            Circle()                .fill(Color.semantic.background)
                .frame(height: 35)
                .inscribed(
                    currency2.logo()
                )
                .offset(x: -5, y: -5)
        }
    }
}
