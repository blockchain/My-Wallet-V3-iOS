import BlockchainUI
import Localization
import SwiftUI

typealias L10n = LocalizationConstants.Checkout

public struct BuyCheckoutView<Object: LoadableObject>: View where Object.Output == BuyCheckout, Object.Failure == Never {

    @BlockchainApp var app
    @Environment(\.context) var context

    @ObservedObject var viewModel: Object

    public init(viewModel: Object) {
        _viewModel = .init(wrappedValue: viewModel)
    }

    public var body: some View {
        AsyncContentView(
            source: viewModel,
            loadingView: Loading(),
            content: Loaded.init
        )
        .onAppear {
            app.post(
                event: blockchain.ux.transaction.checkout[].ref(to: context),
                context: context
            )
        }
    }
}

extension BuyCheckoutView {

    public init<P>(publisher: P) where P: Publisher, P.Output == BuyCheckout, P.Failure == Never, Object == PublishedObject<P, DispatchQueue> {
        self.viewModel = PublishedObject(publisher: publisher)
    }

    public init(_ checkout: Object.Output) where Object == PublishedObject<Just<BuyCheckout>, DispatchQueue> {
        self.init(publisher: Just(checkout))
    }
}

extension BuyCheckoutView {

    public struct Loading: View {

        public var body: some View {
            ZStack {
                BuyCheckoutView.Loaded(checkout: .preview)
                    .redacted(reason: .placeholder)
                ProgressView()
            }
        }
    }

    public struct Loaded: View {

        @BlockchainApp var app
        @Environment(\.context) var context
        @Environment(\.openURL) var openURL
        @State var isAvailableToTradeInfoPresented = false
        @State var isACHTermsInfoPresented = false
        @State var isInvestWeeklySelected = false

        let checkout: BuyCheckout

        @State var information = (price: false, fee: false)
        @State var remaining: TimeInterval = Int.max.d

        public init(checkout: BuyCheckout) {
            self.checkout = checkout
        }

        init(checkout: BuyCheckout, information: (Bool, Bool) = (false, false)) {
            self.checkout = checkout
            _information = .init(wrappedValue: information)
        }
    }
}

extension BuyCheckoutView.Loaded {

    public var body: some View {
        VStack(alignment: .center, spacing: .zero) {
            List {
                Section {
                    header()
                }
                checkoutLineItems
                disclaimer()
            }
            .listStyle(.insetGrouped)
            footer()
        }
        .listStyle(.plain)
        .backgroundTexture(.semantic.background)
        .buttonStyle(.plain)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .bottomSheet(
            isPresented: $isAvailableToTradeInfoPresented
        ) {
            availableToTradeInfoSheet
        }
        .sheet(
            isPresented: $isACHTermsInfoPresented
        ) {
            achTermsInfoSheet
        }
    }

    @ViewBuilder var checkoutLineItems: some View {
        Group {
            price()
            Group {
                paymentMethod()
            }
            purchaseAmount()
            fees()
            recurringBuyFrequency()
            checkoutTotal()
            availableDates()
            investWeekly()
        }
    }

    @ViewBuilder func checkoutTotal() -> some View {
        TableRow(
            title: L10n.Label.total,
            trailing: {
                TableRowTitle(checkout.total.displayString)
            }
        )
    }

    @ViewBuilder func paymentMethod() -> some View {
        TableRow(
            title: L10n.Label.paymentMethod,
            trailing: {
                VStack(alignment: .trailing, spacing: .zero) {
                    TableRowTitle(checkout.paymentMethod.name)
                    if let detail = checkout.paymentMethod.detail {
                        TableRowByline(detail)
                    }
                }
            }
        )
    }

    @ViewBuilder func purchaseAmount() -> some View {
        TableRow(
            title: L10n.Label.purchase,
            trailing: {
                VStack(alignment: .trailing, spacing: .zero) {
                    TableRowTitle(checkout.fiat.displayString)
                    TableRowByline(checkout.crypto.displayString)
                }
            }
        )
    }

    @ViewBuilder var availableToTradeInfoSheet: some View {
        VStack(alignment: .leading, spacing: 19) {
            HStack {
                Text(L10n.AvailableToTradeInfo.title)
                    .typography(.body2)
                    .foregroundTexture(.semantic.title)
                Spacer()
                IconButton(icon: .closeCirclev2) {
                    isAvailableToTradeInfoPresented = false
                }
                .frame(width: 24.pt, height: 24.pt)
            }

            VStack(alignment: .leading, spacing: Spacing.padding2) {
                Text(L10n.AvailableToTradeInfo.description)
                    .typography(.body1)
                    .foregroundTexture(.semantic.text)
                SmallMinimalButton(title: L10n.AvailableToTradeInfo.learnMoreButton) {
                    isAvailableToTradeInfoPresented = false
                    Task { @MainActor in
                        try await openURL(app.get(blockchain.ux.transaction["buy"].checkout.terms.of.withdraw))
                    }
                }
            }
        }
        .padding(Spacing.padding3)
    }

    @ViewBuilder var achTermsInfoSheet: some View {
        PrimaryNavigationView {
            VStack {
                ScrollView {
                    Text(checkout.achTermsInfoDescriptionText)
                        .fixedSize(horizontal: false, vertical: true)
                        .typography(.body1)
                        .foregroundTexture(.semantic.text)
                }
                PrimaryButton(title: L10n.ACHTermsInfo.doneButton) {
                    isACHTermsInfoPresented = false
                }
                .frame(alignment: .bottom)
            }
            .primaryNavigation(
                title: L10n.ACHTermsInfo.title,
                trailing: {
                    IconButton(icon: .closeCirclev2) {
                        isACHTermsInfoPresented = false
                    }
                    .frame(width: 24.pt, height: 24.pt)
                }
            )
            .padding([.horizontal, .bottom], Spacing.padding3)
            .padding(.top, Spacing.padding1)
        }
    }

    @ViewBuilder func header() -> some View {
        HStack {
            Spacer()
            VStack(alignment: .center, spacing: Spacing.padding1) {
                if let expiration = checkout.quoteExpiration {
                    CountdownView(
                        deadline: expiration,
                        remainingTime: $remaining
                    )
                    .padding()
                }
                Text(checkout.fiat.displayString)
                    .typography(.title1)
                    .foregroundTexture(.semantic.title)
                    .minimumScaleFactor(0.7)
                HStack(spacing: .zero) {
                    Text(checkout.crypto.displayString)
                        .typography(.body1)
                        .foregroundTexture(.semantic.body)
                }
            }
            Spacer()
        }
    }

    @ViewBuilder func price() -> some View {
        TableRow(
            title: .init(L10n.Label.price(checkout.crypto.code)),
            inlineTitleButton: IconButton(icon: question(information.price), toggle: $information.price),
            trailing: {
                TableRowTitle(checkout.exchangeRate.displayString)
            }
        )
        if information.price {
            explain(L10n.Label.priceDisclaimer) {
                try await app.post(
                    value: app.get(blockchain.ux.transaction.checkout.exchange.rate.disclaimer.url) as URL,
                    of: blockchain.ux.transaction.checkout.exchange.rate.disclaimer.then.launch.url
                )
            }
        }
    }

    func question(_ isOn: Bool) -> Icon {
        Icon.questionCircle.micro().color(isOn ? .semantic.primary : .semantic.dark)
    }

    @ViewBuilder func fees() -> some View {
        if let fee = checkout.fee {
            TableRow(
                title: .init(L10n.Label.blockchainFee),
                inlineTitleButton: IconButton(icon: question(information.fee), toggle: $information.fee),
                trailing: {
                    if let promotion = fee.promotion, promotion != fee.value {
                        HStack {
                            Text(rich: "~~\(fee.value.displayString)~~")
                                .typography(.paragraph1)
                                .foregroundColor(.semantic.text)
                            TagView(
                                text: promotion.isZero ? L10n.Label.free : promotion.displayString,
                                variant: .success,
                                size: .large
                            )
                        }
                    } else if fee.value.isZero {
                        TagView(text: L10n.Label.free, variant: .success, size: .large)
                    } else {
                        TableRowTitle(fee.value.displayString)
                    }
                }
            )
            if fee.value.isNotZero, information.fee {
                explain(L10n.Label.custodialFeeDisclaimer) {
                    try await app.post(
                        value: app.get(blockchain.ux.transaction.checkout.fee.disclaimer.url) as URL,
                        of: blockchain.ux.transaction.checkout.fee.disclaimer.then.launch.url
                    )
                }
            }
        }
    }

    @ViewBuilder func recurringBuyFrequency() -> some View {
        if let recurringBuyDetails = checkout.recurringBuyDetails, isRecurringBuyEnabled {
            TableRow(
                title: .init(LocalizationConstants.Transaction.Confirmation.frequency),
                trailing: {
                    VStack(alignment: .trailing, spacing: .zero) {
                        TableRowTitle(recurringBuyDetails.frequency)
                        if let description = recurringBuyDetails.description {
                            TableRowByline(description)
                        }
                    }
                }
            )
        }
    }

    @ViewBuilder func availableDates() -> some View {
        if isUIPaymentsImprovementsEnabled {
            if let availableToTrade = checkout.depositTerms?.availableToTrade {
                TableRow(
                    title: .init(LocalizationConstants.Transaction.Confirmation.availableToTrade),
                    trailing: {
                        TableRowTitle(availableToTrade)
                    }
                )
            }

            if let availableToWithdraw = checkout.depositTerms?.availableToWithdraw {
                TableRow(
                    title: .init(LocalizationConstants.Transaction.Confirmation.availableToWithdraw),
                    inlineTitleButton: IconButton(
                        icon: question(information.fee),
                        toggle: $isAvailableToTradeInfoPresented
                    ),
                    trailing: {
                        TableRowTitle(availableToWithdraw)
                    }
                )
            }
        }
    }

    @ViewBuilder
    func investWeekly() -> some View {
        if checkout.displaysInvestWeekly, isRecurringBuyEnabled {
            TableRow(
                title: { TableRowTitle(L10n.Label.investWeeklyTitle) },
                trailing: {
                    Toggle(isOn: $isInvestWeeklySelected) {
                        EmptyView()
                    }
                    .toggleStyle(.switch)
                },
                footer: {
                    Text(String(format: L10n.Label.investWeeklySubtitle, checkout.total.displayString))
                        .typography(.caption1)
                        .foregroundColor(.semantic.body)
                }
            )
            .onChange(of: isInvestWeeklySelected) { newValue in
                $app.post(value: newValue, of: blockchain.ux.transaction.checkout.recurring.buy.invest.weekly)
            }
        }
    }

    @ViewBuilder
    func explain(_ content: some StringProtocol, action: @escaping () async throws -> Void) -> some View {
        HStack {
            VStack(alignment: .leading) {
                Text(rich: content)
                    .foregroundColor(.semantic.text)
                Button(L10n.Button.learnMore) {
                    Task(priority: .userInitiated) { @MainActor [app] in
                        do {
                            try await action()
                        } catch {
                            app.post(error: error)
                        }
                    }
                }
            }
            Spacer()
        }
        .multilineTextAlignment(.leading)
        .typography(.caption1)
        .transition(.scale.combined(with: .opacity))
        .padding()
        .background(Color.semantic.light)
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .padding([.leading, .trailing], 8.pt)
    }

    @ViewBuilder func disclaimer() -> some View {
        VStack(alignment: .leading) {
            if isUIPaymentsImprovementsEnabled, checkout.paymentMethod.isACH {
                VStack(alignment: .leading, spacing: Spacing.padding2) {
                    Text(checkout.achTransferDisclaimerText)
                    .multilineTextAlignment(.leading)
                    SmallMinimalButton(title: L10n.AchTransferDisclaimer.readMoreButton) {
                        isACHTermsInfoPresented = true
                    }
                }
            } else {
                Text(L10n.Label.indicativeDisclaimer)
                    .multilineTextAlignment(.center)
                Text(rich: L10n.Label.termsOfService)
                    .onTapGesture {
                        $app.post(event: blockchain.ux.transaction.checkout.terms.of.service)
                    }
            }
        }
        .padding()
        .typography(.caption1)
        .foregroundColor(.semantic.text)
        .batch {
            set(blockchain.ux.transaction.checkout.terms.of.service.then.launch.url, to: { blockchain.ux.transaction.checkout.terms.of.service.url })
        }
    }

    func confirmed() {
        app.post(
            event: blockchain.ux.transaction.checkout.confirmed[].ref(to: context),
            context: context
        )
    }

    @ViewBuilder
    func footer() -> some View {
        VStack(spacing: .zero) {
            if let recurringBuyDetails = checkout.recurringBuyDetails, isRecurringBuyEnabled {
                PrimaryButton(
                    title: L10n.Button.buy(checkout.crypto.code) + " \(recurringBuyDetails.frequency)",
                    isLoading: remaining <= 3,
                    action: confirmed
                )
                .disabled(remaining <= 3)
            } else if checkout.paymentMethod.isApplePay {
                ApplePayButton(action: confirmed)
            } else {
                PrimaryButton(
                    title: L10n.Button.buy(checkout.crypto.code),
                    isLoading: remaining <= 3,
                    action: confirmed
                )
                .disabled(remaining <= 3)
            }
        }
        .padding()
        .backgroundWithShadow(.top)
    }
}

extension BuyCheckoutView.Loaded {
    private var isRecurringBuyEnabled: Bool {
        app.remoteConfiguration.yes(if: blockchain.app.configuration.recurring.buy.is.enabled)
    }

    private var isUIPaymentsImprovementsEnabled: Bool {
        app.remoteConfiguration.yes(if: blockchain.app.configuration.ui.payments.improvements.is.enabled)
    }
}

struct BuyCheckoutView_Previews: PreviewProvider {

    static var previews: some View {
        PrimaryNavigationView {
            BuyCheckoutView(.preview)
                .primaryNavigation(title: "Checkout")
        }
        .app(App.preview)

        PrimaryNavigationView {
            BuyCheckoutView(.promotion)
                .primaryNavigation(title: "Checkout")
        }
        .app(App.preview)

        PrimaryNavigationView {
            BuyCheckoutView(.free)
                .primaryNavigation(title: "Checkout")
        }
        .app(App.preview)
    }
}

extension BuyCheckout {

    static var promotion = { checkout in
        var checkout = checkout
        checkout.fee?.promotion = FiatValue.create(minor: "49", currency: .USD)
        return checkout
    }(BuyCheckout.preview)

    static var free = { checkout in
        var checkout = checkout
        checkout.fee?.promotion = FiatValue.create(minor: "0", currency: .USD)
        return checkout
    }(BuyCheckout.preview)
}

#if canImport(PassKit)

import PassKit

private struct _ApplePayButton: UIViewRepresentable {
    func updateUIView(_ uiView: PKPaymentButton, context: Context) {}
    func makeUIView(context: Context) -> PKPaymentButton {
        PKPaymentButton(paymentButtonType: .plain, paymentButtonStyle: .black)
    }
}

struct ApplePayButtonStyle: ButtonStyle {
    func makeBody(configuration: Self.Configuration) -> some View { _ApplePayButton().frame(maxHeight: 44.pt) }
}

struct ApplePayButton: View {

    var button: Button<EmptyView>

    init(action: @escaping () -> Void) {
        self.button = Button(action: action, label: EmptyView.init)
    }

    var body: some View {
        button.buttonStyle(ApplePayButtonStyle())
    }
}
#endif

extension BuyCheckout {
    private var paymentMethodLabel: String {
        [paymentMethod.name, paymentMethod.detail].compactMap { $0 }.joined(separator: " ")
    }

    fileprivate var achTermsInfoDescriptionText: String {
        let description: String = {
            switch buyType {
            case .simpleBuy:
                return L10n.ACHTermsInfo.simpleBuyDescription
            case .recurringBuy:
                return L10n.ACHTermsInfo.recurringBuyDescription
            }
        }()
        return String(
            format: description,
            paymentMethodLabel,
            total.displayString,
            depositTerms?.withdrawalLockInDays ?? ""
        )
    }

    fileprivate var achTransferDisclaimerText: String {
        switch buyType {
        case .simpleBuy:
            return String(
                format: L10n.AchTransferDisclaimer.simpleBuyDescription,
                total.displayString,
                crypto.code,
                exchangeRate.displayString
            )
        case .recurringBuy:
            return String(
                format: L10n.AchTransferDisclaimer.recurringBuyDescription,
                paymentMethodLabel,
                total.displayString
            )
        }
    }
}
