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
            sectionHeader(viewStore)
                .padding(.vertical, Spacing.padding1)
            custodialAssetsSection(viewStore)
            if viewStore.presentedAssetsType == .custodial {
                fiatAssetSection(viewStore)
            }
        }
        .onAppear {
            viewStore.send(.onAppear)
        }
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
    func custodialAssetsSection(_ viewStore: ViewStoreOf<DashboardAssetsSection>) -> some View {
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
    func sectionHeader(_ viewStore: ViewStoreOf<DashboardAssetsSection>) -> some View {
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
            .opacity(viewStore.seeAllButtonHidden ? 0.0 : 1.0)
        }
        .opacity(viewStore.seeAllButtonHidden ? 0.0 : 1.0)
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
}
