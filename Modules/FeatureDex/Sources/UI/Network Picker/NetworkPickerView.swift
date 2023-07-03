// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainUI
import FeatureDexDomain
import MoneyKit
import SwiftUI

public struct NetworkPickerView: View {

    let store: StoreOf<NetworkPicker>
    @ObservedObject var viewStore: ViewStoreOf<NetworkPicker>

    public init(store: StoreOf<NetworkPicker>) {
        self.store = store
        self.viewStore = ViewStore(store)
    }

    public var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                LazyVStack(spacing: 0) {
                    ForEach(viewStore.availableNetworks, id: \.networkConfig.networkTicker) { network in
                        TableRow(
                            leading: {
                                network.nativeAsset.logo(size: 24.pt)
                            },
                            title: network.networkConfig.shortName,
                            trailing: {
                                Checkbox(isOn: .constant(viewStore.currentNetwork == network.networkConfig.networkTicker))
                                    .disabled(true)
                            }
                        )
                        .background(Color.semantic.background)
                        .onTapGesture {
                            viewStore.send(.onNetworkSelected(network))
                        }
                    }
                }
                .cornerRadius(16, corners: .allCorners)
                .padding(.horizontal, Spacing.padding2)
            }
            .padding(.top, Spacing.padding1)
        }
        .onAppear {
            viewStore.send(.onAppear)
        }
        .background(Color.semantic.light.ignoresSafeArea())
        .superAppNavigationBar(
            leading: { EmptyView() },
            title: {
                Text(L10n.NetworkPicker.selectNetwork)
                    .typography(.body2)
                    .foregroundColor(.semantic.title)
            },
            trailing: {
                IconButton(icon: .closeCirclev3.color(.black)) {
                    viewStore.send(.onDismiss)
                }
                .frame(width: 20, height: 20)
            },
            scrollOffset: nil
        )
    }
}

struct NetworkPickerView_Previews: PreviewProvider {
    static var ethereum = EVMNetwork(
        networkConfig: .ethereum,
        nativeAsset: .ethereum
    )

    static var previews: some View {
        NetworkPickerView(
            store: Store(
                initialState: NetworkPicker.State(
                    currentNetwork: "ETH"
                ),
                reducer: NetworkPicker()._printChanges()
            )
        )
        .app(App.preview)
    }
}
