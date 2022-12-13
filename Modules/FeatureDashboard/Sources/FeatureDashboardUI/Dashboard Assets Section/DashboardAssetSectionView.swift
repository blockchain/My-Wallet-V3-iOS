// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainComponentLibrary
import BlockchainUI
import ComposableArchitecture
import DIKit
import Localization
import SwiftUI

public struct DashboardAssetSectionView: View {
    let store: StoreOf<DashboardAssetsSection>

    public init(store: StoreOf<DashboardAssetsSection>) {
        self.store = store
    }

    public var body: some View {
      WithViewStore(self.store, observe: { $0 }, content: { viewStore in
        VStack(spacing: 0) {
            sectionHeader
                .padding(.vertical, Spacing.padding1)
            custodialAssetsSection
            if viewStore.presentedAssetsType == .custodial {
                fiatAssetSection
            }
        }
        .onAppear {
            viewStore.send(.onAppear)
        }
        .padding(.horizontal, Spacing.padding2)
       })
    }

    var fiatAssetSection: some View {
        WithViewStore(self.store, observe: { $0 }, content: { _ in
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
        })
    }

    var custodialAssetsSection: some View {
    WithViewStore(self.store, observe: { $0 }, content: { viewStore in
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
      })
    }

    private var loadingSection: some View {
        Group {
            SimpleBalanceRow(leadingTitle: "", trailingDescription: nil, leading: {})
            Divider()
                .foregroundColor(.WalletSemantic.light)
            SimpleBalanceRow(leadingTitle: "", trailingDescription: nil, leading: {})
            Divider()
                .foregroundColor(.WalletSemantic.light)
            SimpleBalanceRow(leadingTitle: "", trailingDescription: nil, leading: {})
        }
    }

    var sectionHeader: some View {
        WithViewStore(self.store, observe: { $0 }, content: { viewStore in
            HStack {
                Text(LocalizationConstants.SuperApp.Dashboard.allAssetsLabel)
                    .typography(.body2)
                    .foregroundColor(.semantic.body)
                Spacer()
                Button {
                    viewStore.send(.onAllAssetsTapped)
                } label: {
                    Text(LocalizationConstants.SuperApp.Dashboard.seeAllLabel)
                        .typography(.paragraph2)
                        .foregroundColor(.semantic.primary)
                }
//                .opacity(viewStore.seeAllButtonHidden ? 0.0 : 1.0)
            }
            .opacity(viewStore.seeAllButtonHidden ? 0.0 : 1.0)
        })
    }
}
