// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainComponentLibrary
import ComposableArchitecture
import FeatureNFTData
import FeatureNFTDomain
import Localization
import SwiftUI
import UIComponentsKit

public struct AssetDetailView: View {

    private typealias LocalizationId = LocalizationConstants.NFT.Screen.Detail

    @State private var webViewPresented = false
    @Environment(\.presentationMode) private var presentationMode
    private let url: URL
    private let store: Store<AssetDetailViewState, AssetDetailViewAction>

    public init(store: Store<AssetDetailViewState, AssetDetailViewAction>) {
        self.store = store
        self.url = ViewStore(store).asset.url
    }

    public var body: some View {
        content
    }

    private var content: some View {
        WithViewStore(store) { viewStore in
            let asset = viewStore.asset
            GeometryReader { proxy in
                ScrollView {
                    Capsule()
                        .fill(Color.semantic.dark)
                        .frame(width: 32.pt, height: 4.pt)
                        .foregroundColor(.semantic.muted)
                        .padding([.top], Spacing.padding2)
                    VStack(alignment: .center, spacing: 8.0) {
                        VStack(alignment: .center, spacing: 32) {
                            AssetMotionView(
                                url: asset.media.imageURL ?? asset.media.imagePreviewURL,
                                proxy: proxy,
                                button: {
                                    webViewPresented.toggle()
                                }
                            )
                            AssetDescriptionView(asset: asset)
                                .padding([.leading, .trailing], Spacing.padding2)
                        }
                        TraitGridView(asset: asset)
                            .padding(Spacing.padding2)
                    }
                }
                .frame(minHeight: proxy.size.height)
            }
            .background(Color.semantic.light.ignoresSafeArea())
            .navigationBarHidden(true)
        }
        .sheet(isPresented: $webViewPresented, content: {
            webView
        })
    }

    @ViewBuilder var webView: some View {
        WithViewStore(store) { viewStore in
            PrimaryNavigationView {
                WebView(url: url)
                    .primaryNavigation(
                        title: viewStore.asset.name,
                        trailing: {
                            IconButton(icon: .closev2.circle()) {
                                webViewPresented = false
                            }
                            .frame(width: 24.pt, height: 24.pt)
                        }
                    )
            }
        }
    }

    @ViewBuilder func dismiss() -> some View {
        IconButton(icon: .closev2.circle()) {
            presentationMode.wrappedValue.dismiss()
        }
        .frame(width: 24.pt, height: 24.pt)
    }

    private struct AssetMotionView: View {
        let url: String
        let proxy: GeometryProxy
        let button: () -> Void

        var body: some View {
            VStack(alignment: .center, spacing: 24.pt) {
                    ZStack {
                        AsyncMedia(
                            url: URL(string: url)
                        )
                        .cornerRadius(64)
                        .blur(radius: 30)
                        .opacity(0.9)
                        AssetViewRepresentable(
                            imageURL: URL(
                                string: url
                            ),
                            size: proxy.size.width - Spacing.padding4
                        )
                    }
                    .frame(minHeight: proxy.size.width - Spacing.padding4)
                    .padding([.top, .leading], Spacing.padding2)
                PrimaryWhiteButton(
                    title: LocalizationId.viewOnOpenSea,
                    leadingView: {
                        Icon
                            .newWindow
                            .frame(width: 24, height: 24)
                    },
                    action: {
                        button()
                    }
                )
                .padding([.leading, .trailing], Spacing.padding2)
            }
        }
    }

    private struct TraitGridView: View {

        let columns = [
            GridItem(.flexible(minimum: 100.0, maximum: 300)),
            GridItem(.flexible(minimum: 100.0, maximum: 300))
        ]

        private let asset: Asset

        init(asset: Asset) {
            self.asset = asset
        }

        var body: some View {
            VStack(alignment: .leading, spacing: Spacing.padding1) {
                Text(LocalizationId.properties)
                    .typography(.body2)
                    .foregroundColor(asset.traits.isEmpty ? .clear : .semantic.muted)
                    .frame(maxWidth: .infinity, alignment: .leading)
                VStack(spacing: 0) {
                    ForEach(asset.traits) {
                        TableRow(
                            title: TableRowTitle($0.type),
                            byline: TableRowByline($0.description)
                        )
                        .backport
                        .listDivider()
                    }
                }
                .background(
                    RoundedRectangle(cornerRadius: 16.0)
                        .foregroundColor(Color.semantic.background)
                )
            }
        }
    }

    private struct AssetDescriptionView: View {

        @State private var isExpanded: Bool = false

        let asset: Asset

        var body: some View {
            VStack(alignment: .leading, spacing: Spacing.padding2) {
                Text(asset.name)
                    .typography(.title2)
                    .frame(maxWidth: .infinity, alignment: .leading)
                TableRow(
                    leading: {
                        ZStack(alignment: .bottomTrailing) {
                            if let value = asset.collection.collectionImageUrl, value.isNotEmpty {
                                AsyncMedia(url: URL(string: value))
                                    .frame(width: 24, height: 24)
                                    .clipShape(RoundedRectangle(cornerRadius: 8.0))
                                    .shadow(
                                        color: .black.opacity(0.2),
                                        radius: 2.0,
                                        x: 0.0,
                                        y: 1.0
                                    )
                            } else {
                                Icon.user.color(.semantic.title).circle(backgroundColor: .semantic.light).small()
                            }
                            if asset.collection.isVerified {
                                Circle()
                                    .fill(.white)
                                    .frame(width: 12.0, height: 12.0)
                                    .overlay(
                                        Icon.verified
                                            .color(.semantic.gold)
                                            .frame(width: 9.0, height: 9.0)
                                    )
                                    .offset(x: 4.0, y: 4.0)
                            }
                    }
                    },
                    title: TableRowTitle(asset.creatorDisplayValue),
                    byline: TableRowByline(LocalizationId.creator)
                )
                .background(
                    RoundedRectangle(cornerRadius: Spacing.padding2)
                        .foregroundColor(Color.semantic.background)
                )

                if let collectionDescription = asset.collection.collectionDescription {
                    if collectionDescription != asset.nftDescription {
                        ExpandableRichTextBlock(
                            title: "\(LocalizationId.about) \(asset.collection.name)",
                            text: collectionDescription
                        )
                    }
                }
                if !asset.nftDescription.isEmpty {
                    ExpandableRichTextBlock(
                        title: LocalizationId.descripton,
                        text: asset.nftDescription
                    )
                }
            }
        }
    }

    private struct ExpandableRichTextBlock: View {

        @State private var isExpanded: Bool = false

        private let title: String
        private let text: String

        init(
            title: String,
            text: String
        ) {
            self.title = title
            self.text = text
        }

        var body: some View {
            VStack(alignment: .leading, spacing: Spacing.padding2) {
                Text(title)
                    .typography(.body2)
                    .foregroundColor(.semantic.title)
                    .frame(maxWidth: .infinity, alignment: .leading)
                Text(rich: text)
                    .lineLimit(isExpanded ? nil : 3)
                    .typography(.paragraph1)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .foregroundColor(.semantic.title)
                if !isExpanded, text.count > 160 {
                    SmallMinimalButton(title: LocalizationId.readMore) {
                        withAnimation {
                            isExpanded.toggle()
                        }
                    }
                }
            }
            .padding(16.0)
            .background(
                RoundedRectangle(cornerRadius: 16.0)
                    .foregroundColor(Color.semantic.background)
            )
        }
    }
}
