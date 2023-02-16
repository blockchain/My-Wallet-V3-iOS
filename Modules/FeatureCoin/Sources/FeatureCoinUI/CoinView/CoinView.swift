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

    public init(store: Store<CoinViewState, CoinViewAction>) {
        self.store = store
        _viewStore = .init(initialValue: ViewStore(store))
    }

    typealias Localization = LocalizationConstants.Coin

    public var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ScrollView {
                header()
                accounts()
                if viewStore.shouldShowRecurringBuy {
                    recurringBuys()
                }
                about()
                Color.clear
                    .frame(height: Spacing.padding2)
            }
            if viewStore.accounts.isNotEmpty, viewStore.actions.isNotEmpty {
                actions()
            }
        }
        .primaryNavigation(
            leading: navigationLeadingView,
            title: viewStore.currency.name,
            trailing: {
                dismiss()
            }
        )
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onAppear { viewStore.send(.onAppear) }
        .onDisappear { viewStore.send(.onDisappear) }
        .sheet(
            item: viewStore.binding(\.$recurringBuy),
            onDismiss: {
                viewStore.send(.set(\.$recurringBuy, nil))
            },
            content: { RecurringBuySummaryView(buy: $0) }
        )
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
                        blockchain.ux.asset.account: account
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

    @ViewBuilder func totalBalance() -> some View {
        TotalBalanceView(
            currency: viewStore.currency,
            accounts: viewStore.accounts,
            trailing: {
                WithViewStore(store) { viewStore in
                    if let isFavorite = viewStore.isFavorite {
                        if isFavorite {
                            IconButton(icon: .favorite) {
                                viewStore.send(.removeFromWatchlist)
                            }
                        } else {
                            IconButton(icon: .favoriteEmpty) {
                                viewStore.send(.addToWatchlist)
                            }
                        }
                    } else {
                        ProgressView()
                            .progressViewStyle(.circular)
                            .frame(width: 28, height: 28)
                    }
                }
            }
        )
    }

    @ViewBuilder func recurringBuys() -> some View {
        RecurringBuyListView(buys: viewStore.recurringBuys)
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
                totalBalance()
                if let status = viewStore.kycStatus {
                    if viewStore.shouldShowRecurringBuy {
                        SectionHeader(title: Localization.Header.walletsAndAccounts)
                            .padding([.top], 8.pt)
                    }
                    AccountListView(
                        accounts: viewStore.accounts,
                        currency: viewStore.currency,
                        earnRates: viewStore.earnRates,
                        kycStatus: status
                    )

                    if let swapAction = viewStore.swapButton {
                        PrimaryButton(title: swapAction.title) {
                            swapAction
                                .icon
                                .color(.white)
                        } action: {
                            app.post(event: swapAction.event[].ref(to: context), context: context)
                        }
                        .disabled(swapAction.disabled)
                        .padding(.top, Spacing.padding2)
                        .padding(.horizontal, Spacing.padding2)
                    }
                }
            } else {
                totalBalance()
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
    }

    @State private var isExpanded: Bool = false

    @ViewBuilder func about() -> some View {
        if viewStore.assetInformation?.description.nilIfEmpty == nil, viewStore.assetInformation?.website == nil {
            EmptyView()
        } else {
            HStack {
                VStack(alignment: .leading, spacing: Spacing.padding1) {
                    Text(
                        Localization.Label.Title.aboutCrypto
                            .interpolating(viewStore.currency.name)
                    )
                    .foregroundColor(.semantic.title)
                    .typography(.body2)
                    if let about = viewStore.assetInformation?.description {
                        Text(rich: about)
                            .lineLimit(isExpanded ? nil : 6)
                            .typography(.paragraph1)
                            .foregroundColor(.semantic.title)
                        if !isExpanded {
                            Button(
                                action: {
                                    withAnimation {
                                        isExpanded.toggle()
                                    }
                                },
                                label: {
                                    Text(Localization.Button.Title.readMore)
                                        .typography(.paragraph1)
                                        .foregroundColor(.semantic.primary)
                                }
                            )
                        }
                    }
                    if let url = viewStore.assetInformation?.website {
                        Spacer()
                        SmallMinimalButton(title: Localization.Link.Title.visitWebsite) {
                            app.post(
                                event: blockchain.ux.asset.bio.visit.website[].ref(to: context),
                                context: [blockchain.ux.asset.bio.visit.website.url[]: url]
                            )
                        }
                    }
                }
                .padding(Spacing.padding3)
            }
        }
    }

    @ViewBuilder func navigationLeadingView() -> some View {
        if let url = viewStore.currency.assetModel.logoPngUrl {
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
    }

    @ViewBuilder func dismiss() -> some View {
        IconButton(icon: .closev2.circle()) {
            viewStore.send(.dismiss)
        }
        .frame(width: 24.pt, height: 24.pt)
    }

    @ViewBuilder func actions() -> some View {
        VStack(spacing: 0) {
            PrimaryDivider()
            HStack(spacing: 8.pt) {
                ForEach(viewStore.actions, id: \.event) { action in
                    SecondaryButton(
                        title: action.title,
                        leadingView: { action.icon.color(.white)
                                .frame(width: 14, height: 14)
                        },
                        action: {
                            app.post(event: action.event[].ref(to: context), context: context)
                        }
                    )
                    .disabled(action.disabled)
                }
            }
            .padding(.horizontal, Spacing.padding2)
            .padding(.top)
        }
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
                        currency: .ethereum,
                        kycStatus: .silver,
                        accounts: [
                            .preview.privateKey,
                            .preview.trading,
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
        .previewDisplayName("Silver")

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
