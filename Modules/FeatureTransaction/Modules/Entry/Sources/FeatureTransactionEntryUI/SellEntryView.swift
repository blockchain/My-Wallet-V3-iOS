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
            if let accounts, accounts.isNotEmpty {
                list(accounts)
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
            subscribe($accounts.animation(.easeOut), to: blockchain.coin.core.accounts.custodial.crypto.with.balance)
        }
    }

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

    @ViewBuilder
    var content: some View {
        if balance == nil || currency != nil {
            VStack(spacing: 0) {
                if let currency {
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
                            Group {
                                if let price, price.isPositive {
                                    Text(price.toDisplayString(includeSymbol: true))
                                } else {
                                    Text("..........").redacted(reason: .placeholder)
                                }
                            }
                            .typography(.paragraph2)
                            .foregroundColor(.semantic.title)
                            Group {
                                if let balance {
                                    Text(balance.toDisplayString(includeSymbol: true))
                                } else {
                                    Text("..........").redacted(reason: .placeholder)
                                }
                            }
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
        } else {
            Text(account)
                .foregroundColor(.semantic.error)
                .typography(.caption1)
        }
    }
}
