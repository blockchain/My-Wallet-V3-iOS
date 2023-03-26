import BlockchainNamespace
import BlockchainUI
import DIKit
import FeatureTopMoversCryptoUI
import SwiftUI

typealias L10n = LocalizationConstants.BuyEntry

@MainActor
public struct BuyEntryView: View {

    @BlockchainApp var app
    @State private var pairs: [CurrencyPair] = []
    @State private var search: String = ""
    @State private var isSearching: Bool = false

    let store: StoreOf<BuyEntry>

    public init(store: StoreOf<BuyEntry>) {
        self.store = store
    }

    var filtered: [CurrencyPair] {
        pairs.filter { pair in
            search.isEmpty || pair.base.filter(by: search, using: FuzzyAlgorithm(caseInsensitive: true))
        }
    }

    public var body: some View {
        WithViewStore(store) { _ in
            content.primaryNavigation(
                title: L10n.title,
                trailing: { close() }
            )
        }
    }

    func close() -> some View {
        IconButton(
            icon: .closeCirclev3,
            action: { $app.post(event: blockchain.ux.transaction.select.target.article.plain.navigation.bar.button.close.tap) }
        )
    }

    var content: some View {
        VStack {
            SearchBar(
                text: $search,
                isFirstResponder: $isSearching.animation(),
                cancelButtonText: L10n.cancel,
                placeholder: L10n.search
            )
            .padding(.horizontal)
            if pairs.isEmpty {
                Spacer()
                BlockchainProgressView()
                    .transition(.opacity)
                Spacer()
            } else {
                BuyEntryListView(
                    isSearching: $isSearching.animation(),
                    store: store,
                    pairs: filtered
                )
                .transition(.opacity)
            }
        }
        .background(Color.semantic.light.ignoresSafeArea())
        .bindings {
            subscribe($pairs.animation(.easeOut), to: blockchain.api.nabu.gateway.simple.buy.pairs.ids)
        }
        .batch {
            set(blockchain.ux.transaction.select.target.article.plain.navigation.bar.button.close.tap.then.close, to: true)
        }
    }
}

@MainActor
struct BuyEntryListView: View {

    @Binding var isSearching: Bool

    let store: StoreOf<BuyEntry>
    let pairs: [CurrencyPair]

    var body: some View {
        List {
            if !isSearching, isTopMoversEnabled == nil || isTopMoversEnabled == true {
                Section {
                    topMoversView
                        .transition(.opacity)
                }
                .listRowBackground(Color.clear)
                .listRowInsets(.zero)
                .textCase(nil)
                .bindings {
                    subscribe($isTopMoversEnabled, to: blockchain.app.configuration.buy.top.movers.is.enabled)
                }
            }

            if mostPopular.isNotEmpty {
                Section(
                    content: { mostPopularView },
                    header: {
                        sectionHeader(title: L10n.mostPopular)
                    }
                )
                .listRowInsets(.zero)
                .textCase(nil)
                .bindings {
                    subscribe($mostPopular, to: blockchain.app.configuration.buy.most.popular.assets)
                }
            }
            Section(
                content: { otherTokensView },
                header: {
                    sectionHeader(title: L10n.otherTokens)
                }
            )
            .textCase(nil)
            .listRowInsets(.zero)
        }
        .listStyle(.insetGrouped)
    }

    @State private var isTopMoversEnabled: Bool?

    var topMoversView: some View {
        TopMoversSectionView(
            store: store.scope(
                state: \.topMoversState,
                action: BuyEntry.Action.topMoversAction
            )
        )
    }

    @ViewBuilder
    func sectionHeader(title: String) -> some View {
        Text(title)
            .typography(.body2)
            .textCase(nil)
            .foregroundColor(.WalletSemantic.body)
            .padding(.bottom, Spacing.padding1)
    }

    @State private var mostPopular: [CurrencyType] = [.crypto(.bitcoin), .crypto(.ethereum)]

    var popular: [CurrencyPair] {
        pairs.sorted(
            like: mostPopular,
            using: \.base,
            equals: \.self
        )
        .prefix(mostPopular.count)
        .array
    }

    var mostPopularView: some View {
        ForEach(popular, id: \.self) { pair in
            BuyEntryRow(id: blockchain.ux.transaction.select.target.most.popular, pair: pair)
                .context([blockchain.ux.transaction.select.target.most.popular.section.list.item.id: pair.base.code])
        }
    }

    var otherTokens: [CurrencyPair] {
        pairs.filter { pair in mostPopular.doesNotContain(pair.base) }
    }

    var otherTokensView: some View {
        ForEach(otherTokens, id: \.self) { pair in
            BuyEntryRow(id: blockchain.ux.transaction.select.target.other.tokens, pair: pair)
                .context([blockchain.ux.transaction.select.target.other.tokens.section.list.item.id: pair.base.code])
        }
    }
}

@MainActor
struct BuyEntryRow: View {

    @BlockchainApp var app

    let id: L & I_blockchain_ui_type_task
    let pair: CurrencyPair

    @State private var price: MoneyValue?
    @State private var delta: Decimal?
    @State var fastRisingMinDelta: Double?

    var body: some View {
        if #available(iOS 16.0, *) {
            content.alignmentGuide(.listRowSeparatorLeading) { d in d[.leading] }
        } else {
            content
        }
    }

    var content: some View {
        VStack(spacing: 0) {
            HStack(spacing: 0) {
                ZStack(alignment: .bottomTrailing) {
                    AsyncMedia(
                        url: pair.base.cryptoCurrency?.logoURL
                    )
                    .frame(width: 24.pt, height: 24.pt)
                }
                Spacer()
                    .frame(width: 16)
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(pair.base.name)
                            .typography(.paragraph2)
                            .foregroundColor(.WalletSemantic.title)
                            .scaledToFill()
                            .minimumScaleFactor(0.5)
                            .lineLimit(1)

                        Text(pair.base.code)
                            .typography(.caption1)
                            .foregroundColor(.WalletSemantic.body)
                            .scaledToFill()
                            .minimumScaleFactor(0.5)
                            .lineLimit(1)
                    }

                    if Decimal((fastRisingMinDelta ?? 100) / 100).isLessThanOrEqualTo(delta ?? 0) {
                        Icon
                            .fireFilled
                            .micro()
                            .color(.semantic.warningMuted)
                    }

                    Spacer()

                    if let price, price.isPositive {
                        VStack(alignment: .trailing, spacing: 4.pt) {
                            Text(price.toDisplayString(includeSymbol: true))
                                .typography(.paragraph1)
                                .foregroundColor(.WalletSemantic.title)
                                .scaledToFill()
                                .minimumScaleFactor(0.5)
                                .lineLimit(1)

                            if let delta {
                                delta.view
                                    .typography(.caption1)
                                    .foregroundColor(delta.color)
                                    .scaledToFill()
                                    .minimumScaleFactor(0.5)
                                    .lineLimit(1)
                            }
                        }
                    } else {
                        VStack(alignment: .trailing) {
                            Text("............")
                            Text(".....")
                        }
                        .redacted(reason: .placeholder)
                    }
                }
            }
        }
        .padding(Spacing.padding2)
        .background(Color.semantic.background)
        .onTapGesture {
            $app.post(event: id.paragraph.row.tap, context: [blockchain.ux.asset.id: pair.base.code])
        }
        .batch {
            set(id.paragraph.row.tap.then.close, to: true)
            set(id.paragraph.row.tap.then.emit, to: blockchain.ux.asset.buy)
        }
        .bindings {
            subscribe($fastRisingMinDelta, to: blockchain.app.configuration.prices.rising.fast.percent)
            subscribe($price, to: blockchain.api.nabu.gateway.price.crypto[pair.base.code].fiat[pair.quote.code].quote.value)
            subscribe($delta, to: blockchain.api.nabu.gateway.price.crypto[pair.base.code].fiat[pair.quote.code].delta.since.yesterday)
        }
    }
}

extension Decimal {
    var color: Color {
        if isSignMinus {
            return Color.WalletSemantic.pink
        } else if isZero {
            return Color.WalletSemantic.body
        } else {
            return Color.WalletSemantic.success
        }
    }

    @ViewBuilder fileprivate var view: some View {
        Group {
            if #available(iOS 15.0, *) {
                Text(isZero ? "" : (isSignMinus ? "↓" : "↑")) + Text(formatted(.percent.precision(.fractionLength(2))))
            } else {
                Text(isZero ? "" : (isSignMinus ? "↓" : "↑"))
            }
        }
        .foregroundColor(isZero ? .semantic.primary : (isSignMinus ? .semantic.pink : .semantic.success))
    }
}

struct BuyEntryView_Preview: PreviewProvider {
    static var previews: some View {
        BuyEntryView(
            store: .init(
                initialState: .init(),
                reducer: EmptyReducer()
            )
        )
        .app(App.preview)
    }
}
