// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainComponentLibrary
import BlockchainNamespace
import BlockchainUI
import ComposableArchitecture
import SwiftUI
import UnifiedActivityDomain
import UnifiedActivityUI

public struct ActivityDetailSceneView: View {
    @BlockchainApp var app
    @Environment(\.context) var context
    let store: StoreOf<ActivityDetailScene>

    public init(store: StoreOf<ActivityDetailScene>) {
        self.store = store
    }

    public var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            ZStack(alignment: .top) {
                ScrollView {
                    VStack {
                        if let groups = viewStore.items {
                            ForEach(groups.itemGroups) { item in
                                VStack(spacing: 0) {
                                    ForEach(item.itemGroup) { itemType in
                                        Group {
                                            ActivityRow(itemType: itemType)
                                            if itemType.id != item.itemGroup.last?.id {
                                                Divider()
                                            }
                                        }
                                    }
                                }
                                .cornerRadius(16)
                                .padding(.horizontal, Spacing.padding2)
                                .padding(.bottom)
                            }
                        } else {
                            loadingSection
                                .padding(.horizontal, Spacing.padding2)
                        }

                        if let floatingActions = viewStore.items?.floatingActions {
                            VStack {
                                ForEach(floatingActions) { actionButton in
                                    FloatingButton(button: actionButton)
                                        .context([blockchain.ux.activity.detail.floating.button.id: actionButton.id])
                                }
                            }
                            .padding(.horizontal, Spacing.padding2)
                        }
                    }
                    .padding(.top, 100)
                    .frame(maxHeight: .infinity)
                    .background(Color.WalletSemantic.light)
                    .onAppear {
                        viewStore.send(.onAppear)
                    }
                }.navigationBarHidden(true)

                navigationView()
                    .padding(.top, Spacing.padding1)
            }
        }
    }

    struct FloatingButton: View {
        let tag = blockchain.ux.activity.detail.floating.button

        @BlockchainApp var app
        let button: ActivityItem.Button

        var body: some View {
            Group {
                switch button.style {
                case .primary:
                    PrimaryButton(title: button.text) {
                        $app.post(event: tag.tap)
                    }
                case .secondary:
                    SecondaryButton(title: button.text) {
                        $app.post(event: tag.tap)
                    }
                }
            }
            .set(tag.tap, to: button.action)
        }
    }

    public func navigationView() -> some View {
        ZStack(alignment: .trailing) {
            HStack(
                alignment: .center,
                spacing: Spacing.padding1,
                content: {
                imageView(with: ViewStore(store).items?.icon)
                Text(ViewStore(store).items?.title ?? "")
                }
            )
            .frame(maxWidth: .infinity)
            .frame(height: 48)
            .background(Color.WalletSemantic.light)
            .cornerRadius(16)
            .shadow(color: Color(red: 0, green: 0, blue: 0, opacity: 0.11), radius: 8, y: 3)
            .padding(.horizontal, Spacing.padding1)

            IconButton(icon: .closev2.circle()) {
                $app.post(event: blockchain.ux.activity.detail.article.plain.navigation.bar.button.close.tap)
            }
            .frame(width: 24.pt, height: 24.pt)
            .batch(
                .set(blockchain.ux.activity.detail.article.plain.navigation.bar.button.close.tap.then.close, to: true)
            )
            .padding(.horizontal, Spacing.padding2)
        }
    }

    @ViewBuilder
    @MainActor
    private func imageView(with image: ImageType?) -> some View {
        if #available(iOS 15.0, *) {
            switch image {
            case .smallTag(let smallTagImage):
                ZStack(alignment: .bottomTrailing) {
                    AsyncMedia(url: URL(string: smallTagImage.main ?? ""), placeholder: { EmptyView() })
                        .frame(width: 25, height: 25)
                        .background(Color.WalletSemantic.light, in: Circle())

                    AsyncMedia(url: URL(string: smallTagImage.tag ?? ""), placeholder: { EmptyView() })
                        .frame(width: 12, height: 12)
                }
            case .none:
                EmptyView()
            }
        } else {
            // Fallback on earlier versions
        }
    }

    private var loadingSection: some View {
        Group {
            SimpleBalanceRow(leadingTitle: "", trailingDescription: nil, leading: {})
            Divider()
                .foregroundColor(.WalletSemantic.light)
            SimpleBalanceRow(leadingTitle: "", trailingDescription: nil, leading: {})
        }
    }
}

extension ItemType: Identifiable {
    public var id: String {
        switch self {
        case .compositionView(let compositionView):
            return compositionView.leading.reduce(into: "") { partialResult, item in
                partialResult += item.id
            }

        case .leaf(let ItemType):
            return ItemType.id
        }
    }
}
