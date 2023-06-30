import BlockchainNamespace
import BlockchainUI
import DIKit
import FeatureTopMoversCryptoUI
import SwiftUI
import SwiftUIExtensions

@MainActor
public struct BuyEntryView: View {

    typealias L10n = LocalizationConstants.BuyEntry

    @BlockchainApp var app

    @State private var pairs: [CurrencyPair] = []
    @State private var search: String = ""
    @State private var isSearching: Bool = false

    public init() {}

    var filtered: [CurrencyPair] {
        pairs.filter { pair in
            search.isEmpty || pair.base.filter(by: search, using: FuzzyAlgorithm(caseInsensitive: true))
        }
    }

    public var body: some View {
        content.primaryNavigation(
            title: L10n.title,
            trailing: { close() }
        )
    }

    func close() -> some View {
        IconButton(
            icon: .closeCirclev3,
            action: {
                $app.post(event: blockchain.ux.transaction.select.target.article.plain.navigation.bar.button.close.tap)
                // this resolves an edge case that might display the recurring buy frequency bottom sheet automatically
                // When a user taps on Add A Recurring buy on RecurringBuyManageView we set the following state to true
                // and then display this view, in case the user closes this view we need to clear this state
                app.state.clear(blockchain.ux.transaction["buy"].action.show.recurring.buy)
            }
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
        .onInteractiveDismissal {
            // this resolves an edge case that might display the recurring buy frequency bottom sheet automatically
            // When a user taps on Add A Recurring buy on RecurringBuyManageView we set the following state to true
            // and then display this view, in case the user closes this view we need to clear this state
            app.state.clear(blockchain.ux.transaction["buy"].action.show.recurring.buy)
        }
    }
}

@MainActor
struct BuyEntryListView: View {

    typealias L10n = LocalizationConstants.BuyEntry

    @Binding var isSearching: Bool

    let pairs: [CurrencyPair]

    init(isSearching: Binding<Bool>, pairs: [CurrencyPair]) {
        self.pairs = pairs
        _isSearching = isSearching
        _topMovers = .init(
            wrappedValue: .init(
                initialState: .init(presenter: .accountPicker),
                reducer: TopMoversSection(app: resolve(), topMoversService: resolve())
            )
        )
    }

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

            if !isSearching, mostPopular.isNotEmpty {
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
                    if isSearching {
                        sectionHeader(title: L10n.searching)
                    } else {
                        sectionHeader(title: L10n.otherTokens)
                    }
                }
            )
            .textCase(nil)
            .listRowInsets(.zero)
        }
        .hideScrollContentBackground()
        .listStyle(.insetGrouped)
        .background(Color.semantic.light)
    }

    @State private var isTopMoversEnabled: Bool?
    @State private var topMovers: StoreOf<TopMoversSection>

    var topMoversView: some View {
        TopMoversSectionView(store: topMovers)
    }

    @ViewBuilder
    func sectionHeader(title: String) -> some View {
        Text(title)
            .typography(.body2)
            .textCase(nil)
            .foregroundColor(.semantic.body)
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
                .listRowSeparatorTint(Color.semantic.light)
                .context([blockchain.ux.transaction.select.target.most.popular.section.list.item.id: pair.base.code])
        }
    }

    var otherTokens: [CurrencyPair] {
        if isSearching { return pairs }
        return pairs.filter { pair in mostPopular.doesNotContain(pair.base) }
    }

    var otherTokensView: some View {
        ForEach(otherTokens, id: \.self) { pair in
            BuyEntryRow(id: blockchain.ux.transaction.select.target.other.tokens, pair: pair)
                .listRowSeparatorTint(Color.semantic.light)
                .context([blockchain.ux.transaction.select.target.other.tokens.section.list.item.id: pair.base.code])
        }
    }
}

@MainActor
struct BuyEntryRow: View {

    @BlockchainApp var app
    @Environment(\.scheduler) var scheduler

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
                            .foregroundColor(.semantic.title)
                            .scaledToFill()
                            .minimumScaleFactor(0.5)
                            .lineLimit(1)

                        Text(pair.base.code)
                            .typography(.caption1)
                            .foregroundColor(.semantic.body)
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
                                .foregroundColor(.semantic.title)
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
            Task {
                $app.post(event: id.paragraph.row.tap, context: [blockchain.ux.asset.id: pair.base.code])
            }
        }
        .batch {
            set(id.paragraph.row.tap.then.navigate.to, to: blockchain.ux.transaction["buy"])
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
            return Color.semantic.pink
        } else if isZero {
            return Color.semantic.body
        } else {
            return Color.semantic.success
        }
    }

    @ViewBuilder fileprivate var view: some View {
        Text(isZero ? "" : (isSignMinus ? "↓" : "↑")) + Text(formatted(.percent.precision(.fractionLength(2))))
            .foregroundColor(isZero ? .semantic.primary : (isSignMinus ? .semantic.pink : .semantic.success))
    }
}

struct BuyEntryView_Preview: PreviewProvider {
    static var previews: some View {
        BuyEntryView()
            .app(App.preview)
    }
}
