// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainUI
import ComposableArchitecture
import DIKit
import Foundation
import Localization
import SwiftUI

public struct DashboardActivitySectionView: View {
    @BlockchainApp var app
    @Environment(\.context) var context

    @ObservedObject var viewStore: ViewStoreOf<DashboardActivitySection>
    let store: StoreOf<DashboardActivitySection>

    public init(store: StoreOf<DashboardActivitySection>) {
        self.store = store
        self.viewStore = ViewStore(store)
    }

    public var body: some View {
        WithViewStore(store, observe: { $0 }, content: { viewStore in
            VStack(spacing: 0) {
                sectionHeader(viewStore)
                activitySection(viewStore)
            }
            .padding(.horizontal, Spacing.padding2)
            .onAppear {
                viewStore.send(.onAppear)
            }
            .batch {
                set(
                    blockchain.ux.user.activity.all.entry.paragraph.row.tap.then.enter.into,
                    to: blockchain.ux.user.activity.all
                )
            }
        })
    }

    @ViewBuilder
    func activitySection(_ viewStore: ViewStoreOf<DashboardActivitySection>) -> some View {
        VStack(spacing: 0) {
            ForEachStore(
              store.scope(
                  state: \.activityRows,
                  action: DashboardActivitySection.Action.onActivityRowTapped(id:action:)
              )
            ) { rowStore in
                WithViewStore(rowStore) { viewStore in
                    DashboardActivityRowView(store: rowStore)
                        .context([blockchain.ux.activity.detail.id: viewStore.id])
                }
            }
        }
        .cornerRadius(16, corners: .allCorners)
    }

    @ViewBuilder
    func sectionHeader(_ viewStore: ViewStoreOf<DashboardActivitySection>) -> some View {
        HStack {
            SectionHeader(title: LocalizationConstants.SuperApp.Dashboard.activitySectionHeader, variant: .superapp)
            Spacer()
            Button {
                app.post(event: blockchain.ux.user.activity.all.entry.paragraph.row.tap, context: context + [
                    blockchain.ux.user.activity.all.model: viewStore.presentedAssetType
                ])
            } label: {
                Text(LocalizationConstants.SuperApp.Dashboard.seeAllLabel)
                    .typography(.paragraph2)
                    .foregroundColor(.semantic.primary)
            }
        }
    }
}
