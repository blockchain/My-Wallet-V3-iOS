// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainComponentLibrary
import ComposableArchitecture
import ComposableNavigation
import FeatureNFTData
import FeatureNFTDomain
import Localization
import SwiftUI
import UIComponentsKit

public struct AssetListView: View {

    private typealias LocalizationId = LocalizationConstants.NFT.Screen.List

    @Environment(\.presentationMode) private var presentationMode

    let store: Store<AssetListViewState, AssetListViewAction>

    public init(store: Store<AssetListViewState, AssetListViewAction>) {
        self.store = store
    }

    public var body: some View {
        PrimaryNavigationView {
            contentView
        }
    }

    private var contentView: some View {
        WithViewStore(store) { viewStore in
            VStack {
                if viewStore.isLoading || viewStore.shouldShowErrorState {
                    LoadingStateView(title: LocalizationId.fetchingYourNFTs)
                } else if viewStore.isEmpty {
                    NoNFTsView(store: store)
                } else {
                    NFTListView(store: store)
                }
            }
            .onAppear { viewStore.send(.onAppear) }
        }
        .navigationRoute(in: store)
        .primaryNavigation()
    }

    struct NFTListView: View {

        @Environment(\.openURL) private var openURL

        let columns = [
            GridItem(.flexible(minimum: 100.0, maximum: 300)),
            GridItem(.flexible(minimum: 100.0, maximum: 300))
        ]

        let store: Store<AssetListViewState, AssetListViewAction>

        init(store: Store<AssetListViewState, AssetListViewAction>) {
            self.store = store
        }

        var body: some View {
            WithViewStore(store) { viewStore in
                ZStack(alignment: .bottom) {
                    ScrollView {
                        LazyVGrid(columns: columns, spacing: 16.0) {
                            ForEach(viewStore.assets) { asset in
                                AssetListItem(asset: asset)
                                    .onAppear {
                                        if viewStore.assets.last == asset {
                                            viewStore.send(.increaseOffset)
                                        }
                                    }
                                    .onTapGesture {
                                        viewStore.send(.assetTapped(asset))
                                    }
                            }
                        }
                        .padding()
                        if viewStore.isPaginating {
                            LoadingStateView(title: "")
                                .fixedSize()
                        }
                    }
                    Spacer()
                    PrimaryButton(
                        title: LocalizationId.shopOnOpenSea,
                        leadingView: {
                            Icon.newWindow
                                .frame(width: 24, height: 24)
                        },
                        action: {
                            if let url = URL(string: "https://www.opensea.io") {
                                openURL(url)
                            }
                        }
                    )
                    .padding([.leading, .trailing, .bottom], 24)
                }
            }
            .navigationRoute(in: store)
        }
    }

    struct AssetListItem: View {

        let asset: Asset

        init(asset: Asset) {
            self.asset = asset
        }

        var body: some View {
            AsyncMedia(
                url: URL(
                    string: asset.media.imagePreviewURL
                )
            )
            .aspectRatio(contentMode: .fill)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .shadow(
                color: .black.opacity(0.2),
                radius: 2.0,
                x: 0.0,
                y: 1.0
            )
        }
    }

    struct NoNFTsView: View {

        private typealias LocalizationId = LocalizationConstants.NFT.Screen.Empty

        @State private var isPressed: Bool = false

        let store: Store<AssetListViewState, AssetListViewAction>

        init(store: Store<AssetListViewState, AssetListViewAction>) {
            self.store = store
        }

        var body: some View {
            WithViewStore(store) { viewStore in
                VStack(alignment: .center, spacing: 16) {
                    Text(LocalizationId.headline)
                        .typography(.title1)
                        .multilineTextAlignment(.center)
                    Text(LocalizationId.subheadline)
                        .typography(.body1)
                        .multilineTextAlignment(.center)
                    Button(isPressed ? LocalizationId.copied : LocalizationId.copyEthAddress) {
                        viewStore.send(.copyEthereumAddressTapped)
                        isPressed.toggle()
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                            isPressed.toggle()
                        }
                    }
                    .foregroundColor(.white)
                    .typography(.body2)
                    .frame(maxWidth: .infinity, minHeight: ButtonSize.Standard.height)
                    .cornerRadius(ButtonSize.Standard.cornerRadius)
                    .background(
                        RoundedRectangle(cornerRadius: Spacing.buttonBorderRadius)
                            .fill(isPressed ? Color.semantic.success : Color.semantic.primary)
                    )
                }
                .padding([.leading, .trailing], 32.0)
            }
        }
    }
}

struct AssetListView_Previews: PreviewProvider {
    static var previews: some View {
        AssetListView(
            store: .init(
                initialState: .init(),
                reducer: assetListReducer,
                environment: .init(
                    assetProviderService: .previewEmpty
                )
            )
        )
    }
}
