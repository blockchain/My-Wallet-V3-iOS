// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainUI
import FeatureExternalTradingMigrationDomain
import SwiftUI

struct BakktAssetMigrationView: View {
    typealias L10n = LocalizationConstants.ExternalTradingMigration.AssetMigration

    @Dependency(\.app) var app
    var beforeMigrationBalances: [Balance]
    var afterMigrationBalance: Balance
    var onDone: () -> Void
    var onGoBack: () -> Void

    init(
        beforeMigrationBalances: [Balance],
        afterMigrationBalance: Balance,
        onDone: @escaping () -> Void,
        onGoBack: @escaping () -> Void
    ) {
        self.beforeMigrationBalances = beforeMigrationBalances
        self.afterMigrationBalance = afterMigrationBalance
        self.onDone = onDone
        self.onGoBack = onGoBack
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            ScrollView {
                VStack(spacing: Spacing.padding3) {
                    Image(
                        "last_step_logo",
                        bundle: Bundle.featureExternalTradingMigration
                    )
                    .frame(width: 88)

                    VStack(spacing: Spacing.padding1) {
                        Text(L10n.headerTitle)
                            .typography(.title3)
                            .foregroundColor(.semantic.title)

                        Text(L10n.headerDescription)
                            .typography(.body1)
                            .foregroundColor(.semantic.text)
                            .multilineTextAlignment(.center)
                    }

                    DividedVStack(spacing: 0) {
                            ForEach(beforeMigrationBalances, id: \.currency) { item in
                                BalanceRow(
                                    leadingTitle: item.currencyType?.name ?? "",
                                    leadingDescription: item.currencyType?.code,
                                    trailingTitle: item.amount,
                                    trailingDescription: "1.1"
                                ) {
                                    item.currencyType?.logo()
                                }
                            }
                    }
                    .cornerRadius(16)
                    Spacer()
                }
                .padding(.horizontal, Spacing.padding2)
            }
            bottomView
        }
        .navigationBarHidden(true)
        .superAppNavigationBar(
            leading: {
                IconButton(icon: .arrowLeft) {
                    onGoBack()
                }
            },
            trailing: {
                IconButton(icon: .navigationCloseButton()) {
                    app.post(event: blockchain.ux.dashboard.external.trading.migration.article.plain.navigation.bar.button.close.tap)
                }
            },
            scrollOffset: nil
        )
        .background(Color.semantic.light.ignoresSafeArea())
        .batch {
            set(blockchain.ux.dashboard.external.trading.migration.article.plain.navigation.bar.button.close.tap.then.close, to: true)
        }
    }

    @ViewBuilder var bottomView: some View {
            VStack(spacing: Spacing.padding2) {
                BalanceRow(
                    leadingTitle: afterMigrationBalance.currencyType?.name ?? "",
                    leadingDescription: afterMigrationBalance.currencyType?.code,
                    trailingTitle: afterMigrationBalance.amount,
                    trailingDescription: afterMigrationBalance.amount
                ) {
                    afterMigrationBalance.currencyType?.logo()
                }
                .cornerRadius(16)
                .padding(.top, Spacing.padding3)

                termsAndConditions

                PrimaryButton(title: "Upgrade") {
                    onDone()
                }
            }
            .padding(.horizontal, Spacing.padding2)
            .foregroundStyle(.primary)
            .border(Color.semantic.light, width: 1)
            .background(.ultraThinMaterial)
            .cornerRadius(16, corners: [.topLeft, .topRight])
            .overlay(
                Icon.arrowDown
                    .color(.semantic.title)
                    .small()
                    .padding(2)
                    .background(Color.semantic.background)
                    .clipShape(Circle())
                    .padding(Spacing.padding1)
                    .background(Color.semantic.light)
                    .clipShape(Circle())
                    .padding(.top, -Spacing.padding2),
                alignment: .top
            )
    }

    @ViewBuilder var termsAndConditions: some View {
        Text("Consolidating your assets into Bitcoin (BTC) does not have any costs involved. Supported assets in your balances will remain the same.")
            .typography(.micro)
            .foregroundColor(.semantic.body)
    }
}

extension Balance {
    var currencyType: CurrencyType? {
        try? CurrencyType(code: currency)
    }
}

//#Preview {
//    PrimaryNavigationView {
//        BakktAssetMigrationView(
//            beforeMigrationBalances: [
//                Balance(currency: "ADA", amount: "1000"),
//                Balance(currency: "SOL", amount: "1000"),
//                Balance(currency: "CHZ", amount: "1000")
//            ],
//            afterMigrationBalance: Balance(
//                currency: "BTC",
//                amount: "1000"
//            ),
//            onDone: {}, 
//            onGoBack: {}
//        )
//    }
//}
