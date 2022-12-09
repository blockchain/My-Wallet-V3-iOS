// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainComponentLibrary
import ComposableArchitecture
import DIKit
import Localization
import SwiftUI

public struct DashboardAssetSectionView: View {
    @ObservedObject var viewStore: ViewStoreOf<DashboardAssetsSection>
    let store: StoreOf<DashboardAssetsSection>

    public init(store: StoreOf<DashboardAssetsSection>) {
        self.store = store
        self.viewStore = ViewStore(store)
    }

    public var body: some View {
        VStack(spacing: 0) {
            sectionHeader
                .padding(.vertical, Spacing.padding1)
            custodialAssetsSection
            if viewStore.presentedAssetsType == .custodial {
                fiatAssetSection
            }
        }
        .task {
            await viewStore.send(.onAppear).finish()
        }
        .padding(.horizontal, Spacing.padding2)
    }

    var fiatAssetSection: some View {
        SingleBalanceRow(
            leadingTitle: viewStore.fiatAssetInfo?.currency.name ?? "",
            trailingTitle: viewStore.fiatAssetInfo?.cryptoBalance.toDisplayString(includeSymbol: true),
            leading: {
                viewStore.fiatAssetInfo?.currency.fiatCurrency?
                    .image
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 24, height: 24)
                    .background(Color.WalletSemantic.fiatGreen)
                    .cornerRadius(6, corners: .allCorners)
            }
        )
        .cornerRadius(16, corners: .allCorners)
        .padding(.top, Spacing.padding2)
    }

    var custodialAssetsSection: some View {
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
    }
}
