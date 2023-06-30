// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainComponentLibrary
import BlockchainUI
import ComposableArchitecture
import DIKit
import FeatureTransactionUI
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
      WithViewStore(store, observe: { $0 }, content: { viewStore in
        VStack(spacing: 0) {
            if viewStore.failedLoadingBalances {
                sectionHeader(viewStore)
                failedToLoadBalances(viewStore)
            } else {
                alertCardIfNeeded(viewStore)
                sectionHeader(viewStore)
                if viewStore.showOnHoldSection {
                    onHoldAssetsSection(viewStore)
                        .padding(.vertical, Spacing.padding1)
                }
                cryptoAssetsSection(viewStore)
                if viewStore.presentedAssetsType.isCustodial {
                    fiatAssetSection(viewStore)
                }
            }
        }
        .onAppear {
            viewStore.send(.onAppear)
        }
        .batch {
            set(blockchain.ux.user.assets.all.entry.paragraph.row.tap.then.enter.into, to: blockchain.ux.user.assets.all)
            set(blockchain.ux.withdrawal.locks.entry.paragraph.row.tap.then.enter.into, to: blockchain.ux.withdrawal.locks)
        }
        .padding(.horizontal, Spacing.padding2)
       })
    }

    @ViewBuilder
    func failedToLoadBalances(_ viewStore: ViewStoreOf<DashboardAssetsSection>) -> some View {
        VStack(spacing: Spacing.padding1) {
            ZStack(alignment: .bottomTrailing) {
                Icon.coins
                    .with(length: 88.pt)
                    .circle(backgroundColor: .semantic.light)
                    .iconColor(.semantic.title)
                Icon.alert
                    .with(length: 44.pt)
                    .iconColor(.semantic.warningMuted)
                    .background(
                        Circle().fill(Color.semantic.background)
                            .frame(width: 59.pt, height: 59.pt)
                    )
            }
            .padding(.top, Spacing.padding3)
            .padding(.bottom, Spacing.padding1)

            Text(LocalizationConstants.Dashboard.Portfolio.FailureState.title)
                .typography(.title3)
                .foregroundColor(.semantic.title)

            Text(LocalizationConstants.Dashboard.Portfolio.FailureState.subtitle)
                .typography(.body1)
                .foregroundColor(.semantic.text)

            MinimalButton(
                title: LocalizationConstants.Dashboard.Portfolio.FailureState.buttonTitle,
                isLoading: viewStore.isLoading,
                leadingView: { Icon.refresh.micro() },
                action: {
                    guard viewStore.isLoading else {
                         return
                    }
                    viewStore.send(.refresh)
                    $app.post(event: blockchain.ux.home.event.did.pull.to.refresh)
                }
            )
            .padding(.horizontal, Spacing.padding2)
            .padding(.vertical, Spacing.padding3)
        }
        .background(
            RoundedRectangle(cornerRadius: Spacing.padding2)
                .fill(Color.semantic.background)
        )
    }

    @ViewBuilder
    func fiatAssetSection(_ viewStore: ViewStoreOf<DashboardAssetsSection>) -> some View {
        VStack(spacing: 0) {
            ForEachStore(
              store.scope(
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
                    .redacted(reason: .placeholder)
            } else {
                ForEachStore(
                    store.scope(
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
                title: {
                    HStack {
                        TableRowTitle(LocalizationConstants.Dashboard.Portfolio.onHoldTitle)
                            .typography(.paragraph2)
                            .foregroundColor(.semantic.title)
                        IconButton(
                            icon: .question.circle().micro(),
                            action: {}
                        )
                        .allowsTightening(false)
                    }
                },
                trailing: {
                    if let amount = viewStore.state.withdrawalLocks?.amount {
                        TableRowTitle(amount)
                            .typography(.paragraph2.slashedZero())
                            .foregroundColor(.semantic.title)
                    } else {
                        TableRowTitle("......")
                            .redacted(reason: .placeholder)
                            .typography(.paragraph2)
                            .foregroundColor(.semantic.title)
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
            HStack {
                Text(LocalizationConstants.SuperApp.Dashboard.assetsLabel)
                    .typography(.body2)
                    .foregroundColor(.semantic.body)
                if let failingNetworks = viewStore.balancesFailingForNetworks, failingNetworks.isNotEmpty {
                    Button {
                        $app.post(
                            event: blockchain.ux.dashboard.defi.balances.failure.sheet.entry.paragraph.button.icon.tap,
                            context: [
                                blockchain.ux.dashboard.defi.balances.failure.sheet.networks: viewStore.balancesFailingForNetworksTitles,
                                blockchain.ui.type.action.then.enter.into.detents: [
                                    blockchain.ui.type.action.then.enter.into.detents.automatic.dimension
                                ],
                                blockchain.ui.type.action.then.enter.into.grabber.visible: true,
                                blockchain.ui.type.action.then.enter.into.embed.in.navigation: false
                            ]
                        )
                    } label: {
                        Icon.alert
                            .micro()
                            .iconColor(.semantic.muted)
                    }
                }
            }
            .padding(.vertical, Spacing.padding1)
            .batch {
                set(blockchain.ux.dashboard.defi.balances.failure.sheet.entry.paragraph.button.icon.tap.then.enter.into, to: blockchain.ux.dashboard.defi.balances.failure.sheet)
            }

            Spacer()
            Button {
                app.post(event: blockchain.ux.user.assets.all.entry.paragraph.row.tap, context: context + [
                    blockchain.ux.user.assets.all.model: viewStore.presentedAssetsType,
                    blockchain.ux.user.assets.all.count: viewStore.assetRows.count
                ])
            } label: {
                Text(LocalizationConstants.SuperApp.Dashboard.seeAllLabel)
                    .typography(.paragraph2)
                    .foregroundColor(.semantic.primary)
            }
            .opacity(viewStore.seeAllButtonHidden ? 0.0 : 1.0)
        }
    }

    @ViewBuilder
    func alertCardIfNeeded(_ viewStore: ViewStoreOf<DashboardAssetsSection>) -> some View {
        if let failingNetworks = viewStore.balancesFailingForNetworks, failingNetworks.isNotEmpty {
            if !viewStore.alertCardSeen, let networks = viewStore.balancesFailingForNetworksTitles {
                AlertCard(
                    title: LocalizationConstants.SuperApp.Dashboard.BalancesFailing.alertCardTitle,
                    message: String(
                        format: LocalizationConstants.SuperApp.Dashboard.BalancesFailing.alertCardMessage,
                        networks
                    ),
                    variant: .warning,
                    isBordered: true,
                    backgroundColor: .semantic.background,
                    onCloseTapped: {
                        viewStore.send(.binding(.set(\.$alertCardSeen, true)), animation: .default)
                    }
                )
                .transition(.opacity)
            } else {
                EmptyView()
            }
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
        PrimaryDivider()
    }
}

extension DashboardAssetsSection.State {
    var showOnHoldSection: Bool {
        presentedAssetsType.isCustodial
            && (withdrawalLocks?.items.count ?? 0) > 0
    }
}
