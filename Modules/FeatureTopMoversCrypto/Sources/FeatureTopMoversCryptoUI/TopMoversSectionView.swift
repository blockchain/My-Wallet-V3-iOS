// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainUI
import Foundation
import SwiftUI

public struct TopMoversSectionView: View {
    @BlockchainApp var app
    @Environment(\.context) var context

    let store: StoreOf<TopMoversSection>

    public init(store: StoreOf<TopMoversSection>) {
        self.store = store
    }

    public var body: some View {
        WithViewStore(store, observe: { $0 }, content: { viewStore in
            VStack(spacing: 0) {
                sectionHeader(viewStore)
                topMoversSection(viewStore)
            }
            .onAppear {
                viewStore.send(.onAppear)
            }
        })
    }

    @ViewBuilder
    func topMoversSection(_ viewStore: ViewStoreOf<TopMoversSection>) -> some View {
        Carousel(viewStore.topMovers, id: \.id, maxVisible: 2.5) { element in
            TopMoverView(presenter: viewStore.presenter, topMover: element)
                .context(
                    [
                        blockchain.ux.top.movers.element.percentage: element.delta,
                        blockchain.ux.top.movers.element.position: (viewStore.topMovers.firstIndex(of: element)?.i ?? -1) + 1,
                        blockchain.ux.asset.select.origin: "TOP MOVERS",
                        blockchain.ux.transaction.select.target.top.movers.section.carousel.item.id: element.currency.code
                    ]
                )
        }
    }

    @ViewBuilder
    func sectionHeader(_ viewStore: ViewStoreOf<TopMoversSection>) -> some View {
        HStack {
            SectionHeader(title: LocalizationConstants.SuperApp.Dashboard.topMovers,
                          variant: .superapp,
                          decoration:  {
                Icon
                    .fireFilled
                    .micro()
                    .color(.WalletSemantic.warningMuted)
            }
        )


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
        PrimaryDivider()
    }
}
