// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Blockchain
import BlockchainUI
import FeatureStakingDomain
import SwiftUI

@available(iOS 15, *)
public struct EarnDashboardView: View {

    @BlockchainApp var app
    @Environment(\.context) var context
    @State var selected: Tag = blockchain.ux.earn.portfolio[]
    @State var showIntro: Bool = false
    @State var showCompare: Bool = false
    @StateObject private var object = EarnDashboard.Object()

    public init() {}
    public var body: some View {
            VStack {
                if object.model.isNotNil {
                    LargeSegmentedControl(
                        items: [
                            .init(title: L10n.earning, identifier: blockchain.ux.earn.portfolio[]),
                            .init(title: L10n.discover, identifier: blockchain.ux.earn.discover[])
                        ],
                        selection: $selected.didSet { _ in hideKeyboard() }
                    )
                    .padding([.top, .leading, .trailing])
                    .zIndex(1)
                    .disabled(!object.hasBalance)
                    .transition(.opacity)

    #if os(iOS)
                    TabView(selection: $selected) {
                        content
                    }
                    .tabViewStyle(.page(indexDisplayMode: .never))
                    .transition(.opacity)
                    .ignoresSafeArea()
    #else
                    TabView(selection: $selected) {
                        content
                    }
                    .ignoresSafeArea()
    #endif
                } else {
                    VStack {
                        Spacer()
                        BlockchainProgressView()
                            .transition(.opacity)
                        Spacer()
                    }
                    .frame(maxWidth: .infinity)
                    .background(Color.semantic.light)
                }
            }
            .background(Color.semantic.light.ignoresSafeArea())
            .superAppNavigationBar(
                leading: { [app] in dashboardLeadingItem(app: app) },
                trailing: { [app] in dashboardTrailingItem(app: app) },
                scrollOffset: nil
            )
            .onAppear {
                object.fetch(app: app)
                showIntro = !((try? app.state.get(blockchain.ux.earn.intro.did.show)) ?? false)
            }
            .onChange(of: object.hasBalance) { hasBalance in
                selected = hasBalance ? blockchain.ux.earn.portfolio[] : blockchain.ux.earn.discover[]
            }
            .sheet(isPresented: $showIntro, content: {
                EarnIntroView(
                    store: .init(
                        initialState: .init(products: object.products),
                        reducer: EarnIntro(
                            app: app,
                            onDismiss: {
                                showIntro = false
                            }
                        )
                    )
                )
            })
            .sheet(isPresented: $showCompare, content: {
                EarnProductCompareView(
                    store: .init(
                        initialState: .init(products: object.products),
                        reducer: EarnProductCompare(
                            onDismiss: {
                                showCompare = false
                            }
                        )
                    )
                )
            })
            .post(lifecycleOf: blockchain.ux.earn.article.plain, update: object.model)
            .batch {
                set(blockchain.ux.earn.article.plain.navigation.bar.button.close.tap.then.close, to: true)
            }
    }

    @ViewBuilder var content: some View {
        if object.hasBalance, object.model.isNotNilOrEmpty {
            EarnListView(
                hub: blockchain.ux.earn.portfolio,
                model: object.model,
                selectedTab: $selected,
                totalBalance: object.totalBalance,
                backgroundColor: Color.semantic.light
            ) { id, product, currency, _ in
                EarnPortfolioRow(id: id, product: product, currency: currency)
            }
            .id(blockchain.ux.earn.portfolio[])
            .tag(blockchain.ux.earn.portfolio[])
        }
        EarnListView(
            hub: blockchain.ux.earn.discover,
            model: object.model,
            selectedTab: $selected,
            totalBalance: object.totalBalance,
            backgroundColor: Color.semantic.light,
            header: {
                if object.products.count > 1 {
                    compareCTA {
                        showCompare = true
                    }
                } else if let product = object.products.first {
                    product.learnCardView(Color.semantic.background).context(
                        [blockchain.ux.earn.discover.learn.id: product.value]
                    )
                    .padding(.leading)
                    .frame(maxHeight: 144.pt)
                }
            },
            content: { id, product, currency, eligible in
                EarnDiscoverRow(id: id, product: product, currency: currency, isEligible: eligible)
            }
        )
        .id(blockchain.ux.earn.discover[])
        .tag(blockchain.ux.earn.discover[])
    }
}

@ViewBuilder
func compareCTA(_ action: @escaping () -> Void) -> some View {
    ZStack {
        HStack(alignment: .center, spacing: Spacing.padding2) {
            Icon.coins.color(.semantic.primary).frame(width: 32, height: 32)
            VStack(alignment: .leading, spacing: Spacing.baseline / 2) {
                Text(LocalizationConstants.Earn.Compare.title)
                    .typography(.caption1)
                Text(LocalizationConstants.Earn.Compare.subtitle)
                    .typography(.paragraph2)
            }
            Spacer()
            SmallSecondaryButton(title: LocalizationConstants.Earn.Compare.go) {
                action()
            }
        }
        .padding(Spacing.padding2)
        .background(
            RoundedRectangle(cornerRadius: Spacing.containerBorderRadius)
                .fill(
                    Color.semantic.background
                )
        )
    }
}

// MARK: Common Nav Bar Items

@ViewBuilder
func dashboardLeadingItem(app: AppProtocol) -> some View {
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
func dashboardTrailingItem(app: AppProtocol) -> some View {
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

@MainActor
public struct EarnDashboard: View {

    @BlockchainApp var app
    @Environment(\.context) var context

    @State var selected: Tag = blockchain.ux.earn.portfolio[]
    @State var showIntro: Bool = false
    @State var showCompare: Bool = false

    @StateObject private var object = Object()

    public init() {}

    public var body: some View {
        VStack(spacing: .zero) {
            if object.model.isNotNil {
                LargeSegmentedControl(
                    items: [
                        .init(title: L10n.earning, identifier: blockchain.ux.earn.portfolio[]),
                        .init(title: L10n.discover, identifier: blockchain.ux.earn.discover[])
                    ],
                    selection: $selected.didSet { _ in hideKeyboard() }
                )
                .padding([.leading, .trailing])
                .zIndex(1)
                .disabled(!object.hasBalance)
                .transition(.opacity)

#if os(iOS)
                TabView(selection: $selected) {
                    content
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .transition(.opacity)
#else
                TabView(selection: $selected) {
                    content
                }
#endif
            } else {
                Spacer()
                BlockchainProgressView()
                    .transition(.opacity)
                Spacer()
            }
        }
        .primaryNavigation(
            title: L10n.earn,
            trailing: {
                IconButton(icon: .closev2.circle()) {
                    $app.post(event: blockchain.ux.earn.article.plain.navigation.bar.button.close.tap)
                }
                .frame(width: 24.pt, height: 24.pt)
            }
        )
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.semantic.background)
        .onAppear {
            object.fetch(app: app)
            showIntro = !((try? app.state.get(blockchain.ux.earn.intro.did.show)) ?? false)
        }
        .onChange(of: object.hasBalance) { hasBalance in
            selected = hasBalance ? blockchain.ux.earn.portfolio[] : blockchain.ux.earn.discover[]
        }
        .sheet(isPresented: $showIntro, content: {
            EarnIntroView(
                store: .init(
                    initialState: .init(products: object.products),
                    reducer: EarnIntro(
                        app: app,
                        onDismiss: {
                            showIntro = false
                        }
                    )
                )
            )
        })
        .sheet(isPresented: $showCompare, content: {
            EarnProductCompareView(
                store: .init(
                    initialState: .init(products: object.products),
                    reducer: EarnProductCompare(
                        onDismiss: {
                            showCompare = false
                        }
                    )
                )
            )
        })
        .post(lifecycleOf: blockchain.ux.earn.article.plain, update: object.model)
        .batch {
            set(blockchain.ux.earn.article.plain.navigation.bar.button.close.tap.then.close, to: true)
        }
    }

    @ViewBuilder var content: some View {
        if object.hasBalance, object.model.isNotNilOrEmpty {
            EarnListView(
                hub: blockchain.ux.earn.portfolio,
                model: object.model,
                selectedTab: $selected,
                totalBalance: object.totalBalance
            ) { id, product, currency, _ in
                EarnPortfolioRow(id: id, product: product, currency: currency)
            }
            .id(blockchain.ux.earn.portfolio[])
            .tag(blockchain.ux.earn.portfolio[])
        }
        EarnListView(
            hub: blockchain.ux.earn.discover,
            model: object.model,
            selectedTab: $selected,
            totalBalance: object.totalBalance,
            header: {
                if object.products.count > 1 {
                    compareCTA {
                        showCompare = true
                    }
                } else if let product = object.products.first {
                    product.learnCardView(Color.semantic.light).context(
                        [blockchain.ux.earn.discover.learn.id: product.value]
                    )
                    .padding(.leading)
                    .frame(maxHeight: 144.pt)
                }
            },
            content: { id, product, currency, eligible in
                EarnDiscoverRow(id: id, product: product, currency: currency, isEligible: eligible)
            }
        )
        .id(blockchain.ux.earn.discover[])
        .tag(blockchain.ux.earn.discover[])
    }
}

extension EarnDashboard {

    class Object: ObservableObject {

        @Published var model: [Model]?
        @Published var products: [EarnProduct] = [.savings, .staking]
        @Published var hasBalance: Bool = true
        @Published var totalBalance: MoneyValue?

        func fetch(app: AppProtocol) {

            func model(_ product: EarnProduct, _ asset: CryptoCurrency) -> AnyPublisher<Model?, Never> {
                app.publisher(
                    for: blockchain.user.earn.product[product.value].asset[asset.code].account.balance,
                    as: MoneyValue.self
                )
                .map(\.value)
                .combineLatest(
                    app.publisher(
                        for: blockchain.api.nabu.gateway.price.crypto[asset.code].fiat,
                        as: blockchain.api.nabu.gateway.price.crypto.fiat
                    )
                    .replaceError(with: L_blockchain_api_nabu_gateway_price_crypto_fiat.JSON()),
                    app.publisher(
                        for: blockchain.user.earn.product[product.value].asset[asset.code].is.eligible
                    )
                    .replaceError(with: false),
                    app.publisher(
                        for: blockchain.user.earn.product[product.value].asset[asset.code].rates.rate
                    )
                    .replaceError(with: Double.zero)
                )
                .map { balance, price, isEligible, rate -> Model in
                    let fiat: MoneyValue?
                    do {
                        fiat = try balance?.convert(using: price.quote.value(MoneyValue.self))
                    } catch {
                        fiat = nil
                    }
                    return Model(
                        product: product,
                        asset: asset,
                        marketCap: price.market.cap ?? .zero,
                        isEligible: isEligible,
                        crypto: balance,
                        fiat: fiat,
                        rate: rate
                    )
                }
                .prepend(nil)
                .eraseToAnyPublisher()
            }

            let products = app.publisher(for: blockchain.ux.earn.supported.products, as: OrderedSet<EarnProduct>.self)
                .replaceError(with: [.savings, .staking])
                .removeDuplicates()

            products.flatMap { products -> AnyPublisher<[Model], Never> in
                products.map { product -> AnyPublisher<[Model?], Never> in
                    app.publisher(for: blockchain.user.earn.product[product.value].all.assets, as: [CryptoCurrency].self)
                        .replaceError(with: [])
                        .flatMap { assets -> AnyPublisher<[Model?], Never> in
                            assets.map { asset in model(product, asset) }.combineLatest()
                        }
                        .prepend([])
                        .eraseToAnyPublisher()
                }
                .combineLatest()
                .map { products -> [Model] in products.joined().compacted().array }
                .eraseToAnyPublisher()
            }
             .receive(on: DispatchQueue.main.animation())
            .assign(to: &$model)

            func balance(_ product: EarnProduct, _ asset: CryptoCurrency) -> AnyPublisher<MoneyValue, Never> {
                let quotePublisher = app
                    .publisher(for: blockchain.api.nabu.gateway.price.crypto[asset.code].fiat.quote.value, as: MoneyValue.self)
                    .compactMap(\.value)

                let balancePublisher = app
                    .publisher(
                        for: blockchain.user.earn.product[product.value].asset[asset.code].account.balance,
                        as: MoneyValue.self
                    )
                    .compactMap(\.value)

                return balancePublisher.combineLatest(quotePublisher)
                        .map { balance, quote -> MoneyValue in
                            balance.convert(using: quote)
                        }
                        .replaceError(with: .zero(currency: .USD))
                        .eraseToAnyPublisher()
            }

            func hasBalance(_ product: EarnProduct, _ asset: CryptoCurrency) -> AnyPublisher<Bool, Never> {
                balance(product, asset)
                    .combineLatest(
                        app.publisher(for: blockchain.ux.user.account.preferences.small.balances.are.hidden, as: Bool.self)
                            .replaceError(with: false)
                    )
                    .map { balance, isHidden -> Bool in
                        if isHidden {
                            return balance.isDust == false
                        } else {
                            return balance.isPositive
                        }
                    }
                    .eraseToAnyPublisher()
            }

            func totalBalance(for product: EarnProduct) -> AnyPublisher<MoneyValue?, Never> {
                app.publisher(for: blockchain.user.earn.product[product.value].all.assets, as: [CryptoCurrency].self)
                    .replaceError(with: [])
                    .flatMap { assets -> AnyPublisher<MoneyValue?, Never> in
                        assets
                            .map { asset in
                                balance(product, asset).optional().prepend(nil)
                            }
                            .combineLatest()
                            .map { balances -> MoneyValue? in
                                balances.compactMap { $0 }.sum()
                            }
                            .eraseToAnyPublisher()
                    }
                    .prepend(nil)
                    .eraseToAnyPublisher()
            }

            products.flatMap { products -> AnyPublisher<Bool, Never> in
                products.map { product in
                    app.publisher(for: blockchain.user.earn.product[product.value].all.assets, as: [CryptoCurrency].self)
                        .replaceError(with: [])
                        .flatMap { assets -> AnyPublisher<Bool, Never> in
                            assets.map { asset -> AnyPublisher<Bool, Never> in hasBalance(product, asset) }
                                .combineLatest()
                                .map { balances in balances.contains(true) }
                                .eraseToAnyPublisher()
                        }
                        .eraseToAnyPublisher()
                }
                .combineLatest()
                .map { balances in balances.contains(true) }
                .eraseToAnyPublisher()
            }
            .receive(on: DispatchQueue.main.animation())
            .assign(to: &$hasBalance)

            products
                .flatMap { products -> AnyPublisher<MoneyValue?, Never> in
                    products
                        .map { product in totalBalance(for: product) }
                        .combineLatest()
                        .map { balances -> MoneyValue? in
                            balances.compactMap { $0 }.sum()
                        }
                        .eraseToAnyPublisher()
                }
                .receive(on: DispatchQueue.main.animation())
                .assign(to: &$totalBalance)

            products.map(\.array)
                .receive(on: DispatchQueue.main.animation())
                .assign(to: &$products)

            app.post(event: blockchain.ux.earn.did.appear)
        }
    }
}
