// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainComponentLibrary
import BlockchainNamespace
import BlockchainUI
import ComposableArchitecture
import SwiftUI
import UnifiedActivityDomain
import UnifiedActivityUI

@available(iOS 15, *)
public struct ActivityDetailSceneView: View {
    @BlockchainApp var app
    @Environment(\.context) var context
    let store: StoreOf<ActivityDetailScene>

    @State private var scrollOffset: CGFloat = 0
    @StateObject private var scrollViewObserver = ScrollViewOffsetObserver()

    struct ViewState: Equatable {
        let items: ActivityDetail.GroupedItems?
        let isPlaceholder: Bool
        init(state: ActivityDetailScene.State) {
            items = state.items
            isPlaceholder = state.items == state.placeholderItems
        }
    }

    public init(store: StoreOf<ActivityDetailScene>) {
        self.store = store
    }

    public var body: some View {
        WithViewStore(store, observe: ViewState.init(state:)) { viewStore in
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
                        .redacted(reason: viewStore.isPlaceholder ? .placeholder : [])
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
                .findScrollView { scrollView in
                    scrollViewObserver.didScroll = { offset in
                        DispatchQueue.main.async {
                            $scrollOffset.wrappedValue = offset.y
                        }
                    }
                    scrollView.delegate = scrollViewObserver
                }
                .padding(.top, Spacing.padding3)
                .frame(maxHeight: .infinity)
                .onAppear {
                    viewStore.send(.onAppear)
                }
                .navigationBarHidden(true)
            }
            .superAppNavigationBar(
                title: { navigationTitleView(title: viewStore.items?.title, icon: viewStore.items?.icon) },
                trailing: { navigationTrailingView() },
                scrollOffset: $scrollOffset
            )
            .background(Color.semantic.light.ignoresSafeArea(edges: .bottom))
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

    @ViewBuilder
    func navigationTitleView(title: String?, icon: ImageType?) -> some View {
        imageView(with: icon)
        Text(title ?? "")
    }

    public func navigationTrailingView() -> some View {
        IconButton(icon: .closev2.circle()) {
            $app.post(event: blockchain.ux.activity.detail.article.plain.navigation.bar.button.close.tap)
        }
        .frame(width: 24.pt, height: 24.pt)
        .batch(
            .set(blockchain.ux.activity.detail.article.plain.navigation.bar.button.close.tap.then.close, to: true)
        )
    }

    @ViewBuilder
    @MainActor
    private func imageView(with image: ImageType?) -> some View {
        if #available(iOS 15.0, *) {
            switch image {
            case .smallTag(let model):
                ZStack(alignment: .bottomTrailing) {
                    AsyncMedia(url: URL(string: model.main ?? ""), placeholder: { EmptyView() })
                        .frame(width: 25, height: 25)
                        .background(Color.WalletSemantic.light, in: Circle())

                    AsyncMedia(url: URL(string: model.tag ?? ""), placeholder: { EmptyView() })
                        .frame(width: 12, height: 12)
                }
            case .singleIcon(let model):
                AsyncMedia(url: URL(string: model.url ?? ""), placeholder: { EmptyView() })
                    .frame(width: 25, height: 25)
                    .background(Color.WalletSemantic.light, in: Circle())
            case .none:
                EmptyView()
            }
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
