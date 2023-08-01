// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainComponentLibrary
import BlockchainNamespace
import Collections
import FeatureCoinDomain
import MoneyKit
import SwiftUI
import ToolKit

struct AccountSheet: View {

    @BlockchainApp var app
    @Environment(\.context) var context

    private let account: Account.Snapshot
    private let onClose: () -> Void
    private let isVerified: Bool
    private let allActions: OrderedSet<Account.Action>
    private let actionsToDisplay: OrderedSet<Account.Action>
    private let maxHeight: Length

    init(account: Account.Snapshot, isVerified: Bool, onClose: @escaping () -> Void) {
        self.account = account
        self.isVerified = isVerified
        self.onClose = onClose
        let allActionsArray: [Account.Action] = account.actions
            .union(account.importantActions)
            .intersection(account.allowedActions)
            .sorted(like: account.allowedActions.array)
        self.allActions = OrderedSet(allActionsArray)

        actionsToDisplay = isVerified.isNo && account.isPrivateKey ? account.allowedActions : allActions
        maxHeight = (85 / max(1, actionsToDisplay.count))
            .clamped(to: 8..<11).vh
    }

    @ViewBuilder
    var body: some View {
        VStack(spacing: 0) {
            header
                .padding(.horizontal, Spacing.padding2)
            balance
                .padding([.top, .bottom], Spacing.padding3)
            actions
        }
        .batch {
            set(
                blockchain.ux.asset.account.rewards.summary.then.enter.into,
                to: blockchain.ux.earn.portfolio.product["savings"].asset[account.cryptoCurrency.code].summary
            )
            set(
                blockchain.ux.asset.account.staking.summary.then.enter.into,
                to: blockchain.ux.earn.portfolio.product["staking"].asset[account.cryptoCurrency.code].summary
            )
            set(
                blockchain.ux.asset.account.active.rewards.summary.then.enter.into,
                to: blockchain.ux.earn.portfolio.product["earn_cc1w"].asset[account.cryptoCurrency.code].summary
            )
        }
    }

    @ViewBuilder
    private var header: some View {
        HStack {
            account.cryptoCurrency.logo()
            Text(account.assetName)
                .typography(.body2.slashedZero())
                .foregroundColor(.semantic.title)
            Spacer()
            IconButton(icon: .navigationCloseButton(), action: onClose)
                .frame(width: 24.pt, height: 24.pt)
        }
    }

    @ViewBuilder
    private var balance: some View {
        if account.fiat.isNil, account.crypto.isNil {
            BalanceSectionHeader(
                title: "......",
                subtitle: "............"
            )
            .redacted(reason: .placeholder)
        } else {
            BalanceSectionHeader(
                title: account.fiat?.displayString,
                subtitle: account.crypto?.displayString
            )
        }
    }

    @ViewBuilder
    private var actions: some View {
        ForEach(actionsToDisplay) { action in
            PrimaryDivider()
            if allActions.contains(action) {
                PrimaryRow(
                    title: action.title,
                    subtitle: action.description.interpolating(account.cryptoCurrency.displayCode),
                    leading: {
                        action.icon.circle()
                            .accentColor(.semantic.title)
                            .frame(maxHeight: 24.pt)
                    },
                    action: {
                        onClose()
                        app.post(event: action.id[].ref(to: context), context: context)
                    }
                )
                .accessibility(identifier: action.id(\.id))
                .frame(maxHeight: maxHeight)
            } else {
                LockedAccountRow(
                    title: action.title,
                    subtitle: action.description.interpolating(account.cryptoCurrency.displayCode),
                    icon: action.icon.circle()
                )
                .accessibility(identifier: action.id(\.id))
                .frame(maxHeight: maxHeight)
            }
        }
    }
}

struct AccountSheetPreviewProvider: PreviewProvider {
    static var previews: some View {
        AccountSheet(
            account: .preview.trading,
            isVerified: true,
            onClose: {}
        )
    }
}
