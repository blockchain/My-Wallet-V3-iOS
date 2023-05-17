import BlockchainUI
import SwiftUI

@MainActor
public struct SellEntryView: View {

    typealias L10n = LocalizationConstants.SellEntry

    @BlockchainApp var app

    @State private var accounts: [String]?
    @State private var isAllowedToSell = [String: Bool]()

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

    var isEmpty: Bool {
        guard let accounts else { return false }
        return accounts.allSatisfy({ account in isAllowedToSell[account] == false })
    }

    var content: some View {
        VStack {
            if let accounts, accounts.isNotEmpty {
                if isEmpty {
                    emptyView().transition(.opacity)
                } else {
                    list(accounts).transition(.opacity)
                }
            } else {
                loadingView()
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.semantic.light.ignoresSafeArea())
        .bindings {
            switch app.currentMode {
            case .pkw:
                subscribe($accounts.animation(.easeOut), to: blockchain.coin.core.accounts.DeFi.with.balance)
            default:
                subscribe($accounts.animation(.easeOut), to: blockchain.coin.core.accounts.custodial.crypto.with.balance)
            }
        }
    }

    @ViewBuilder func list(_ accounts: [String]) -> some View {
        List {
            Section(
                header: sectionHeader(title: L10n.availableToSell),
                content: {
                    ForEach(accounts, id: \.self) { account in
                        if isAllowedToSell[account] == nil || isAllowedToSell[account] == true {
                            SellEntryRow(id: blockchain.ux.transaction.select.source.asset, account: account)
                                .listRowSeparatorColor(Color.semantic.light)
                                .context(
                                    [
                                        blockchain.coin.core.account.id: account,
                                        blockchain.ux.transaction.select.source.asset.section.list.item.id: account
                                    ]
                                )
                                .disabled(isAllowedToSell[account] == nil)
                                .redacted(reason: isAllowedToSell[account] == nil ? .placeholder : [])
                                .bindings {
                                    subscribe($isAllowedToSell[account], to: blockchain.coin.core.account[account].can.perform.sell)
                                }
                        }
                    }
                }
            )
            .listRowInsets(.zero)
        }
        .hideScrollContentBackground()
        .listStyle(.insetGrouped)
    }

    @ViewBuilder
    func sectionHeader(title: String) -> some View {
        Text(title)
            .typography(.body2)
            .foregroundColor(.semantic.body)
            .padding(.bottom, Spacing.padding1)
            .textCase(nil)
    }

    @ViewBuilder
    func emptyView() -> some View {
        ZStack {
            VStack(spacing: Spacing.padding2) {
                ZStack {
                    Circle()
                        .fill(Color.semantic.background)
                        .frame(width: 88.pt, height: 88.pt)
                    Icon.coins.color(.semantic.title)
                        .frame(width: 58.pt, height: 58.pt)
                }
                .overlay(
                    Icon.alert.color(.semantic.muted).circle(backgroundColor: Color.semantic.light)
                        .frame(width: 36.pt, height: 36.pt),
                    alignment: .bottomTrailing
                )
                Text(L10n.emptyTitle)
                    .typography(.title3)
                    .foregroundColor(.semantic.title)
                Text(L10n.emptyMessage)
                    .typography(.body1)
                    .foregroundColor(.semantic.body)
            }
            .multilineTextAlignment(.center)
        }
        .padding()
    }

    @ViewBuilder func loadingView() -> some View {
        Spacer()
        BlockchainProgressView()
            .transition(.opacity)
        Spacer()
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
                        currency.logo(
                            size: 24.pt,
                            showNetworkLogo: true
                        )
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
