import Blockchain
import SwiftUI

public struct MoneyValueView: View {

    @Environment(\.redactionReasons) private var redactionReasons
    @Environment(\.typography) var typography
    @Environment(\.context) var context

    @State private var isHidingBalance = false

    let value: MoneyValue

    public init(_ value: MoneyValue) {
        self.value = value
    }

    public var body: some View {
        Text(isRedacted ? redacted : value.displayString)
            .typography(typography.slashedZero())
            .bindings {
                if context[blockchain.ux.dashboard.is.hiding.balance].isNil {
                    subscribe($isHidingBalance, to: blockchain.ux.dashboard.is.hiding.balance)
                }
            }
    }

    var isRedacted: Bool {
        if let isHidingBalance = context[blockchain.ux.dashboard.is.hiding.balance] as? Bool {
            return isHidingBalance
        }
        if #available(iOS 15.0, *) {
            return isHidingBalance || redactionReasons.contains(.privacy)
        } else {
            return isHidingBalance
        }
    }

    var redacted: String {
        value.displayString.hasPrefix(value.displaySymbol) ? "\(value.displaySymbol) ••••" : "•••• \(value.displaySymbol)"
    }
}

public struct MoneyValueAndQuoteView: View {

    @Environment(\.moneyValueViewQuoteCurrency) private var quoteCurrency

    let value: MoneyValue
    let alignment: HorizontalAlignment

    @State private var quoteValue: MoneyValue?

    public init(_ value: MoneyValue, alignment: HorizontalAlignment = .trailing) {
        self.value = value
        self.alignment = alignment
    }

    public var body: some View {
        VStack(alignment: alignment, spacing: 2) {
            if let quoteValue, quoteValue.currency != value.currency {
                value.convert(using: quoteValue)
                    .typography(.paragraph2)
                    .foregroundColor(.semantic.title)
                    .padding(.bottom, 2)
            }
            value.typography(.paragraph1)
                .foregroundColor(.semantic.text)
        }
        .bindings {
            subscribe($quoteValue, to: blockchain.api.nabu.gateway.price.crypto[value.currency.code].fiat[{ quoteCurrency }].quote.value)
        }
    }
}

public struct MoneyValueQuoteAndChangePercentageView: View {

    @Environment(\.moneyValueViewQuoteCurrency) private var quoteCurrency

    let value: MoneyValue
    let alignment: HorizontalAlignment

    @State private var delta: Double?
    @State private var quoteValue: MoneyValue?

    public init(_ value: MoneyValue, alignment: HorizontalAlignment = .trailing) {
        self.value = value
        self.alignment = alignment
    }

    public var body: some View {
        VStack(alignment: alignment, spacing: 2) {
            if let quoteValue {
                value.convert(using: quoteValue)
                    .typography(.paragraph2)
                    .foregroundColor(.semantic.title)
            }
            if let deltaChangeText {
                Text(deltaChangeText)
                    .typography(.caption1.slashedZero())
                    .foregroundColor(color)
                    .padding(.top, 2)
            }
        }
        .bindings {
            subscribe($quoteValue, to: blockchain.api.nabu.gateway.price.crypto[value.currency.code].fiat[{ quoteCurrency }].quote.value)
            subscribe($delta, to: blockchain.api.nabu.gateway.price.crypto[value.currency.code].fiat[{ quoteCurrency }].delta.since.yesterday)
        }
    }

    var deltaDecimal: Decimal? {
        delta.map({ Decimal($0) })
    }

    var color: Color {
        guard let delta = deltaDecimal else { return .semantic.body }
        if delta.isSignMinus {
            return .semantic.pink
        } else if delta.isZero {
            return .semantic.body
        } else {
            return .semantic.success
        }
    }

    var deltaChangeText: String? {
        guard let delta = deltaDecimal else { return nil }
        if #available(iOS 15.0, *) {
            return "\(delta.isSignMinus ? "↓" : "↑") \(delta.abs().formatted(.percent.precision(.fractionLength(2))))"
        } else {
            return "\(delta.isSignMinus ? "↓" : "↑") \(percentageFormatter.string(for: abs(delta.doubleValue)) ?? "")"
        }
    }
}

public struct MoneyValueHeaderView<Subtitle: View>: View {

    @BlockchainApp var app
    @State private var isHidingBalance = false

    let value: MoneyValue
    let subtitle: Subtitle

    public init(
        title value: MoneyValue,
        @ViewBuilder subtitle: () -> Subtitle
    ) {
        self.value = value
        self.subtitle = subtitle()
    }

    public var body: some View {
        VStack(alignment: .center) {
            HStack {
                value.typography(.title1)
                    .foregroundColor(.semantic.title)
                if isHidingBalance {
                    IconButton(icon: .visibilityOff.small().color(.semantic.dark)) {
                        $app.post(value: false, of: blockchain.ux.dashboard.is.hiding.balance)
                    }
                } else {
                    IconButton(icon: .visibilityOn.small().color(.semantic.dark)) {
                        $app.post(value: true, of: blockchain.ux.dashboard.is.hiding.balance)
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .center)
            subtitle.typography(.paragraph2.slashedZero())
        }
        .bindings {
            subscribe($isHidingBalance, to: blockchain.ux.dashboard.is.hiding.balance)
        }
    }
}

public struct MoneyValueRowView: View {

    public enum Variant {
        case quote
        case delta
        case value
    }

    @Environment(\.typography) var typography
    @Environment(\.moneyValueViewQuoteCurrency) private var quoteCurrency

    let value: MoneyValue
    let variant: Variant

    public init(_ value: MoneyValue, _ variant: Variant = .delta) {
        self.value = value
        self.variant = variant
    }

    public var body: some View {
        TableRow(
            leading: {
                value.currency.logo(size: 24.pt)
            },
            title: {
                TableRowTitle(value.currency.name)
            },
            trailing: {
                if value.isCrypto {
                    switch variant {
                    case .quote:
                        MoneyValueAndQuoteView(value, alignment: .trailing)
                    case .delta:
                        MoneyValueQuoteAndChangePercentageView(value, alignment: .trailing)
                    case .value:
                        MoneyValueView(value)
                            .typography(.paragraph1)
                            .foregroundColor(.semantic.title)
                    }
                } else {
                    MoneyValueView(value)
                        .typography(.paragraph1)
                        .foregroundColor(.semantic.title)
                }
            }
        )
        .background(Color.semantic.background)
    }
}

extension MoneyValue: View {

    public var body: some View {
        MoneyValueView(self)
    }

    public func quoteView(alignment: HorizontalAlignment = .trailing) -> some View {
        MoneyValueAndQuoteView(self, alignment: alignment)
    }

    public func deltaView(alignment: HorizontalAlignment = .trailing) -> some View {
        MoneyValueQuoteAndChangePercentageView(self, alignment: alignment)
    }

    public func rowView(_ type: MoneyValueRowView.Variant) -> some View {
        MoneyValueRowView(self, type)
    }

    public func headerView<Subtitle: View>(@ViewBuilder _ subtitle: () -> Subtitle = EmptyView.init) -> some View {
        MoneyValueHeaderView(title: self, subtitle: subtitle)
    }
}

extension Decimal {
    func abs() -> Self { Decimal(Swift.abs(doubleValue)) }
}

let percentageFormatter: NumberFormatter = with(NumberFormatter()) { formatter in
    formatter.numberStyle = .percent
    formatter.maximumFractionDigits = 2
    formatter.minimumFractionDigits = 1
}

/// Environment key set by `PrimaryNavigation`
private struct MoneyValueViewQuoteCurrencyEnvironmentKey: EnvironmentKey {
    static var defaultValue: L & I_blockchain_type_currency = blockchain.user.currency.preferred.fiat.display.currency
}

extension EnvironmentValues {

    public var moneyValueViewQuoteCurrency: L & I_blockchain_type_currency {
        get { self[MoneyValueViewQuoteCurrencyEnvironmentKey.self] }
        set { self[MoneyValueViewQuoteCurrencyEnvironmentKey.self] = newValue }
    }
}

struct MoneyView_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            MoneyValueHeaderView(
                title: .create(major: 98.01, currency: .fiat(.GBP)),
                subtitle: {
                    HStack {
                        MoneyValueView(.create(major: 1.99, currency: .fiat(.GBP)))
                        Text("(34.03%)")
                    }
                    .foregroundColor(.semantic.pink)
                }
            )
            Spacer().frame(maxHeight: 44.pt)
            MoneyValue.create(major: 1.204, currency: .crypto(.bitcoin))
            MoneyValue.create(major: 1699.86, currency: .fiat(.GBP))
            VStack {
                Title("Quote")
                MoneyValueRowView(.create(major: 1.204, currency: .crypto(.bitcoin)), .quote)
                    .cornerRadius(8)
                Title("Delta")
                MoneyValueRowView(.create(major: 1.204, currency: .crypto(.ethereum)), .delta)
                    .cornerRadius(8)
                Title("Value")
                MoneyValueRowView(.create(major: 1.204, currency: .crypto(.stellar)), .value)
                    .cornerRadius(8)
                Title("Fiat")
                MoneyValueRowView(.create(major: 120.24, currency: .fiat(.GBP)), .delta)
                    .cornerRadius(8)
            }
            .padding()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.semantic.light.ignoresSafeArea())
        .app(App.preview.withPreviewData().setup { app in
            try await app.set(blockchain.ux.dashboard.is.hiding.balance, to: true)
        })
        .previewDisplayName("Dashboard Balances")
    }

    static func Title(_ string: String) -> some View {
        Text(string)
            .typography(.caption1)
            .foregroundColor(.semantic.body)
            .frame(maxWidth: .infinity, alignment: .leading)
    }
}
