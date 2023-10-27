// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainComponentLibrary
import BlockchainNamespace
import Combine
import Dependencies
import DIKit
import FeatureNFTDomain
import MoneyKit
import SwiftUI

public struct NftAssetListSceneView: View {

    @BlockchainApp var app

    @StateObject private var model: Model = Model()

    @State var displayType: NFTListView.DisplayType = .collection

    @State private var selectedAsset: NFTAssets.Asset?

    public init() {}

    public var body: some View {
        VStack {
            if model.isLoading {
                loadingView()
            } else if let assets = model.assets {
                if assets.isEmpty {
                    NoNFTsView()
                        .context([blockchain.coin.core.account.id: "ETH"])
                } else {
                    mainContent()
                }
            }
        }
        .onAppear {
            model.prepare(app: app)
        }
        .onDisappear {
            model.deactivate()
        }
        .navigationBarHidden(true)
        .background(Color.semantic.light.ignoresSafeArea())
        .superAppNavigationBar(
            leading: {
                dashboardLeadingItem
            },
            trailing: {
                dashboardTrailingItem
            },
            scrollOffset: nil
        )
        .sheet(
            item: $selectedAsset,
            onDismiss: { selectedAsset = nil },
            content: { asset in
                NftAssetDetailView(asset: asset)
            }
        )
    }

    @ViewBuilder
    func mainContent() -> some View {
        VStack {
            HStack(alignment: .center) {
                NetworkPickerButton()
                Spacer()
                Button {
                    withAnimation {
                        displayType = displayType == .collection ? .row : .collection
                    }
                } label: {
                    Group {
                        if displayType == .row {
                            Icon
                                .listBullets
                                .color(.semantic.title)
                                .small()
                        } else {
                            Icon
                                .grid
                                .color(.semantic.title)
                                .small()
                        }
                    }
                    .padding(Spacing.padding2)
                    .background(Color.semantic.background)
                    .clipShape(RoundedRectangle(cornerRadius: Spacing.padding1, style: .continuous))
                }
            }
            .padding([.leading, .trailing], Spacing.padding2)
            .padding(.top, Spacing.padding1)
            NFTListView(
                assets: $model.filteredAssets,
                displayType: $displayType,
                onAssetTapped: { asset in
                    selectedAsset = asset
                }
            )
        }
    }

    @ViewBuilder
    func loadingView() -> some View {
        VStack {
            Spacer()
            HStack {
                Spacer()
                BlockchainProgressView()
                    .transition(.opacity)
                Spacer()
            }
            Spacer()
        }
        .background(Color.semantic.light.ignoresSafeArea())
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

        @Binding var assets: [NFTAssets.Asset]
        @Binding var displayType: NFTListView.DisplayType

        private var onAssetTapped: (NFTAssets.Asset) -> Void

        init(
            assets: Binding<[NFTAssets.Asset]>,
            displayType: Binding<NFTListView.DisplayType>,
            onAssetTapped: @escaping (NFTAssets.Asset) -> Void
        ) {
            self._displayType = displayType
            self._assets = assets
            self.onAssetTapped = onAssetTapped
        }

        var body: some View {
            ZStack(alignment: .bottom) {
                if assets.isEmpty {
                    NoNFTsView()
                        .context([blockchain.coin.core.account.id: "ETH"])
                } else {
                    ScrollView {
                        LazyVGrid(columns: displayType.columns, spacing: 16.0) {
                            ForEach(assets) { asset in
                                if let imageUrl = asset.value.media?.collection?.medium.url {
                                    AssetListItem(assetImageUrl: imageUrl, assetId: asset.id, network: asset.network)
                                        .onTapGesture {
                                            onAssetTapped(asset)
                                        }
                                }
                            }
                        }
                        .padding([.leading, .trailing, .bottom], Spacing.padding2)
                        .padding(.top, Spacing.padding1)
                        Rectangle()
                            .foregroundColor(Color.semantic.light)
                            .frame(height: 100)
                    }
                }
            }
        }
    }

    struct AssetListItem: View {

        let assetImageUrl: String
        let assetId: String
        let network: EVMNetwork

        init(assetImageUrl: String, assetId: String, network: EVMNetwork) {
            self.assetImageUrl = assetImageUrl
            self.assetId = assetId
            self.network = network
        }

        var body: some View {
            ZStack(alignment: .bottomTrailing) {
                AsyncMedia(
                    url: URL(
                        string: assetImageUrl
                    ),
                    identifier: assetId,
                    placeholder: {
                        Image("nft-placeholder", bundle: .featureNFTUI)
                            .resizable()
                            .aspectRatio(1, contentMode: .fill)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                    }
                )
                .aspectRatio(contentMode: .fill)
                AsyncMedia(url: network.logoURL)
                    .padding([.trailing, .bottom], Spacing.padding1)
                    .frame(width: 32, height: 32)
            }
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

        @BlockchainApp private var app
        @State private var isPressed: Bool = false
        @State private var isVerified: Bool = false
        @Environment(\.openURL) private var openURL
        @Environment(\.context) var context

        var body: some View {
            VStack(alignment: .center, spacing: 24) {
                Spacer()
                VStack(spacing: 8) {
                    Image("hero", bundle: .featureNFTUI)
                    Text(L10n.Screen.Empty.headline)
                        .typography(.title3)
                        .multilineTextAlignment(.center)
                    Text(L10n.Screen.Empty.subheadline)
                        .typography(.body1)
                        .foregroundColor(.semantic.text)
                        .multilineTextAlignment(.center)
                }
                HStack {
                    SecondaryButton(
                        title: L10n.Screen.Empty.buy,
                        leadingView: {
                            Icon
                                .newWindow
                                .small()
                        },
                        action: {
                            if let url = URL(string: "https://www.opensea.io") {
                                openURL(url)
                            }
                        }
                    )
                    PrimaryButton(
                        title: L10n.Screen.Empty.receive,
                        leadingView: {
                            Icon
                                .walletReceive
                                .frame(height: 20)
                        },
                        action: {
                            $app.post(event: blockchain.ux.nft.empty.receive.paragraph.button.primary.tap)
                        }
                    )
                }
                .padding(.bottom, 100)
                Spacer()
            }
            .padding([.leading, .trailing], 32.0)
            .bindings {
                subscribe($isVerified, to: blockchain.user.is.verified)
            }
            .batch {
                if app.currentMode == .pkw {
                    set(
                        blockchain.ux.nft.empty.receive.paragraph.button.primary.tap.then.enter.into,
                        to: blockchain.ux.currency.receive.address
                    )
                } else {
                    set(
                        blockchain.ux.nft.empty.receive.paragraph.button.primary.tap.then.enter.into,
                        to: isVerified ? blockchain.ux.currency.receive.address : blockchain.ux.kyc.trading.unlock.more
                    )
                }
            }
            .onAppear {
                $app.post(event: blockchain.ux.nft.empty)
            }
        }
    }
}

extension NftAssetListSceneView {
    class Model: ObservableObject {
        @Dependency(\.assetProviderService) var service

        @Published var isActive: Bool = false
        @Published var isLoading: Bool = false

        @Published var assets: [NFTAssets.Asset]?
        @Published var filteredAssets: [NFTAssets.Asset] = []

        func prepare(app: AppProtocol) {
            isActive = true

            app.on(blockchain.ux.home.event.did.pull.to.refresh)
                .mapToVoid()
                .prepend(())
                .combineLatest($isActive)
                .filter { _, active in active }
                .flatMap { [service] _ -> AnyPublisher<[NFTAssets.Asset], Never> in
                    service.fetchAssets()
                        .map(\.assets)
                        .replaceError(with: [])
                        .eraseToAnyPublisher()
                }
                .receive(on: DispatchQueue.main)
                .assign(to: &$assets)

            $assets
                .map { $0 == nil }
                .receive(on: DispatchQueue.main)
                .assign(to: &$isLoading)

            app.publisher(for: blockchain.ux.nft.network.picker.selected.network, as: Network.self)
                .compactMap(\.value)
                .prepend(.all)
                .combineLatest($assets)
                .map { network, assets in
                    guard let assets else { return [] }
                    switch network {
                    case .specific(let value):
                        return assets.filter { $0.network == value }
                    case .all:
                        return assets
                    }
                }
                .receive(on: DispatchQueue.main)
                .assign(to: &$filteredAssets)
        }

        func deactivate() {
            isActive = false
        }
    }
}

public struct AssetProviderRepositoryDependencyKey: DependencyKey {
    public static var liveValue: AssetProviderServiceAPI = DIKit.resolve()
}

extension DependencyValues {
    public var assetProviderService: AssetProviderServiceAPI {
        get { self[AssetProviderRepositoryDependencyKey.self] }
        set { self[AssetProviderRepositoryDependencyKey.self] = newValue }
    }
}
