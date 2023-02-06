// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Blockchain
import BlockchainUI
import FeatureDashboardDomain
import FeatureProductsDomain
import FeatureStakingDomain
import Foundation
import Localization
import SwiftUI

private typealias L10n = LocalizationConstants.EarnDashboard

public struct DashboardEarnSectionView: View {

    @BlockchainApp var app
    @Environment(\.context) var context

    @StateObject var model = EarnDashboardSectionModel()

    // regardless of product availability, aka earnAvailable,
    // check if earnModels is not empty.
    var sectionIsVisible: Bool {
        model.earnAvailable || model.earnModels.isNotEmpty
    }

    public init() {}

    public var body: some View {
        VStack {
            if sectionIsVisible {
                headerSection
                if model.earnModels.isEmpty {
                    EarnDashboardEmptyView()
                } else {
                    VStack(spacing: 0) {
                        ForEach(model.earnModels) { item in
                            EarnDashboardRowView(id: blockchain.ux.earn.portfolio.product.asset, model: item)
                                .context(
                                    [
                                        blockchain.user.earn.product.id: item.product.value,
                                        blockchain.user.earn.product.asset.id: item.asset.code,
                                        blockchain.ux.earn.portfolio.product.id: item.product.value,
                                        blockchain.ux.earn.portfolio.product.asset.id: item.asset.code
                                    ]
                                )
                            if model.earnModels.last != item {
                                Divider()
                                    .foregroundColor(.semantic.light)
                            }
                        }
                    }
                    .redacted(reason: model.earnModels == EarnDashboardSectionModel.earnModelsPlaceholders ? .placeholder : [])
                    .cornerRadius(Spacing.padding2, corners: .allCorners)
                }
            } else {
                Spacer().frame(height: 0)
            }
        }
        .opacity(sectionIsVisible ? 1.0 : 0.0)
        .onAppear {
            model.prepare(app: app)
        }
        .padding(.horizontal, Spacing.padding2)
        .batch(
            .set(blockchain.ux.earn.entry.paragraph.button.secondary.tap.then.enter.into, to: blockchain.ux.earn)
        )
    }

    @ViewBuilder
    var headerSection: some View {
        HStack {
            Text(L10n.sectionTitle)
                .typography(.body2)
                .foregroundColor(.semantic.body)
            Spacer()
            Button {
                app.post(
                    event: blockchain.ux.earn.entry.paragraph.button.secondary.tap,
                    context: [blockchain.ui.type.action.then.enter.into.embed.in.navigation: true]
                )
            } label: {
                Text(L10n.manageButtonTitle)
                    .typography(.paragraph2)
                    .foregroundColor(.semantic.primary)
            }
            .opacity(model.earnModels.isEmpty ? 0.0 : 1.0)
            .disabled(model.earnModels.isEmpty)
        }
    }
}

struct EarnDashboardRowView: View {
    @BlockchainApp var app
    @Environment(\.context) var context

    let id: L & I_blockchain_ux_earn_type_hub_product_asset

    let model: EarnSectionRowModel
    private let product: EarnProduct
    private let currency: CryptoCurrency

    init(id: L & I_blockchain_ux_earn_type_hub_product_asset, model: EarnSectionRowModel) {
        self.id = id
        self.model = model
        self.product = model.product
        self.currency = model.asset
    }

    @State var balance: MoneyValue?
    @State var exchangeRate: MoneyValue?

    var body: some View {
        HStack(spacing: Spacing.padding2) {
            AsyncMedia(url: model.asset.logoURL)
                .frame(width: 24.pt)
            VStack(alignment: .leading, spacing: Spacing.textSpacing) {
                Text(model.asset.name)
                    .typography(.paragraph2)
                    .foregroundColor(.semantic.title)
                TagView(text: L10n.rewards.interpolating(model.product.title))
            }
            Spacer()
            VStack(alignment: .trailing, spacing: Spacing.textSpacing) {
                if let balance {
                    if let exchangeRate {
                        Text(balance.convert(using: exchangeRate).displayString)
                            .typography(.paragraph2)
                            .foregroundColor(.semantic.title)
                    }
                    Text(model.rateTitle)
                        .typography(.caption1)
                        .foregroundColor(.semantic.body)
                } else {
                    ProgressView()
                }
            }
        }
        .binding(
            .subscribe($exchangeRate, to: blockchain.api.nabu.gateway.price.crypto[model.asset.code].fiat.quote.value),
            .subscribe($balance, to: blockchain.user.earn.product[model.product.value].asset[model.asset.code].account.balance)
        )
        .batch(
            .set(id.paragraph.row.tap.then.enter.into, to: $app[blockchain.ux.earn.portfolio.product.asset.summary])
        )
        .padding(Spacing.padding2)
        .background(Color.white)
        .onTapGesture {
            $app.post(event: id.paragraph.row.tap)
        }
    }
}

// MARK: - Empty State

struct EarnDashboardEmptyView: View {
    @BlockchainApp var app

    var body: some View {
        HStack(spacing: Spacing.padding2) {
            Icon.interestCircle.medium().color(.semantic.medium)
            VStack(alignment: .leading, spacing: Spacing.textSpacing) {
                Text(L10n.EmptyState.title)
                    .typography(.caption1)
                    .foregroundColor(.semantic.title)
                Text(L10n.EmptyState.subtitle)
                    .typography(.paragraph2)
                    .foregroundColor(.semantic.title)
            }
            Spacer()
            SmallSecondaryButton(
                title: L10n.EmptyState.earnButtonTitle,
                action: {
                    app.post(
                        event: blockchain.ux.earn.entry.paragraph.button.secondary.tap,
                        context: [blockchain.ui.type.action.then.enter.into.embed.in.navigation: false]
                    )
                }
            )
        }
        .padding(Spacing.padding2)
        .background(Color.white)
        .cornerRadius(Spacing.padding2, corners: .allCorners)
    }
}

// MARK: - View Model

struct EarnSectionRowModel: Equatable, Identifiable {
    var id: AnyHashable {
        "\(product.value)_\(asset.code)"
    }

    let product: EarnProduct
    let asset: CryptoCurrency
    let balance: MoneyValue?
    let fiat: MoneyValue?
    let rate: Double

    var rateTitle: String {
        if #available(iOS 15.0, *) {
            return "\(rate.formatted(.percent)) \(L10n.rateAPY)"
        }
        return percentageFormatter.string(from: NSNumber(value: rate)) ?? ""
    }
}

final class EarnDashboardSectionModel: ObservableObject {

    @Published var earnModels: [EarnSectionRowModel] = earnModelsPlaceholders
    @Published var earnAvailable: Bool = false

    static var earnModelsPlaceholders = [
        EarnSectionRowModel(
            product: .savings,
            asset: .bitcoin,
            balance: .zero(currency: .bitcoin),
            fiat: .zero(currency: .USD),
            rate: 10
        ),
        EarnSectionRowModel(
            product: .staking,
            asset: .bitcoin,
            balance: .zero(currency: .bitcoin),
            fiat: .zero(currency: .USD),
            rate: 10
        )
    ]

    func prepare(app: AppProtocol) {

        func model(_ product: EarnProduct, _ asset: CryptoCurrency) -> AnyPublisher<EarnSectionRowModel, Never> {
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
                    for: blockchain.user.earn.product[product.value].asset[asset.code].rates.rate
                )
                .replaceError(with: Double.zero)
            )
            .map { balance, price, rate -> EarnSectionRowModel in
                EarnSectionRowModel(
                    product: product,
                    asset: asset,
                    balance: balance,
                    fiat: (try? price.quote.value(MoneyValue.self)).flatMap { balance?.convert(using: $0) },
                    rate: rate
                )
            }
            .eraseToAnyPublisher()
        }

        let earnCC1WEligible = app.publisher(
            for: blockchain.api.nabu.gateway.products[ProductIdentifier.depositEarnCC1W].is.eligible,
            as: Bool.self
        )
        .replaceError(with: false)
        .eraseToAnyPublisher()

        let earnInterestEligible = app.publisher(
            for: blockchain.api.nabu.gateway.products[ProductIdentifier.depositInterest].is.eligible,
            as: Bool.self
        )
        .replaceError(with: false)
        .eraseToAnyPublisher()

        let earnStakingEligible = app.publisher(
            for: blockchain.api.nabu.gateway.products[ProductIdentifier.depositStaking].is.eligible,
            as: Bool.self
        )
        .replaceError(with: false)
        .eraseToAnyPublisher()

        Publishers.Zip3(earnInterestEligible, earnStakingEligible, earnCC1WEligible)
            .map { $0.0 || $0.1 || $0.2 }
            .eraseToAnyPublisher()
            .receive(on: DispatchQueue.main)
            .assign(to: &$earnAvailable)

        let products = app.publisher(for: blockchain.ux.earn.supported.products, as: OrderedSet<EarnProduct>.self)
            .replaceError(with: [.savings, .staking])
            .removeDuplicates()

        let allEarnAssets = products.flatMap { products -> AnyPublisher<[EarnSectionRowModel], Never> in
            products.map { product -> AnyPublisher<[EarnSectionRowModel], Never> in
                app.publisher(for: blockchain.user.earn.product[product.value].all.assets, as: [CryptoCurrency].self)
                    .replaceError(with: [])
                    .flatMap { assets -> AnyPublisher<[EarnSectionRowModel], Never> in
                        assets.map { asset in model(product, asset) }.combineLatest()
                    }
                    .eraseToAnyPublisher()
            }
            .combineLatest()
            .map { products -> [EarnSectionRowModel] in products.joined().array }
            .eraseToAnyPublisher()
        }

        allEarnAssets
            .combineLatest(app.publisher(for: blockchain.ux.user.account.preferences.small.balances.are.hidden, as: Bool.self).replaceError(with: false))
            .map { products, isHidden -> [EarnSectionRowModel] in
                products
                    .filter { item -> Bool in
                        guard let balance = item.fiat else { return false }
                        if isHidden, balance.isDust { return false }
                        return balance.isPositive
                    }
                    .sorted { lhs, rhs in
                        lhs.asset.name < rhs.asset.name
                    }
            }
            .map { products -> [EarnSectionRowModel] in
                products.sorted { lhs, rhs in
                    guard let lhs = lhs.fiat, let rhs = rhs.fiat else { return false }
                    return (try? lhs > rhs) ?? false
                }
            }
            .map { products -> [EarnSectionRowModel] in
                let upTo = min(8, products.count)
                return Array(products[..<upTo])
            }
            .receive(on: DispatchQueue.main)
            .assign(to: &$earnModels)
    }
}

let percentageFormatter: NumberFormatter = with(NumberFormatter()) { formatter in
    formatter.numberStyle = .percent
    formatter.maximumFractionDigits = 2
}
