// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainComponentLibrary
import FeatureNFTDomain
import SwiftUI

struct NftAssetDetailView: View {
    @State private var webViewPresented = false
    @Environment(\.presentationMode) private var presentationMode
    private let url: URL
    private let asset: NFTAssets.Asset

    init(asset: NFTAssets.Asset) {
        self.asset = asset
        self.url = asset.assetUrl
    }

    var body: some View {
        GeometryReader { proxy in
            ScrollView {
                Capsule()
                    .fill(Color.semantic.dark)
                    .frame(width: 32.pt, height: 4.pt)
                    .foregroundColor(.semantic.muted)
                    .padding([.top], Spacing.padding2)
                VStack(alignment: .center, spacing: 8.0) {
                    VStack(alignment: .center, spacing: 32) {
                        if let url = asset.value.media?.collection?.medium.url {
                            AssetMotionView(
                                url: url,
                                proxy: proxy,
                                button: {
                                    webViewPresented.toggle()
                                }
                            )
                        }
                        AssetDescriptionView(asset: asset)
                            .padding([.leading, .trailing], Spacing.padding2)
                        networkContent
                            .padding([.leading, .trailing], Spacing.padding2)
                    }
                    if let metadata = asset.value.metadata?.atributes {
                        TraitGridView(metadata: metadata)
                            .padding(Spacing.padding2)
                    }
                }
            }
            .frame(minHeight: proxy.size.height)
        }
        .background(Color.semantic.light.ignoresSafeArea())
        .navigationBarHidden(true)
        .sheet(isPresented: $webViewPresented, content: {
            webView
        })
    }

    @ViewBuilder var webView: some View {
        PrimaryNavigationView {
            WebView(url: url)
                .primaryNavigation(
                    title: "",
                    trailing: {
                        IconButton(icon: .navigationCloseButton()) {
                            webViewPresented = false
                        }
                        .frame(width: 24.pt, height: 24.pt)
                    }
                )
        }
    }

    @ViewBuilder var networkContent: some View {
        VStack(alignment: .leading, spacing: Spacing.padding1) {
            Text(L10n.Screen.Detail.network)
                .typography(.body2)
                .foregroundColor(.semantic.text)
            HStack(spacing: Spacing.padding1) {
                asset.network.logoResource.image
                    .frame(width: 24.pt, height: 24.pt)
                Text(asset.network.networkConfig.shortName)
                    .typography(.paragraph2)
                    .foregroundColor(.semantic.title)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(Spacing.padding2)
            .background(
                RoundedRectangle(cornerRadius: 16.0)
                    .foregroundColor(Color.semantic.background)
            )
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    @ViewBuilder func dismiss() -> some View {
        IconButton(icon: .navigationCloseButton()) {
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
                        imageURL: URL(string: url),
                        size: proxy.size.width - Spacing.padding4
                    )
                }
                .frame(minHeight: proxy.size.width - Spacing.padding4)
                .padding([.top, .leading], Spacing.padding2)
                MinimalButton(
                    title: L10n.Screen.Detail.viewOnOpenSea,
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

        private let metadata: [AssetAttribute]

        init(metadata: [AssetAttribute]) {
            self.metadata = metadata
        }

        var body: some View {
            VStack(alignment: .leading, spacing: Spacing.padding1) {
                Text(L10n.Screen.Detail.properties)
                    .typography(.body2)
                    .foregroundColor(metadata.isEmpty ? .clear : .semantic.text)
                    .frame(maxWidth: .infinity, alignment: .leading)
                VStack(spacing: 0) {
                    ForEach(metadata) {
                        TableRow(
                            title: TableRowTitle($0.name),
                            byline: TableRowByline($0.value)
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

        let asset: NFTAssets.Asset

        var body: some View {
            VStack(alignment: .leading, spacing: Spacing.padding2) {
                Text(asset.value.name ?? "")
                    .typography(.title2)
                    .frame(maxWidth: .infinity, alignment: .leading)
                TableRow(
                    leading: {
                        ZStack(alignment: .bottomTrailing) {
                            if let value = asset.value.media?.collection?.medium.url, value.isNotEmpty {
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
                        }
                    },
                    title: TableRowTitle(asset.creatorDisplayValue ?? ""),
                    byline: TableRowByline(L10n.Screen.Detail.creator)
                )
                .background(
                    RoundedRectangle(cornerRadius: Spacing.padding2)
                        .foregroundColor(Color.semantic.background)
                )

                if let description = asset.value.metadata?.description, !description.isEmpty {
                    ExpandableRichTextBlock(
                        title: L10n.Screen.Detail.descripton,
                        text: description
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
                    .foregroundColor(.semantic.text)
                    .frame(maxWidth: .infinity, alignment: .leading)
                VStack(alignment: .leading, spacing: Spacing.padding2) {
                    Text(rich: text)
                        .lineLimit(isExpanded ? nil : 3)
                        .typography(.paragraph1)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .foregroundColor(.semantic.title)
                    if !isExpanded, text.count > 160 {
                        SmallMinimalButton(title: L10n.Screen.Detail.readMore) {
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
}
