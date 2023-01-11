// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainComponentLibrary
import BlockchainUI
import ComposableArchitecture
import DIKit
import Localization
import SwiftUI

public struct DashboardAssetSectionView: View {
    @BlockchainApp var app
    @Environment(\.context) var context

    let store: StoreOf<DashboardAssetsSection>

    public init(store: StoreOf<DashboardAssetsSection>) {
        self.store = store
    }

    public var body: some View {
      WithViewStore(self.store, observe: { $0 }, content: { viewStore in
        VStack(spacing: 0) {
            sectionHeader(viewStore)
                .padding(.vertical, Spacing.padding1)
            if viewStore.showOnHoldSection {
                onHoldAssetsSection(viewStore)
                    .padding(.vertical, Spacing.padding1)
            }
            cryptoAssetsSection(viewStore)
            if viewStore.presentedAssetsType.isCustodial {
                fiatAssetSection(viewStore)
            }
        }
        .onAppear {
            viewStore.send(.onAppear)
        }
        .batch(
            .set(blockchain.ux.user.assets.all.entry.paragraph.row.tap.then.enter.into, to: blockchain.ux.user.assets.all),
            .set(blockchain.ux.withdrawal.locks.entry.paragraph.row.tap.then.enter.into, to: blockchain.ux.withdrawal.locks)
        )
        .padding(.horizontal, Spacing.padding2)
       })
    }

    @ViewBuilder
    func fiatAssetSection(_ viewStore: ViewStoreOf<DashboardAssetsSection>) -> some View {
        VStack(spacing: 0) {
            ForEachStore(
              self.store.scope(
                  state: \.fiatAssetRows,
                  action: DashboardAssetsSection.Action.fiatAssetRowTapped(id:action:)
              )
            ) { rowStore in
                DashboardAssetRowView(store: rowStore)
            }
        }
        .cornerRadius(16, corners: .allCorners)
        .padding(.top, Spacing.padding2)
    }

    @ViewBuilder
    func cryptoAssetsSection(_ viewStore: ViewStoreOf<DashboardAssetsSection>) -> some View {
        VStack(spacing: 0) {
            if viewStore.isLoading {
                loadingSection
            } else {
                ForEachStore(
                    self.store.scope(
                        state: \.assetRows,
                        action: DashboardAssetsSection.Action.assetRowTapped(id:action:)
                    )
                ) { rowStore in
                    DashboardAssetRowView(store: rowStore)
                }
            }
        }
        .cornerRadius(16, corners: .allCorners)
    }

    @ViewBuilder
    func onHoldAssetsSection(_ viewStore: ViewStoreOf<DashboardAssetsSection>) -> some View {
        VStack(spacing: 0) {
            TableRow(
                title: TableRowTitle(LocalizationConstants.Dashboard.Portfolio.onHoldTitle)
                    .typography(.paragraph2)
                    .foregroundColor(.textBody),
                inlineTitleButton: IconButton(
                    icon: .question.circle().micro(),
                    action: {}
                ),
                trailing: {
                    if let amount = viewStore.state.withdrawalLocks?.amount {
                        TableRowTitle(amount)
                            .typography(.paragraph2)
                            .foregroundColor(.textBody)
                    } else {
                        TableRowTitle("......")
                            .redacted(reason: .placeholder)
                            .typography(.paragraph2)
                            .foregroundColor(.textBody)
                    }
                }
            )
            .tableRowBackground(Color.semantic.background)
            .onTapGesture {
                if let model = viewStore.state.withdrawalLocks {
                    app.post(
                        event: blockchain.ux.withdrawal.locks.entry.paragraph.row.tap,
                        context: [
                            blockchain.ux.withdrawal.locks.info: model,
                            blockchain.ui.type.action.then.enter.into.embed.in.navigation: false
                        ]
                    )
                }
            }
        }
        .cornerRadius(16, corners: .allCorners)
    }

    @ViewBuilder
    func sectionHeader(_ viewStore: ViewStoreOf<DashboardAssetsSection>) -> some View {
        HStack {
            Text(LocalizationConstants.SuperApp.Dashboard.assetsLabel)
                .typography(.body2)
                .foregroundColor(.semantic.body)
            Spacer()
            Button {
                app.post(event: blockchain.ux.user.assets.all.entry.paragraph.row.tap, context: context + [
                    blockchain.ux.user.assets.all.model: viewStore.presentedAssetsType
                ])
            } label: {
                Text(LocalizationConstants.SuperApp.Dashboard.seeAllLabel)
                    .typography(.paragraph2)
                    .foregroundColor(.semantic.primary)
            }
            .opacity(viewStore.seeAllButtonHidden ? 0.0 : 1.0)
        }
    }

    private var loadingSection: some View {
        Group {
            loadingRow
            loadingDivider
            loadingRow
            loadingDivider
            loadingRow
        }
    }

    private var loadingRow: some View {
        SimpleBalanceRow(leadingTitle: "", trailingDescription: nil, leading: {})
    }

    private var loadingDivider: some View {
        Divider().foregroundColor(.WalletSemantic.light)
    }
}

extension DashboardAssetsSection.State {
    var showOnHoldSection: Bool {
        presentedAssetsType.isCustodial
            && (withdrawalLocks?.items.count ?? 0) > 0
    }
}
