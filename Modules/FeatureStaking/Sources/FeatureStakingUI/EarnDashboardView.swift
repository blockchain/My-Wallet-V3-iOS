// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Blockchain
import BlockchainUI
import FeatureStakingDomain
import SwiftUI

@MainActor
public struct EarnDashboard: View {

    @BlockchainApp var app
    @Environment(\.context) var context

    @State var selected: Tag = blockchain.ux.earn.portfolio[]

    @StateObject private var object = Object()

    public init() { }

    public var body: some View {
        VStack {
            if object.hasBalance {
                LargeSegmentedControl(
                    items: [
                        .init(title: L10n.earning, identifier: blockchain.ux.earn.portfolio[]),
                        .init(title: L10n.discover, identifier: blockchain.ux.earn.discover[])
                    ],
                    selection: $selected.didSet { _ in hideKeyboard() }
                )
                .padding([.leading, .trailing])
                .zIndex(1)
            }
#if os(iOS)
            TabView(selection: $selected) {
                content
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
#else
            TabView(selection: $selected) {
                content
            }
#endif
        }
        .padding(.top)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.semantic.background)
        .onAppear {
            object.fetch(app: app)
        }
        .onChange(of: object.hasBalance) { hasBalance in
            selected = hasBalance ? blockchain.ux.earn.portfolio[] : blockchain.ux.earn.discover[]
        }
        .post(lifecycleOf: blockchain.ux.earn.article.plain, update: object.model)
    }

    @ViewBuilder var content: some View {
        if object.hasBalance {
            EarnListView(hub: blockchain.ux.earn.portfolio, model: object.model) { id, product, currency, _ in
                EarnPortfolioRow(id: id, product: product, currency: currency)
            }
            .id(blockchain.ux.earn.portfolio[])
        }
        EarnListView(
            hub: blockchain.ux.earn.discover,
            model: object.model,
            header: {
                Carousel(object.products, id: \.self, maxVisible: 1.8) { product in
                    product.learnCardView.context(
                        [blockchain.ux.earn.discover.learn.id: product.value]
                    )
                }
            },
            content: { id, product, currency, eligible in
                EarnDiscoverRow(id: id, product: product, currency: currency, isEligible: eligible)
            }
        )
        .tag(blockchain.ux.earn.discover[])
    }
}

extension EarnDashboard {

    class Object: ObservableObject {

        @Published var model: [Model]?
        @Published var products: [EarnProduct] = [.savings, .staking]
        @Published var hasBalance: Bool = true

        func fetch(app: AppProtocol) {

            func model(_ product: EarnProduct, _ asset: CryptoCurrency) -> AnyPublisher<Model, Never> {
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
                    .compactMap(\.value),
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
                    Model(
                        product: product,
                        asset: asset,
                        marketCap: price.market.cap ?? .zero,
                        isEligible: isEligible,
                        crypto: balance,
                        fiat: (try? price.quote.value(MoneyValue.self)).flatMap { balance?.convert(using: $0) },
                        rate: rate
                    )
                }
                .eraseToAnyPublisher()
            }

            let products = app.publisher(for: blockchain.ux.earn.supported.products, as: OrderedSet<EarnProduct>.self)
                .replaceError(with: [.savings, .staking])
                .removeDuplicates()

            products.flatMap { products -> AnyPublisher<[Model], Never> in
                products.map { product -> AnyPublisher<[Model], Never> in
                    app.publisher(for: blockchain.user.earn.product[product.value].all.assets, as: [CryptoCurrency].self)
                        .replaceError(with: [])
                        .flatMap { assets -> AnyPublisher<[Model], Never> in
                            assets.map { asset in model(product, asset) }.combineLatest()
                        }
                        .eraseToAnyPublisher()
                }
                .combineLatest()
                .map { products -> [Model] in products.joined().array }
                .eraseToAnyPublisher()
            }
            .receive(on: DispatchQueue.main)
            .assign(to: &$model)

            products.flatMap { products -> AnyPublisher<Bool, Never> in
                products.map { product in
                    app.publisher(for: blockchain.user.earn.product[product.value].has.balance, as: Bool.self).replaceError(with: false)
                }
                .combineLatest()
                .map { balances in balances.contains(true) }
                .eraseToAnyPublisher()
            }
            .receive(on: DispatchQueue.main)
            .assign(to: &$hasBalance)

            products.map(\.array)
                .receive(on: DispatchQueue.main)
                .assign(to: &$products)
        }
    }
}
