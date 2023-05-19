// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainComponentLibrary
import BlockchainNamespace
import ComposableArchitecture
import ComposableNavigation
import FeatureNFTData
import FeatureNFTDomain
import Localization
import SwiftUI
import UIComponentsKit

public struct AssetListSceneView: View {

    private typealias L10n = LocalizationConstants.NFT.Screen.List

    @BlockchainApp var app
    @Environment(\.presentationMode) private var presentationMode

    let store: Store<AssetListViewState, AssetListViewAction>

    @State private var scrollOffset: CGPoint = .zero

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
                    LoadingStateView(title: L10n.fetchingYourNFTs)
                } else if viewStore.isEmpty {
                    NoNFTsView(store: store)
                        .context([blockchain.coin.core.account.id: "ETH"])
                } else {
                    NFTListView(store: store, scrollOffset: $scrollOffset)
                }
            }
            .onAppear { viewStore.send(.onAppear) }
        }
        .navigationBarHidden(true)
        .background(Color.semantic.light.ignoresSafeArea())
        .navigationRoute(in: store)
        .superAppNavigationBar(
            leading: {
                dashboardLeadingItem
            },
            trailing: {
                dashboardTrailingItem
            },
            scrollOffset: $scrollOffset.y
        )
    }

    @ViewBuilder
    var dashboardLeadingItem: some View {
        IconButton(icon: .userv2.color(.semantic.title).small()) {
            app.post(
                event: blockchain.ux.user.account.entry.paragraph.button.icon.tap,
                context: [blockchain.ui.type.action.then.enter.into.embed.in.navigation: false]
            )
        }
        .batch {
            set(blockchain.ux.user.account.entry.paragraph.button.icon.tap.then.enter.into, to: blockchain.ux.user.account)
        }
        .id(blockchain.ux.user.account.entry.description)
        .accessibility(identifier: blockchain.ux.user.account.entry.description)
    }

    @ViewBuilder
    var dashboardTrailingItem: some View {
        IconButton(icon: .viewfinder.color(.semantic.title).small()) {
            app.post(
                event: blockchain.ux.scan.QR.entry.paragraph.button.icon.tap,
                context: [blockchain.ui.type.action.then.enter.into.embed.in.navigation: false]
            )
        }
        .batch {
            set(blockchain.ux.scan.QR.entry.paragraph.button.icon.tap.then.enter.into, to: blockchain.ux.scan.QR)
        }
        .id(blockchain.ux.scan.QR.entry.description)
        .accessibility(identifier: blockchain.ux.scan.QR.entry.description)
    }

    struct NFTListView: View {

        enum DisplayType: String {
            case collection
            case row

            var columns: [GridItem] {
                switch self {
                case .collection:
                    return [
                        GridItem(.flexible(minimum: 100.0, maximum: 300)),
                        GridItem(.flexible(minimum: 100.0, maximum: 500))
                    ]
                case .row:
                    return [
                        GridItem(.flexible(minimum: 100.0, maximum: .infinity))
                    ]
                }
            }
        }

        @Binding var myScrollOffset: CGPoint
        @State var displayType: NFTListView.DisplayType = .collection
        let store: Store<AssetListViewState, AssetListViewAction>

        init(store: Store<AssetListViewState, AssetListViewAction>, scrollOffset: Binding<CGPoint>) {
            self.store = store
            self._myScrollOffset = scrollOffset
        }

        var body: some View {
            WithViewStore(store) { viewStore in
                ZStack(alignment: .bottom) {
                    ScrollView {
                        HStack(alignment: .center) {
                            Text(L10n.title)
                                .typography(.paragraph2)
                                .foregroundColor(.semantic.title)
                            Spacer()
                            if displayType == .row {
                                Icon
                                    .listBullets
                                    .color(.semantic.title)
                                    .small()
                                    .onTapGesture {
                                        withAnimation {
                                            displayType = displayType == .collection ? .row : .collection
                                        }
                                    }
                            } else {
                                Icon
                                    .grid
                                    .color(.semantic.title)
                                    .small()
                                    .onTapGesture {
                                        withAnimation {
                                            displayType = displayType == .collection ? .row : .collection
                                        }
                                    }
                            }
                        }
                        .scrollOffset($myScrollOffset)
                        .padding([.leading, .trailing], Spacing.padding2)
                        .padding(.top, Spacing.padding3)
                        LazyVGrid(columns: displayType.columns, spacing: 16.0) {
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
                        .padding([.leading, .trailing, .bottom], Spacing.padding2)
                        .padding(.top, Spacing.padding1)
                        if viewStore.isPaginating {
                            LoadingStateView(title: "")
                                .fixedSize()
                        }
                        Rectangle()
                            .foregroundColor(Color.semantic.light)
                            .frame(height: 100)
                    }
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
                ),
                identifier: asset.id
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

        private typealias L10n = LocalizationConstants.NFT.Screen.Empty

        @BlockchainApp private var app
        @State private var isPressed: Bool = false
        @State private var isVerified: Bool = false
        @Environment(\.openURL) private var openURL
        @Environment(\.context) var context

        let store: Store<AssetListViewState, AssetListViewAction>

        init(store: Store<AssetListViewState, AssetListViewAction>) {
            self.store = store
        }

        var body: some View {
            WithViewStore(store) { _ in
                VStack(alignment: .center, spacing: 24) {
                    Spacer()
                    VStack(spacing: 8) {
                        Image("hero", bundle: .featureNFTUI)
                        Text(L10n.headline)
                            .typography(.title3)
                            .multilineTextAlignment(.center)
                        Text(L10n.subheadline)
                            .typography(.body1)
                            .foregroundColor(.semantic.text)
                            .multilineTextAlignment(.center)
                    }
                    HStack {
                        SecondaryButton(
                            title: L10n.buy,
                            leadingView: {
                                Icon
                                    .newWindow
                                    .small()
                            }
                        ) {
                            if let url = URL(string: "https://www.opensea.io") {
                                openURL(url)
                            }
                        }
                        PrimaryButton(
                            title: L10n.receive,
                            leadingView: {
                                Icon
                                    .walletReceive
                                    .frame(height: 20)
                            }
                        ) {
                            $app.post(event: blockchain.ux.nft.empty.receive.paragraph.button.primary.tap)
                        }
                    }
                    .padding(.bottom, 100)
                    Spacer()
                }
                .padding([.leading, .trailing], 32.0)
            }
            .bindings {
                subscribe($isVerified, to: blockchain.user.is.verified)
            }
            .batch {
                set(
                    blockchain.ux.nft.empty.receive.paragraph.button.primary.tap.then.enter.into,
                    to: isVerified ? blockchain.ux.currency.receive.address : blockchain.ux.kyc.trading.unlock.more
                )
            }
            .onAppear {
                $app.post(event: blockchain.ux.nft.empty)
            }
        }
    }
}

struct AssetListSceneView_Previews: PreviewProvider {
    static var previews: some View {
        AssetListSceneView.NoNFTsView(
            store: .init(
                initialState: .init(),
                reducer: assetListReducer,
                environment: .init(
                    assetProviderService: AssetProviderService.previewEmpty
                )
            )
        )
        .app(App.preview)
    }
}
