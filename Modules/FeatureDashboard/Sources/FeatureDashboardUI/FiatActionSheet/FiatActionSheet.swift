// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainComponentLibrary
import BlockchainNamespace
import Collections
import FeatureDashboardDomain
import MoneyKit
import SwiftUI

public struct FiatActionSheet: View {
    @Environment(\.presentationMode) private var presentationMode
    @BlockchainApp var app
    private let model: FiatActionSheet.Model

    public init(assetBalanceInfo: AssetBalanceInfo) {
        self.model = FiatActionSheet.Model(with: assetBalanceInfo)
    }

    public var body: some View {
        VStack(spacing: 0) {
            header
                .padding(.top, Spacing.padding2)
                .padding(.horizontal, Spacing.padding2)
            balance
                .padding([.top, .bottom], Spacing.padding3)
            rows
            Color.semantic.background.ignoresSafeArea()
        }
        .batch {
            set(
                blockchain.ux.multiapp.wallet.action.sheet.deposit.paragraph.row.event.tap.then.emit,
                to: blockchain.ux.frequent.action.deposit
            )
            set(
                blockchain.ux.multiapp.wallet.action.sheet.withdraw.paragraph.row.event.tap.then.emit,
                to: blockchain.ux.frequent.action.withdraw
            )
        }
        .background(Color.semantic.background.ignoresSafeArea())
    }

    @ViewBuilder
    private var rows: some View {
        ForEach(model.actions) { action in
            PrimaryDivider()
            PrimaryRow(
                title: action.name,
                subtitle: action.description,
                leading: {
                    action.icon
                        .circle()
                        .accentColor(.semantic.title)
                        .frame(maxHeight: 24.pt)
                },
                action: { app.post(event: action.action) }
            )
        }
    }

    @ViewBuilder
    private var balance: some View {
        if let balance = model.balance {
            BalanceSectionHeader(
                title: balance,
                subtitle: nil
            )
        } else {
            BalanceSectionHeader(
                title: "......",
                subtitle: nil
            )
            .redacted(reason: .placeholder)
        }
    }

    @ViewBuilder
    private var header: some View {
        HStack(spacing: Spacing.padding1) {
            model.currency.logo()
            Text(model.title)
                .typography(.body2)
                .foregroundColor(.semantic.title)
            Spacer()
            IconButton(
                icon: .navigationCloseButton(),
                action: { presentationMode.wrappedValue.dismiss() }
            )
            .frame(width: 24.pt, height: 24.pt)
        }
    }
}
