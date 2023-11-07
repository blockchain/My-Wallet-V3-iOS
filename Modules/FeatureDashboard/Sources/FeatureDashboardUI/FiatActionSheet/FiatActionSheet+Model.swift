// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainComponentLibrary
import BlockchainNamespace
import Coincore
import Collections
import FeatureDashboardDomain
import Foundation
import Localization
import MoneyKit

extension FiatActionSheet {

    struct FiatAction: Hashable, Identifiable {

        typealias L10n = LocalizationConstants.WalletAction.Default

        let id: String
        let icon: Icon
        let name: String
        let description: String
        let action: Tag.Event

        static let deposit = Self(
            id: "deposit",
            icon: .bank,
            name: L10n.Deposit.title,
            description: L10n.Deposit.Fiat.description,
            action: blockchain.ux.multiapp.wallet.action.sheet.deposit.paragraph.row.tap
        )

        static let withdraw = Self(
            id: "withdraw",
            icon: .cash,
            name: L10n.Withdraw.title,
            description: L10n.Withdraw.description,
            action: blockchain.ux.multiapp.wallet.action.sheet.withdraw.paragraph.row.tap
        )

        func hash(into hasher: inout Hasher) {
            hasher.combine(id)
        }

        static func == (lhs: FiatActionSheet.FiatAction, rhs: FiatActionSheet.FiatAction) -> Bool {
            lhs.id == rhs.id
        }
    }

    struct Model: Equatable {
        let actions: OrderedSet<FiatAction>
        let balance: String?
        let currency: CurrencyType
        let title: String

        init(with asset: AssetBalanceInfo) {
            self.actions = OrderedSet(asset.sortedActions.compactMap(\.fiatAction))
            self.balance = asset.balance?.toDisplayString(includeSymbol: true)
            self.currency = asset.currency
            self.title = asset.currency.name
        }
    }
}

extension AssetAction {
    fileprivate var fiatAction: FiatActionSheet.FiatAction? {
        switch self {
        case .deposit:
            .deposit
        case .withdraw:
            .withdraw
        default:
            nil
        }
    }
}

struct FiatActionSheet_PreviewProvider: PreviewProvider {
    static var content: some View {
        FiatActionSheet(
            assetBalanceInfo: AssetBalanceInfo(
                cryptoBalance: MoneyValue.one(currency: .GBP),
                fiatBalance: nil,
                currency: .fiat(.GBP),
                delta: nil,
                actions: [.withdraw, .deposit],
                rawQuote: nil
            )
        )
        .app(App.preview)
    }

    static var previews: some View {
        ForEach(ColorScheme.allCases, id: \.self) {
            content.preferredColorScheme($0)
        }
    }
}
