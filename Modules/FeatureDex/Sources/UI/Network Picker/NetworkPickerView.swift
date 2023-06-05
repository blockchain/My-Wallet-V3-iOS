//Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation
import ComposableArchitecture
import SwiftUI
import BlockchainUI
import MoneyKit
import FeatureDexDomain

public struct NetworkPickerView: View {

    let store: StoreOf<NetworkPicker>
    @BlockchainApp var app

    public init(store: StoreOf<NetworkPicker>) {
        self.store = store
    }

    public var body: some View {
        WithViewStore(store, observe: { $0 }, content: { viewStore in
            VStack(spacing: 0) {
                ScrollView {
                    LazyVStack(spacing: 0) {
                        ForEach(viewStore.availableChains, id: \.name) { chain in
                            TableRow(
                                leading: {
                                    chain.logo(size: 24.pt)
                                },
                                title: chain.name,
                                trailing: {
                                    Checkbox(isOn: .constant(viewStore.selectedChain?.chainId == chain.chainId))
                                }
                            )
                            .onTapGesture {
                                viewStore.send(.onNetworkSelected(chain))
                            }
                            .background(Color.white)
                        }
                    }
                    .cornerRadius(16, corners: .allCorners)
                    .padding(.horizontal, Spacing.padding2)
                }
                .padding(.top, Spacing.padding1)
            }
            .background(Color.semantic.light.ignoresSafeArea())
            .superAppNavigationBar(
                leading: { EmptyView() },
                title: { navigationTitle() },
                trailing: { trailingItem(viewStore) },
                scrollOffset: nil
            )
        })
    }



    @ViewBuilder func navigationTitle() -> some View {
        Text("Select Network")
            .typography(.body2)
            .foregroundColor(.semantic.title)
    }

    @ViewBuilder func trailingItem(
        _ viewStore: ViewStoreOf<NetworkPicker>
    ) -> some View {
        IconButton(icon: .closeCirclev3.color(.black)) {
            viewStore.send(.onDismiss)
        }
        .frame(width: 20, height: 20)
    }

    @ViewBuilder
    func sectionHeader(_ value: String) -> some View {
        HStack {
            Text(value)
                .typography(.body2)
                .foregroundColor(.semantic.body)
            Spacer()
        }
        .padding(.vertical, Spacing.padding1)
    }
}


extension Chain {
    @MainActor
    func logo(size: Length) -> some View  {
        CryptoCurrency(code: nativeCurrency.symbol)?.logo(size: size, showNetworkLogo: false)
    }
}
