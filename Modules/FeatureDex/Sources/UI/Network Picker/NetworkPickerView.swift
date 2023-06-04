//Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation
import ComposableArchitecture
import SwiftUI
import BlockchainUI

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
                        ForEach(viewStore.availableNetworks, id: \.nativeAsset.name) { network in
                            TableRow(
                                leading: {
                                    network.nativeAsset.logo()
                                },
                                title: network.nativeAsset.name,
                                trailing: {
                                    Checkbox(isOn: .constant(viewStore.selectedNetwork == network))
                                }
                            )
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

//struct AssetPickerView_Previews: PreviewProvider {
//
//    private static var app = App.preview.withPreviewData()
//
//    static var previews: some View {
//        AssetPickerView(
//            store: Store(
//                initialState: AssetPicker.State(
//                    balances: [.init(value: .one(currency: .ethereum))],
//                    tokens: [.bitcoin, .ethereum],
//                    denylist: [],
//                    currentNetwork: .init(networkConfig: .ethereum, nativeAsset: .ethereum),
//                    searchText: "",
//                    isSearching: false
//                ),
//                reducer: AssetPicker()
//            )
//        )
//        .app(app)
//    }
//}
