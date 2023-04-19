import BlockchainUI
import SwiftUI

@MainActor
public struct SellEntryView: View {

    typealias L10n = LocalizationConstants.SellEntry

    @BlockchainApp var app
    @State private var accounts: [String]?

    public init() {}

    public var body: some View {
        content.primaryNavigation(
            title: L10n.title,
            trailing: { close() }
        )
    }

    func close() -> some View {
        IconButton(
            icon: .closeCirclev3,
            action: { $app.post(event: blockchain.ux.transaction.select.source.article.plain.navigation.bar.button.close.tap) }
        )
        .batch {
            set(blockchain.ux.transaction.select.source.article.plain.navigation.bar.button.close.tap.then.close, to: true)
        }
    }

    var content: some View {
        VStack {
            if let accounts {
                if accounts.isNotEmpty {
                    list(accounts)
                } else {
                    Spacer()
                    mostPopularView
                    Spacer()
                }
            } else {
                Spacer()
                BlockchainProgressView()
                    .transition(.opacity)
                Spacer()
            }
        }
        .frame(maxWidth: .infinity)
        .background(Color.semantic.light.ignoresSafeArea())
        .bindings {
            subscribe($accounts.animation(.easeOut), to: blockchain.coin.core.accounts.custodial.with.balance)
            subscribe($mostPopular, to: blockchain.app.configuration.buy.most.popular.assets)
        }
    }

    @State private var mostPopular: [CurrencyType]?

    @ViewBuilder func list(_ accounts: [String]) -> some View {
        List {
            ForEach(accounts, id: \.self) { account in
                SellEntryRow(id: blockchain.ux.transaction.select.source.asset, account: account)
                    .context(
                        [
                            blockchain.coin.core.account.id: account,
                            blockchain.ux.transaction.select.source.asset.section.list.item.id: account
                        ]
                    )
            }
            .listRowInsets(.zero)
            if mostPopular == nil || mostPopular.isNotNilOrEmpty {
                Section(
                    content: { mostPopularView },
                    header: {
                        sectionHeader(title: L10n.lookingToBuy)
                    }
                )
                .listRowBackground(Color.clear)
                .listRowInsets(.zero)
                .textCase(nil)
            }
        }
        .listStyle(.insetGrouped)
    }

    @ViewBuilder
    func sectionHeader(title: String) -> some View {
        Text(title)
            .typography(.body2)
            .foregroundColor(.semantic.body)
            .padding(.bottom, Spacing.padding1)
    }

    @ViewBuilder var mostPopularView: some View {
        if let mostPopular {
            Carousel(mostPopular, id: \.code, maxVisible: 2.5) { currency in
                MostPopularTile(
                    id: blockchain.ux.transaction.select.source.buy.most.popular.section.list.item,
                    currency: currency
                )
                .context(
                    [blockchain.ux.transaction.select.source.buy.most.popular.section.list.item.id: currency.code]
                )
            }
        }
    }
}

struct SellEntryRow: View {

    @BlockchainApp var app

    let id: L & I_blockchain_ui_type_task
    let account: String

    @State private var balance: MoneyValue?
    @State private var exchangeRate: MoneyValue?

    var currency: CryptoCurrency? {
        balance?.currency.cryptoCurrency
    }

    var price: MoneyValue? {
        guard let balance, let exchangeRate else { return nil }
        return balance.convert(using: exchangeRate)
    }

    var body: some View {
        if #available(iOS 16.0, *) {
            content.alignmentGuide(.listRowSeparatorLeading) { d in d[.leading] }
        } else {
            content
        }
    }

    var content: some View {
        VStack(spacing: 0) {
            if let currency, let balance {
                HStack(spacing: 0) {
                    ZStack(alignment: .bottomTrailing) {
                        AsyncMedia(url: currency.logoURL)
                            .frame(width: 24.pt, height: 24.pt)
                    }
                    Spacer()
                        .frame(width: 16)
                    Text(currency.name)
                        .typography(.paragraph2)
                        .foregroundColor(.semantic.title)
                    Spacer()
                    VStack(alignment: .trailing, spacing: 4.pt) {
                        if let price, price.isPositive {
                            Text(price.toDisplayString(includeSymbol: true))
                                .typography(.paragraph2)
                                .foregroundColor(.semantic.title)
                        } else {
                            Text("..........")
                                .typography(.paragraph2)
                                .redacted(reason: .placeholder)
                        }
                        Text(balance.toDisplayString(includeSymbol: true))
                            .typography(.caption1)
                            .foregroundColor(.semantic.body)
                    }
                }
            }
        }
        .padding(Spacing.padding2)
        .background(Color.semantic.background)
        .onTapGesture {
            $app.post(
                event: id.paragraph.row.tap,
                context: [
                    blockchain.ux.asset.id: currency?.code,
                    blockchain.ux.asset.account.id: account
                ]
            )
        }
        .batch {
            set(id.paragraph.row.tap.then.navigate.to, to: blockchain.ux.transaction["sell"])
        }
        .bindings {
            subscribe($balance, to: blockchain.coin.core.account.balance.available)
        }
        .bindings {
            if let currency {
                subscribe($exchangeRate, to: blockchain.api.nabu.gateway.price.crypto[currency.code].fiat.quote.value)
            }
        }
    }
}

struct MostPopularTile: View {

    @BlockchainApp var app

    let id: L & I_blockchain_ui_type_task
    let currency: CurrencyType

    @State private var price: MoneyValue?

    var body: some View {
        Tile(
            icon: currency.cryptoCurrency?.logoURL,
            title: {
                Text(currency.displayCode)
                    .typography(.paragraph2)
                    .foregroundColor(.semantic.title)
            },
            byline: {
                if let price {
                    Text(price.toDisplayString(includeSymbol: true))
                        .typography(.paragraph1)
                        .foregroundColor(.semantic.title)
                } else {
                    Text(".......")
                        .redacted(reason: .placeholder)
                }
            },
            action: {
                $app.post(
                    event: id.paragraph.card.tap,
                    context: [blockchain.ux.asset.id: currency.code]
                )
            }
        )
        .bindings {
            subscribe($price, to: blockchain.api.nabu.gateway.price.crypto[currency.code].fiat.quote.value)
        }
        .batch {
            set(id.paragraph.card.tap.then.close, to: true)
            set(id.paragraph.card.tap.then.emit, to: blockchain.ux.asset.buy)
        }
    }
}
