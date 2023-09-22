// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainNamespace
import BlockchainUI
import Combine
import ComposableArchitecture
import ComposableArchitectureExtensions
import FeatureCoinDomain
import Localization
import MoneyKit
import SwiftUI
import ToolKit

public struct CoinView: View {

    private typealias Localization = LocalizationConstants.Coin
    private typealias RejectedL10n = LocalizationConstants.SuperApp.Dashboard.GetStarted.Trading

    let store: Store<CoinViewState, CoinViewAction>
    @ObservedObject var viewStore: ViewStore<CoinViewState, CoinViewAction>

    @BlockchainApp var app
    @Environment(\.context) var context
    @State private var isVerified: Bool = true
    @State private var isRejected: Bool = false
    @State private var supportURL: URL?
    @State private var isExpanded: Bool = false
    @State private var scrollOffset: CGPoint = .zero

    public init(store: Store<CoinViewState, CoinViewAction>) {
        self.store = store
        _viewStore = .init(initialValue: ViewStore(store))
    }

    @ViewBuilder
    public var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ScrollView {
                header()
                allActionsList()
                if isRejected {
                    rejectedView
                }
                VStack(alignment: .leading, spacing: Spacing.padding4) {
                    accounts()
                    if viewStore.shouldShowRecurringBuy {
                        recurringBuys()
                    }
                    about()
                    news()

                    if viewStore.shouldDisplayBakktLogo {
                        bakktLogo()
                    }
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
            subscribe($isVerified, to: blockchain.user.account.kyc.state, as: \Tag[is: blockchain.user.account.kyc.state.verified])
            subscribe($isRejected, to: blockchain.user.account.kyc.state, as: \Tag[is: blockchain.user.account.kyc.state.rejected])
        }
        .batch {
            if let accountId = viewStore.accounts.first?.id {
                if app.currentMode == .trading {
                    set(blockchain.ux.asset.account[accountId].receive.then.enter.into, to: isVerified ? blockchain.ux.currency.receive.address : blockchain.ux.kyc.trading.unlock.more)
                } else {
                    set(blockchain.ux.asset.account[accountId].receive.then.enter.into, to: blockchain.ux.currency.receive.address)
                }
            }
            if app.currentMode == .trading {
                set(blockchain.ux.asset.receive.then.enter.into, to: isVerified ? blockchain.ux.currency.receive.address : blockchain.ux.kyc.trading.unlock.more)
            } else {
                set(blockchain.ux.asset.receive.then.enter.into, to: blockchain.ux.currency.receive.address)
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

    @ViewBuilder
    var rejectedView: some View {
        AlertCard(
            title: RejectedL10n.weCouldNotVerify,
            message: RejectedL10n.unableToVerifyGoToDeFi,
            variant: .warning,
            isBordered: true,
            footer: {
                VStack {
                    SmallSecondaryButton(
                        title: RejectedL10n.blockedContactSupport,
                        action: {
                            $app.post(event: blockchain.ux.asset.kyc.is.rejected.contact.support.paragraph.button.small.secondary.tap)
                        }
                    )
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        )
        .padding(.horizontal)
        .onAppear {
            $app.post(event: blockchain.ux.asset.kyc.is.rejected)
        }
        .bindings {
            subscribe($supportURL, to: blockchain.ux.kyc.is.rejected.support.url)
        }
        .batch {
            if let supportURL {
                set(blockchain.ux.asset.kyc.is.rejected.contact.support.paragraph.button.small.secondary.tap.then.enter.into, to: blockchain.ux.web[supportURL])
            }
        }
    }

    @ViewBuilder
    func header() -> some View {
        GraphView(
            store: store.scope(state: \.graph, action: CoinViewAction.graph)
        )
    }

    @ViewBuilder
    func recurringBuys() -> some View {
        RecurringBuyListView(
            buys: viewStore.recurringBuys,
            location: .coin(asset: viewStore.currency.code),
            showsManageButton: .constant(false)
        )
    }

    @ViewBuilder
    func allActionsList() -> some View {
        ActionsView(actions: viewStore.allActions)
            .context([
                blockchain.ux.asset.account.id: viewStore.accounts.first?.id,
                blockchain.coin.core.account.id: viewStore.accounts.first?.id
            ])
    }

    @ViewBuilder
    func accounts() -> some View {
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
                        variant: .superapp,
                        trailing: {
                            Text(viewStore.accounts.fiatBalance?.displayString ?? 6.of(".").joined())
                                .typography(.body2)
                                .foregroundColor(.semantic.title)
                        }
                    )
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
        .background(Color.semantic.light)
    }

    @ViewBuilder
    func bakktLogo() -> some View {
        HStack(
            alignment: .center,
            content: {
                Image("bakkt-logo", bundle: .componentLibrary)
            }
        )
        .frame(maxWidth: .infinity)
    }

    @ViewBuilder
    func news() -> some View {
        NewsSectionView(api: blockchain.api.news.asset, seeAll: false)
            .context([blockchain.api.news.asset.id: viewStore.currency.code])
    }

    @ViewBuilder
    func about() -> some View {
        CoinAboutView(
            currency: viewStore.currency,
            value: viewStore.assetInformation,
            isExpanded: isExpanded,
            toggleIsExpaded: { isExpanded.toggle() }
        )
    }

    @ViewBuilder
    func primaryActions() -> some View {
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
                                context: [
                                    blockchain.ux.asset.account: viewStore.accounts.first,
                                    blockchain.coin.core.account.id: viewStore.accounts.first?.id,
                                    blockchain.ux.transaction.select.source.is.first.in.flow: false
                                ]
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
        content
            .superAppNavigationBar(
                leading: {
                    navigationLeadingView()
                },
                title: {
                    navigationTitleView(currency: viewStore.currency)
                },
                trailing: {
                    dismiss()
                },
                scrollOffset: $scrollOffset.y
            )
            .navigationBarHidden(true)
    }

    @MainActor @ViewBuilder
    func navigationTitleView(currency: CryptoCurrency?) -> some View {
        HStack(spacing: Spacing.textSpacing) {
            currency?.logo()
            Text(currency?.name ?? "")
                .typography(.body2)
                .foregroundColor(.semantic.title)
        }
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
        IconButton(icon: .navigationCloseButton()) {
            viewStore.send(.dismiss)
        }
        .frame(width: 24.pt, height: 24.pt)
    }
}

// swiftlint:disable type_name
struct CoinView_PreviewProvider: PreviewProvider {

    static var previews: some View {

        PrimaryNavigationView {
            CoinView(
                store: Store(
                    initialState: CoinViewState(
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
                    environment: CoinViewEnvironment.preview
                )
            )
            .app(App.preview)
        }
        .previewDevice("iPhone SE (2nd generation)")
        .previewDisplayName("Gold - iPhone SE (2nd generation)")

        PrimaryNavigationView {
            CoinView(
                store: Store(
                    initialState: CoinViewState(
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
                    environment: CoinViewEnvironment.preview
                )
            )
            .app(App.preview)
        }
        .previewDevice("iPhone 13 Pro Max")
        .previewDisplayName("Gold - iPhone 13 Pro Max")

        PrimaryNavigationView {
            CoinView(
                store: Store(
                    initialState: CoinViewState(
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
                    environment: CoinViewEnvironment.preview
                )
            )
            .app(App.preview)
        }
        .previewDisplayName("Not Tradable")

        PrimaryNavigationView {
            CoinView(
                store: Store(
                    initialState: CoinViewState(
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
                    environment: CoinViewEnvironment.preview
                )
            )
            .app(App.preview)
        }
        .previewDisplayName("Unverified")

        PrimaryNavigationView {
            CoinView(
                store: Store(
                    initialState: CoinViewState(
                        currency: .stellar,
                        isFavorite: nil,
                        graph: .init(isFetching: true)
                    ),
                    reducer: coinViewReducer,
                    environment: CoinViewEnvironment.previewEmpty
                )
            )
            .app(App.preview)
        }
        .previewDisplayName("Loading")

        PrimaryNavigationView {
            CoinView(
                store: Store(
                    initialState: CoinViewState(
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
                    environment: CoinViewEnvironment.previewEmpty
                )
            )
            .app(App.preview)
        }
        .previewDisplayName("Error")
    }
}
