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
        WithViewStore(self.store, observe: { $0 }, content: { viewStore in
            VStack(spacing: 0) {
                sectionHeader(viewStore)
                    .padding(.vertical, Spacing.padding1)
                topMoversSection(viewStore)
            }
            .onAppear {
                viewStore.send(.onAppear)
            }
            .padding(.horizontal, Spacing.padding2)
        })
    }

    @ViewBuilder
    func topMoversSection(_ viewStore: ViewStoreOf<DashboardTopMoversSection>) -> some View {
        Carousel(viewStore.topMovers, id: \.id, maxVisible: 2.7) { element in
            TopMoverView(priceRowData: element)
                .onTapGesture {
                    viewStore.send(.onAssetTapped(element))
                }
        }
    }

    @ViewBuilder
    func sectionHeader(_ viewStore: ViewStoreOf<DashboardTopMoversSection>) -> some View {
        HStack {
            Text(LocalizationConstants.SuperApp.Dashboard.topMovers)
                .typography(.body2)
                .foregroundColor(.semantic.body)
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
