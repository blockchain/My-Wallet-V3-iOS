// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Blockchain
import BlockchainUI
import FeatureStakingDomain
import SwiftUI

public struct EarnDashboardView: View {

    @BlockchainApp var app
    @Environment(\.context) var context
    @State var selected: Tag = blockchain.ux.earn.discover[]
    @State var showIntro: Bool = false
    @State var showCompare: Bool = false
    @StateObject private var object = Object()

    @State private var scrollOffset: CGPoint = .zero
    @State private var displayDisclaimer: Bool = false
    @State private var disclaimerHeight: CGFloat = 0

    public init() {}
    public var body: some View {
        ZStack(alignment: .top) {
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
            .padding(.top, displayDisclaimer ? max(disclaimerHeight, 60).pt : 0.pt)
            if object.model.isNotNil {
                FinancialPromotionDisclaimerView(display: $displayDisclaimer)
                    .padding()
                    .background(
                        GeometryReader { proxy in
                            RoundedRectangle(cornerRadius: Spacing.padding1)
                                .fill(Color.semantic.background)
                                .shadow(color: .semantic.dark.opacity(0.5), radius: shadowRadius(forScrollOffset: scrollOffset.y))
                                .padding(.init(top: 8, leading: 8, bottom: 8, trailing: 8))
                                .onChange(of: proxy.size) { _ in
                                    disclaimerHeight = proxy.size.height
                                }
                        }
                    )
                    .mask(RoundedRectangle(cornerRadius: shadowRadius(forScrollOffset: scrollOffset.y)).padding(.bottom, -20))
                    .padding([.bottom], 8.pt)
            }
        }
        .background(Color.semantic.light.ignoresSafeArea())
        .superAppNavigationBar(
            leading: { [app] in dashboardLeadingItem(app: app) },
            trailing: { [app] in dashboardTrailingItem(app: app) },
            scrollOffset: $scrollOffset.y
        )
        .onAppear {
            object.fetch(app: app)
            showIntro = !((try? app.state.get(blockchain.ux.earn.intro.did.show)) ?? false)
        }
        .onChange(of: object.totalBalance) { balance in
            selected = (balance?.isPositive ?? false) ? blockchain.ux.earn.portfolio[] : blockchain.ux.earn.discover[]
        }
        .sheet(isPresented: $showIntro, content: {
            EarnIntroView(
                store: Store(
                    initialState: .init(products: object.products),
                    reducer: {
                        EarnIntro(
                            app: app,
                            onDismiss: {
                                showIntro = false
                            }
                        )
                    }
                )
            )
        })
        .sheet(isPresented: $showCompare, content: {
            EarnProductCompareView(
                store: Store(
                    initialState: EarnProductCompare.State(
                        products: object.products,
                        model: object.model
                    ),
                    reducer: {
                        EarnProductCompare(
                            onDismiss: {
                                showCompare = false
                            }
                        )
                    }
                )
            )
        })
        .post(lifecycleOf: blockchain.ux.earn.article.plain, update: object.model)
        .batch {
            set(blockchain.ux.earn.article.plain.navigation.bar.button.close.tap.then.close, to: true)
        }
    }

    @ViewBuilder var content: some View {
        if object.totalBalance?.isPositive ?? false, object.model.isNotNilOrEmpty {
            EarnListView(
                hub: blockchain.ux.earn.portfolio,
                model: object.model,
                selectedTab: $selected,
                totalBalance: object.totalBalance,
                backgroundColor: Color.semantic.light
            ) { id, product, currency, _, _ in
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
            content: { id, product, currency, eligible, verified in
                EarnDiscoverRow(id: id, product: product, currency: currency, isEligible: eligible, isVerified: verified)
            }
        )
        .id(blockchain.ux.earn.discover[])
        .tag(blockchain.ux.earn.discover[])
    }

    func shadowRadius(forScrollOffset offset: CGFloat) -> CGFloat {
        let lowerBound: CGFloat = 30
        let upperBound: CGFloat = 70
        if offset < lowerBound {
            return 0
        } else if offset > upperBound {
            return 8
        } else {
            return ((offset - lowerBound) / (upperBound - lowerBound)) * 8
        }
    }
}

@ViewBuilder
func compareCTA(_ action: @escaping () -> Void) -> some View {
    ZStack {
        HStack(alignment: .center, spacing: Spacing.padding2) {
            Icon.coins.color(.semantic.primary).frame(width: 32, height: 32)
            VStack(alignment: .leading, spacing: Spacing.baseline / 2) {
                Text(Localization.Earn.Compare.title)
                    .typography(.caption1)
                Text(Localization.Earn.Compare.subtitle)
                    .typography(.paragraph2)
            }
            Spacer()
            SmallSecondaryButton(title: Localization.Earn.Compare.go) {
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

extension EarnDashboardView {

    class Object: ObservableObject {

        @Published var model: [Model]?
        @Published var products: [EarnProduct] = [.savings, .staking]
        @Published var totalBalance: MoneyValue?

        func fetch(app: AppProtocol) {

            func model(_ product: EarnProduct, _ asset: CryptoCurrency) -> AnyPublisher<Model?, Never> {
                let publishers = Publishers.CombineLatest4(
                    app.publisher(
                        for: blockchain.api.nabu.gateway.price.crypto[asset.code].fiat,
                        as: blockchain.api.nabu.gateway.price.crypto.fiat
                    )
                    .replaceError(with: L_blockchain_api_nabu_gateway_price_crypto_fiat.JSON()),
                    app.publisher(
                        for: blockchain.user.account.kyc[blockchain.user.account.tier.gold].state,
                        as: Tag.self
                    )
                    .replaceError(with: blockchain.user.account.kyc.state.none[]),
                    app.publisher(
                        for: blockchain.user.earn.product[product.value].asset[asset.code].is.eligible
                    )
                    .replaceError(with: false),
                    app.publisher(
                        for: blockchain.user.earn.product[product.value].asset[asset.code].rates.rate
                    )
                    .replaceError(with: Double.zero)
                )

                return app.publisher(
                    for: blockchain.user.earn.product[product.value].asset[asset.code].account.balance,
                    as: MoneyValue.self
                )
                .map(\.value)
                .combineLatest(publishers)
                .map { balance, values -> Model in
                    let (price, kycStatus, isEligible, rate) = values
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
                        rate: rate,
                        isVerified: kycStatus == blockchain.user.account.kyc.state.verified[]
                    )
                }
                .prepend(nil)
                .eraseToAnyPublisher()
            }

            let products: AnyPublisher<OrderedSet<EarnProduct>, Never> = app.publisher(
                for: blockchain.ux.earn.supported.products,
                as: [EarnProduct].self
            )
                .replaceError(with: [.savings, .staking])
                .map { products in
                    OrderedSet<EarnProduct>(products)
                }
                .removeDuplicates()
                .share()
                .eraseToAnyPublisher()

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
