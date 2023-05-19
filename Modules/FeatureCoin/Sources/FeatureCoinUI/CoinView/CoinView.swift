// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainComponentLibrary
import BlockchainNamespace
import Combine
import ComposableArchitecture
import ComposableArchitectureExtensions
import FeatureCoinDomain
import Localization
import SwiftUI
import ToolKit

public struct CoinView: View {
    let store: Store<CoinViewState, CoinViewAction>
    @ObservedObject var viewStore: ViewStore<CoinViewState, CoinViewAction>

    @BlockchainApp var app
    @Environment(\.context) var context
    @State private var isVerified: Bool = true

    @State private var scrollOffset: CGPoint = .zero

    public init(store: Store<CoinViewState, CoinViewAction>) {
        self.store = store
        _viewStore = .init(initialValue: ViewStore(store))
    }

    typealias Localization = LocalizationConstants.Coin

    public var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ScrollView {
                header()
                allActionsList()
                VStack(alignment: .leading, spacing: Spacing.padding4) {
                    accounts()
                    if viewStore.shouldShowRecurringBuy {
                        recurringBuys()
                    }
                    about()
                    news()
                }
                .scrollOffset($scrollOffset)
                Color.clear
                    .frame(height: Spacing.padding2)
            }
            if viewStore.accounts.isNotEmpty, viewStore.primaryActions.isNotEmpty {
                primaryActions()
            }
        }
        .modifier(NavigationModifier(viewStore: viewStore, scrollOffset: $scrollOffset))
        .frame(
            maxWidth: .infinity,
            maxHeight: .infinity
        )
        .background(Color.semantic.light.ignoresSafeArea(edges: .bottom))
        .onAppear { viewStore.send(.onAppear) }
        .onDisappear { viewStore.send(.onDisappear) }
        .bindings {
            subscribe($isVerified, to: blockchain.user.is.verified)
        }
        .batch {
            set(blockchain.ux.asset.receive.then.enter.into, to: isVerified ? blockchain.ux.currency.receive.address : blockchain.ux.kyc.trading.unlock.more)
            if let accountId = viewStore.accounts.first?.id {
                set(blockchain.ux.asset.account[accountId].receive.then.enter.into, to: isVerified ? blockchain.ux.currency.receive.address : blockchain.ux.kyc.trading.unlock.more)
            }
        }
        .bottomSheet(
            item: viewStore.binding(\.$account).animation(.spring()),
            content: { account in
                AccountSheet(
                    account: account,
                    isVerified: viewStore.kycStatus != .unverified,
                    onClose: {
                        viewStore.send(.set(\.$account, nil), animation: .spring())
                    }
                )
                .context(
                    [
                        blockchain.ux.asset.account.id: account.id,
                        blockchain.ux.asset.account: account,
                        blockchain.coin.core.account.id: account.id
                    ]
                )
            }
        )
        .bottomSheet(
            item: viewStore.binding(\.$explainer).animation(.spring()),
            content: { account in
                AccountExplainer(
                    account: account,
                    onClose: {
                        viewStore.send(.set(\.$explainer, nil), animation: .spring())
                    }
                )
                .context(
                    [
                        blockchain.ux.asset.account.id: account.id,
                        blockchain.ux.asset.account: account
                    ]
                )
            }
        )
    }

    @ViewBuilder func header() -> some View {
        GraphView(
            store: store.scope(state: \.graph, action: CoinViewAction.graph)
        )
    }

    @ViewBuilder func recurringBuys() -> some View {
        RecurringBuyListView(
            buys: viewStore.recurringBuys,
            location: .coin(asset: viewStore.currency.code),
            showsManageButton: .constant(false)
        )
    }

    @ViewBuilder func allActionsList() -> some View {
        ActionsView(actions: viewStore.allActions)
            .context([
                blockchain.ux.asset.account.id: viewStore.accounts.first?.id,
                blockchain.coin.core.account.id: viewStore.accounts.first?.id
            ])
    }

    @ViewBuilder func accounts() -> some View {
        VStack {
            if viewStore.error == .failedToLoad {
                AlertCard(
                    title: Localization.Accounts.Error.title,
                    message: Localization.Accounts.Error.message,
                    variant: .error,
                    isBordered: true
                )
                .padding([.leading, .trailing, .top], Spacing.padding2)
            } else if viewStore.currency.isTradable {
                if let status = viewStore.kycStatus {
                    SectionHeader(
                        title: Localization.Header.balance,
                        variant: .superapp
                    ) {
                        Text(viewStore.accounts.fiatBalance?.displayString ?? 6.of(".").joined())
                            .typography(.body2)
                            .foregroundColor(.WalletSemantic.title)
                    }
                    .padding([.top], 8.pt)
                    .padding(.horizontal, Spacing.padding2)
                    AccountListView(
                        accounts: viewStore.accounts,
                        currency: viewStore.currency,
                        earnRates: viewStore.earnRates,
                        kycStatus: status
                    )
                }
            } else {
                AlertCard(
                    title: Localization.Label.Title.notTradable.interpolating(
                        viewStore.currency.name,
                        viewStore.currency.displayCode
                    ),
                    message: Localization.Label.Title.notTradableMessage.interpolating(
                        viewStore.currency.name,
                        viewStore.currency.displayCode
                    )
                )
                .padding([.leading, .trailing], Spacing.padding2)
            }
        }
        .background(Color.WalletSemantic.light)
    }

    @ViewBuilder func news() -> some View {
        NewsSectionView(api: blockchain.api.news.asset, seeAll: false)
            .context([blockchain.api.news.asset.id: viewStore.currency.code])
    }

    @State private var isExpanded: Bool = false

    @ViewBuilder func about() -> some View {
        if viewStore.assetInformation?.description.nilIfEmpty == nil, viewStore.assetInformation?.website == nil {
            EmptyView()
        } else {
            VStack(alignment: .leading, spacing: .zero) {
                Text(Localization.Label.Title.aboutCrypto.interpolating(viewStore.currency.name))
                    .typography(.body2)
                    .foregroundColor(.semantic.body)
                    .padding(.horizontal, Spacing.padding2)
                if let about = viewStore.assetInformation?.description, about.isNotEmpty {
                    VStack(alignment: .leading, spacing: Spacing.padding2) {
                                Text(rich: about)
                                    .lineLimit(isExpanded ? nil : 6)
                                    .typography(.paragraph1)
                                    .foregroundColor(.semantic.title)
                                if !isExpanded {
                                    SmallMinimalButton(
                                        title: Localization.Button.Title.readMore,
                                        action: {
                                            withAnimation {
                                                isExpanded.toggle()
                                            }
                                        }
                                    )
                                }
                    }
                    .padding(Spacing.padding2)
                    .background(Color.semantic.background)
                    .cornerRadius(16)
                    .padding(.horizontal, Spacing.padding2)
                    .padding(.top, Spacing.padding1)
                }
                HStack {
                    if let url = viewStore.assetInformation?.website {
                        SmallMinimalButton(
                            title: Localization.Link.Title.visitWebsite,
                            leadingView: {
                                Icon.globe.frame(width: 16.pt)
                            },
                            action: {
                                $app.post(event: blockchain.ux.asset.bio.visit.website)
                            }
                        )
                        .batch {
                            set(blockchain.ux.asset.bio.visit.website.then.enter.into, to: blockchain.ux.web[url])
                        }
                    }
                    if let url = viewStore.assetInformation?.whitepaper {
                        SmallMinimalButton(
                            title: Localization.Link.Title.visitWhitepaper,
                            leadingView: {
                                Icon.link
                                .color(.semantic.light)
                                .circle(backgroundColor: .semantic.primary)
                                .frame(width: 16.pt)
                            },
                            action: {
                                $app.post(event: blockchain.ux.asset.bio.visit.whitepaper)
                            }
                        )
                        .batch {
                            set(blockchain.ux.asset.bio.visit.whitepaper.then.enter.into, to: blockchain.ux.web[url])
                        }
                    }
                    Spacer()
                }
                .padding(.horizontal, Spacing.padding2)
                .padding(.top, Spacing.padding2)
            }
            .frame(maxWidth: .infinity)
        }
    }

    @ViewBuilder func primaryActions() -> some View {
        VStack(spacing: 0) {
            PrimaryDivider()
            HStack(spacing: 8.pt) {
                ForEach(viewStore.primaryActions, id: \.event) { action in
                    SecondaryButton(
                        title: action.title,
                        leadingView: { action.icon.color(.white)
                                .frame(width: 14, height: 14)
                        },
                        action: {
                            $app.post(
                                event: action.event,
                                context: [blockchain.coin.core.account.id: viewStore.accounts.first?.id]
                            )
                        }
                    )
                }
            }
            .padding(.horizontal, Spacing.padding2)
            .padding(.top, Spacing.padding2)
        }
    }
}

private struct NavigationModifier: ViewModifier {
    @ObservedObject var viewStore: ViewStore<CoinViewState, CoinViewAction>
    @Binding var scrollOffset: CGPoint

    init(viewStore: ViewStore<CoinViewState, CoinViewAction>, scrollOffset: Binding<CGPoint>) {
        self.viewStore = viewStore
        self._scrollOffset = scrollOffset
    }

    @ViewBuilder
    func body(content: Content) -> some View {
        if #available(iOS 15, *) {
            content
                .superAppNavigationBar(
                    leading: {
                        navigationLeadingView()
                    },
                    title: {
                        navigationTitleView(
                            title: viewStore.currency.name,
                            iconUrl: viewStore.currency.assetModel.logoPngUrl
                        )
                    },
                    trailing: {
                        dismiss()
                    },
                    scrollOffset: $scrollOffset.y
                )
                .navigationBarHidden(true)
        } else {
            content
                .primaryNavigation(
                    leading: navigationLeadingView,
                    title: viewStore.currency.name,
                    trailing: {
                        dismiss()
                    }
                )
        }
    }

    @MainActor @ViewBuilder
    func navigationTitleView(title: String?, iconUrl: URL?) -> some View {
        if let url = iconUrl {
            AsyncMedia(
                url: url,
                content: { media in
                    media.cornerRadius(12)
                },
                placeholder: {
                    Color.semantic.muted
                        .opacity(0.3)
                        .overlay(
                            ProgressView()
                                .progressViewStyle(.circular)
                        )
                        .clipShape(Circle())
                }
            )
            .resizingMode(.aspectFit)
            .frame(width: 24.pt, height: 24.pt)
        }

        Text(title ?? "")
            .typography(.body2)
            .foregroundColor(.WalletSemantic.title)
    }

    @ViewBuilder func navigationLeadingView() -> some View {
        if let isFavorite = viewStore.isFavorite {
            if isFavorite {
                IconButton(icon: .favorite.color(.semantic.title)) {
                    viewStore.send(.removeFromWatchlist)
                }
                .frame(width: 20, height: 20)
            } else {
                IconButton(icon: .favoriteEmpty.color(.semantic.title)) {
                    viewStore.send(.addToWatchlist)
                }
                .frame(width: 20, height: 20)
            }
        } else {
            ProgressView()
                .progressViewStyle(.circular)
                .frame(width: 28, height: 28)
        }
    }

    @ViewBuilder func dismiss() -> some View {
        IconButton(icon: .closeCirclev3
            .color(.black))
        {
            viewStore.send(.dismiss)
        }
        .frame(width: 20, height: 20)
    }
}

// swiftlint:disable type_name
struct CoinView_PreviewProvider: PreviewProvider {

    static var previews: some View {

        PrimaryNavigationView {
            CoinView(
                store: .init(
                    initialState: .init(
                        currency: .bitcoin,
                        kycStatus: .gold,
                        accounts: [
                            .preview.privateKey,
                            .preview.trading,
                            .preview.rewards
                        ],
                        isFavorite: true,
                        graph: .init(
                            interval: .day,
                            result: .success(.preview)
                        )
                    ),
                    reducer: coinViewReducer,
                    environment: .preview
                )
            )
            .app(App.preview)
        }
        .previewDevice("iPhone SE (2nd generation)")
        .previewDisplayName("Gold - iPhone SE (2nd generation)")

        PrimaryNavigationView {
            CoinView(
                store: .init(
                    initialState: .init(
                        currency: .bitcoin,
                        kycStatus: .gold,
                        accounts: [
                            .preview.privateKey,
                            .preview.trading,
                            .preview.rewards
                        ],
                        isFavorite: true,
                        graph: .init(
                            interval: .day,
                            result: .success(.preview)
                        )
                    ),
                    reducer: coinViewReducer,
                    environment: .preview
                )
            )
            .app(App.preview)
        }
        .previewDevice("iPhone 13 Pro Max")
        .previewDisplayName("Gold - iPhone 13 Pro Max")

        PrimaryNavigationView {
            CoinView(
                store: .init(
                    initialState: .init(
                        currency: .nonTradable,
                        kycStatus: .unverified,
                        accounts: [
                            .preview.rewards
                        ],
                        isFavorite: false,
                        graph: .init(
                            interval: .day,
                            result: .success(.preview)
                        )
                    ),
                    reducer: coinViewReducer,
                    environment: .preview
                )
            )
            .app(App.preview)
        }
        .previewDisplayName("Not Tradable")

        PrimaryNavigationView {
            CoinView(
                store: .init(
                    initialState: .init(
                        currency: .bitcoin,
                        kycStatus: .unverified,
                        accounts: [
                            .preview.privateKey
                        ],
                        isFavorite: false,
                        graph: .init(
                            interval: .day,
                            result: .success(.preview)
                        )
                    ),
                    reducer: coinViewReducer,
                    environment: .preview
                )
            )
            .app(App.preview)
        }
        .previewDisplayName("Unverified")

        PrimaryNavigationView {
            CoinView(
                store: .init(
                    initialState: .init(
                        currency: .stellar,
                        isFavorite: nil,
                        graph: .init(isFetching: true)
                    ),
                    reducer: coinViewReducer,
                    environment: .previewEmpty
                )
            )
            .app(App.preview)
        }
        .previewDisplayName("Loading")

        PrimaryNavigationView {
            CoinView(
                store: .init(
                    initialState: .init(
                        currency: .bitcoin,
                        kycStatus: .unverified,
                        error: .failedToLoad,
                        isFavorite: false,
                        graph: .init(
                            interval: .day,
                            result: .failure(.init(request: nil, type: .serverError(.badResponse)))
                        )
                    ),
                    reducer: coinViewReducer,
                    environment: .previewEmpty
                )
            )
            .app(App.preview)
        }
        .previewDisplayName("Error")
    }
}
