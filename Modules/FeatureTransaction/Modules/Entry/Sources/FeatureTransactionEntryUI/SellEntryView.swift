import BlockchainUI
import Coincore
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
                                .listRowSeparatorTint(Color.semantic.light)
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
    @Environment(\.context) var context
    @Environment(\.coincore) var coincore

    @BlockchainApp var app

    let id: L & I_blockchain_ui_type_task
    let account: String

    @State private var balance: MoneyValue?
    @State private var exchangeRate: MoneyValue?
    @State private var networkName: String?

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
                            showNetworkLogo: app.currentMode == .pkw
                        )
                        Spacer()
                            .frame(width: 16)

                        VStack(alignment: .leading, spacing: 4.pt) {
                            Text(currency.name)
                                .typography(.paragraph2)
                                .foregroundColor(.semantic.title)
                                .typography(.paragraph2)
                                .foregroundColor(.semantic.title)

                            if app.currentMode == .pkw {
                                HStack {
                                    Text(currency.code)
                                        .typography(.caption1)
                                        .foregroundColor(.semantic.body)
                                    if let networkName {
                                        TagView(text: networkName, variant: .outline)
                                    }
                                }
                            }
                        }

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
            .navigationBarHidden(false)
            .padding(Spacing.padding2)
            .background(Color.semantic.background)
            .onTapGesture {
                Task {
                    let blockchainAccount = try? await coincore.account(account).await()
                    $app.post(
                        event: id.paragraph.row.tap,
                        context: [
                            blockchain.ux.asset.id: currency?.code,
                            blockchain.ux.asset.account.id: account,
                            blockchain.ux.transaction.source: AnyJSON(blockchainAccount)
                        ]
                    )
                }

            }
            .batch {
                set(id.paragraph.row.tap.then, to: action)
            }
            .bindings {
                subscribe($balance, to: blockchain.coin.core.account.balance.available)
                subscribe($networkName, to: blockchain.coin.core.account.network.name)
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

    var action: AnyJSON {
        // here we decide if the enter amount view is being pushed or current view is being dismissed
        var then: L_blockchain_ui_type_action_then.JSON = .init()
        let isFirstInFlow: Bool? = (context[blockchain.ux.transaction.select.source.is.first.in.flow] as? Bool) ?? true
        switch isFirstInFlow {
        case true:
            then.navigate.to = blockchain.ux.transaction["sell"]
        case false:
            then.emit = blockchain.ux.transaction.action.select.source[]
            then.close = true
        case _:
            break
        }
        return then.toJSON()
    }
}
