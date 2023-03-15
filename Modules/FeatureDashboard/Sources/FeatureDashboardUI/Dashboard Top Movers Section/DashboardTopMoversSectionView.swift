// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainUI
import Foundation
import SwiftUI

public struct DashboardTopMoversSectionView: View {
    @BlockchainApp var app
    @Environment(\.context) var context

    let store: StoreOf<DashboardTopMoversSection>

    public init(store: StoreOf<DashboardTopMoversSection>) {
        self.store = store
    }

    public var body: some View {
        WithViewStore(store, observe: { $0 }, content: { viewStore in
            VStack(spacing: 0) {
                sectionHeader(viewStore)
                    .padding(.bottom, Spacing.padding1)
                topMoversSection(viewStore)
            }
            .onAppear {
                viewStore.send(.onAppear)
            }
        })
    }

    @ViewBuilder
    func topMoversSection(_ viewStore: ViewStoreOf<DashboardTopMoversSection>) -> some View {
        Carousel(viewStore.topMovers, id: \.id, maxVisible: 2.5) { element in
            TopMoverView(presenter: viewStore.presenter, topMover: element)
                .context(
                    [
                        blockchain.ux.top.movers.element.percentage: element.delta,
                        blockchain.ux.top.movers.element.position: (viewStore.topMovers.firstIndex(of: element)?.i ?? -1) + 1,
                        blockchain.ux.asset.select.origin: "TOP MOVERS",
                        viewStore.presenter.action.id: element.currency.code
                    ]
                )
        }
    }

    @ViewBuilder
    func sectionHeader(_ viewStore: ViewStoreOf<DashboardTopMoversSection>) -> some View {
        HStack {
            Text(LocalizationConstants.SuperApp.Dashboard.topMovers)
                .typography(.body2)
                .foregroundColor(.semantic.body)

            Icon.fireFilled
                .micro()
                .color(.WalletSemantic.warningMuted)
                .opacity((viewStore.fastRising ?? false) ? 0 : 1)

            Spacer()
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
