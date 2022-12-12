// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainUI
import ComposableArchitecture
import DIKit
import Foundation
import Localization
import SwiftUI

public struct DashboardActivitySectionView: View {
    @ObservedObject var viewStore: ViewStoreOf<DashboardActivitySection>
    let store: StoreOf<DashboardActivitySection>

    public init(store: StoreOf<DashboardActivitySection>) {
        self.store = store
        self.viewStore = ViewStore(store)
    }

    public var body: some View {
        WithViewStore(self.store, observe: { $0 }, content: { viewStore in
            VStack(spacing: 0) {
                sectionHeader
                    .padding(.vertical, Spacing.padding1)
                activitySection
            }
            .task {
                await viewStore.send(.onAppear).finish()
            }
            .padding(.horizontal, Spacing.padding2)
        })
        .onAppear {
            viewStore.send(.onAppear)
        }
    }

    var activitySection: some View {
        VStack(spacing: 0) {
            ForEachStore(
              self.store.scope(
                  state: \.activityRows,
                  action: DashboardActivitySection.Action.onActivityRowTapped(id:action:)
              )
            ) { rowStore in
                WithViewStore(rowStore.scope(state: \.activity.id)) { id in
                    DashboardActivityRowView(store: rowStore)
                        .context([blockchain.ux.activity.detail.id: id.state])
                }
            }
        }
        .cornerRadius(16, corners: .allCorners)
    }

    var sectionHeader: some View {
        WithViewStore(self.store, observe: { $0 }, content: { viewStore in
            HStack {
                Text("Activity")
                    .typography(.body2)
                    .foregroundColor(.semantic.body)
                Spacer()
                Button {
                    viewStore.send(.onAllActivityTapped)
                } label: {
                    Text(LocalizationConstants.SuperApp.Dashboard.seeAllLabel)
                        .typography(.paragraph2)
                        .foregroundColor(.semantic.primary)
                }
            }
        })
    }
}
