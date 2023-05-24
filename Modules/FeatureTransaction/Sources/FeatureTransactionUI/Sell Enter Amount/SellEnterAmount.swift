//Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Blockchain
import BlockchainUI
import FeatureTransactionDomain
import PlatformKit
import AnalyticsKit
import PlatformUIKit


public struct SellEnterAmount: ReducerProtocol {
    var app: AppProtocol
    private let transactionModel: TransactionModel
    var maxLimitPublisher: AnyPublisher<FiatValue,Never> {
        maxLimitPassThroughSubject.eraseToAnyPublisher()
    }
    private var maxLimitPassThroughSubject = PassthroughSubject<FiatValue, Never>()

    public init(
        app: AppProtocol,
        transactionModel: TransactionModel
    ) {
        self.app = app
        self.transactionModel = transactionModel
    }

    // MARK: - State

    public struct State: Equatable {
        var isEnteringFiat: Bool = true
        var source: CryptoCurrency? {
            sourceBalance?.currency.cryptoCurrency
        }

        var fullInputText: String = "" {
            didSet {
                updateAmounts()
            }
        }
        @BindingState var showAccountSelect: Bool = false
        @BindingState var sourceBalance: MoneyValue?
        @BindingState var defaultFiatCurrency: FiatCurrency?
        @BindingState var exchangeRate: MoneyValuePair?
        @BindingState var input: MoneyValue?
        var prefillButtonsState = PrefillButtons.State(action: .sell)

        public init() {}

        var previewButtonDisabled: Bool {
            finalSelectedMoneyValue == nil || finalSelectedMoneyValue?.isZero == true
        }

        var transactionDetails: (forbidden: Bool, ctaLabel: String) {
            guard let defaultFiatCurrency,
                  let maxAmountToSwap,
                  let amountFiatEntered,
                  let currentEnteredMoneyValue,
                  let amountFiatEntered = amountFiatEntered.fiatValue
            else {
                return (forbidden: false, ctaLabel: LocalizationConstants.Transaction.Sell.Amount.previewButton)
            }

            let minimumSwapFiatValue = FiatValue.create(major: Decimal(5), currency: defaultFiatCurrency)
            if (try? amountFiatEntered < FiatValue.create(major: Decimal(5), currency: defaultFiatCurrency)) ?? false {
                return (
                    forbidden: true,
                    ctaLabel: String.localizedStringWithFormat(
                        LocalizationConstants.Transaction.Sell.Amount.belowMinimumLimitCTA,
                        minimumSwapFiatValue.toDisplayString(includeSymbol: true)
                    )
                )
            }

            if (try? currentEnteredMoneyValue > maxAmountToSwap) ?? false {
                return (
                    forbidden: true,
                    ctaLabel: String.localizedStringWithFormat(
                        LocalizationConstants.Swap.notEnoughCoin,
                        source?.code ?? ""
                    )
                )
            }

            return (forbidden: false, ctaLabel: LocalizationConstants.Transaction.Sell.Amount.previewButton)
        }

        var finalSelectedMoneyValue: MoneyValue? {
            if isEnteringFiat {
                return amountFiatEntered?
                    .toCryptoAmount(
                        currency: source,
                        cryptoPrice: exchangeRate?.quote
                    )
            } else {
                return amountCryptoEntered
            }
        }

        var mainFieldText: String {
            if isEnteringFiat {
                return amountFiatEntered?.fiatValue?.toDisplayString(includeSymbol: true, format: .shortened) ?? defaultZeroFiat
            } else {
                return amountCryptoEntered?.toDisplayString(includeSymbol: true) ?? defaultZeroCryptoCurrency
            }
        }

        var secondaryFieldText: String {
            if isEnteringFiat == true {
                return amountFiatEntered?
                    .toCryptoAmount(
                        currency: source,
                        cryptoPrice: exchangeRate?.quote
                    )?
                    .displayString
                ?? defaultZeroCryptoCurrency
            } else {
                return amountCryptoEntered?
                    .cryptoValue?
                    .toFiatAmount(with: exchangeRate?.quote)?
                    .toDisplayString(includeSymbol: true, format: .shortened) ?? defaultZeroFiat
            }
        }

        private var defaultZeroFiat: String {
            defaultFiatCurrency.flatMap(FiatValue.zero(currency:))?.toDisplayString(includeSymbol: true, format: .shortened) ?? ""
        }

        private var defaultZeroCryptoCurrency: String {
            guard let currency = source else {
                return ""
            }
            return CryptoValue(storeAmount: 0, currency: currency).toDisplayString(includeSymbol: true)
        }

        var maxAmountToSwapFiatValue: MoneyValue? {
            return sourceBalance?.cryptoValue?.toFiatAmount(with: exchangeRate?.quote)?.moneyValue
        }

        var maxAmountToSwapCryptoValue: MoneyValue? {
            sourceBalance
        }

        var maxAmountToSwap: MoneyValue? {
            if isEnteringFiat {
                return sourceBalance?.cryptoValue?.toFiatAmount(with: exchangeRate?.quote)?.moneyValue
            } else {
                return sourceBalance
            }
        }

        var currentEnteredMoneyValue: MoneyValue? {
            if isEnteringFiat {
                return amountFiatEntered
            } else {
                return amountCryptoEntered
            }
        }

        var amountFiatEntered: MoneyValue?
        var amountCryptoEntered: MoneyValue?

        mutating func updateAmounts() {
            guard let currency = defaultFiatCurrency else {
                return
            }

            guard let sourceCurrency = source else {
                return
            }


            amountFiatEntered = MoneyValue
                .create(
                    major: fullInputText,
                    currency: currency.currencyType
                )

            amountCryptoEntered = MoneyValue.create(
                minor: fullInputText,
                currency: sourceCurrency.currencyType
            )
        }
    }

    // MARK: - Action

    public enum Action: BindableAction {
        case streamPricesTask
        case onAppear
        case didFetchSourceBalance(MoneyValue?)
        case onChangeInputTapped
        case onSelectSourceTapped
        case updateBalance
        case binding(BindingAction<SellEnterAmount.State>)
        case onCloseTapped
        case onPreviewTapped
        case fetchSourceBalance
        case prefillButtonAction(PrefillButtons.Action)
        case onInputChanged(String)
    }

    struct Price: Decodable, Equatable {
        let pair: String
        let amount, result: String
    }

    // MARK: - Reducer

    public var body: some ReducerProtocol<State, Action> {
        BindingReducer()

        Scope(state: \.prefillButtonsState, action: /Action.prefillButtonAction) {
            PrefillButtons(app: app,
                           lastPurchasePublisher: .empty(),
                           maxLimitPublisher: self.maxLimitPublisher) { _, _ in }
        }

        Reduce { state, action in
            switch action {
            case .streamPricesTask:
                return .run { send in
                    for await value in app.stream(blockchain.ux.transaction.source.target.quote.price, as: Price.self) {
                        do {
                            let quote = try value.get()
                            let pair = quote.pair.splitIfNotEmpty(separator: "-")
                            let (source, destination) = try (
                                (pair.first?.string).decode(Either<CryptoCurrency, FiatCurrency>.self),
                                (pair.last?.string).decode(Either<CryptoCurrency, FiatCurrency>.self)
                            )
                            let amount = try MoneyValue.create(minor: quote.amount, currency: source.currency).or(throw: "No amount")
                            let result = try MoneyValue.create(minor: quote.result, currency: destination.currency).or(throw: "No result")
                            let exchangeRate = try await MoneyValuePair(base: amount, quote: result).toFiat(in: app)
                            
                            await send(.binding(.set(\.$input, amount)))
                            await send(.binding(.set(\.$exchangeRate, exchangeRate)))
                        } catch let error {
                            print(error.localizedDescription)
                            await send(.binding(.set(\.$input, nil)))
                            await send(.binding(.set(\.$exchangeRate, nil)))
                        }
                }
            }

            case .onAppear:
                return .merge(
                    EffectTask(value: .fetchSourceBalance)
                )

            case .fetchSourceBalance:
                return .run { send in
                    let currency = try? await app.get(blockchain.ux.transaction.source.id, as: String.self)
                    let appMode = await app.mode()
                    switch appMode {
                    case .pkw:
                        let balance = try? await app.get(blockchain.user.pkw.asset[currency].balance, as: MoneyValue.self)
                        await send(.didFetchSourceBalance(balance))
                    case .trading, .universal:
                        let balance = try? await app.get(blockchain.user.trading.account[currency].balance.available, as: MoneyValue.self)
                        await send(.didFetchSourceBalance(balance))
                    }
                }


            case .didFetchSourceBalance(let moneyValue):
                state.sourceBalance = moneyValue
                transactionModel.process(action: .fetchPrice(amount: moneyValue))
                return .none

            case .binding(\.$exchangeRate):
                if let maxLimitFiatValue = state.maxAmountToSwap?.fiatValue {
                    maxLimitPassThroughSubject.send(maxLimitFiatValue)
                }
                return .none

            case .onChangeInputTapped:
                state.isEnteringFiat.toggle()
                app.state.set(blockchain.ux.transaction.enter.amount.active.input,
                                  to: state.isEnteringFiat ?
                                  blockchain.ux.transaction.enter.amount.active.input.crypto[] : blockchain.ux.transaction.enter.amount.active.input.fiat[]
                )
                return .none

            case .onSelectSourceTapped:
                return .run { _ in
                    try? await app.set(blockchain.ux.transaction.checkout.article.plain.navigation.bar.button.back.tap.then.pop, to: true)
                    app.post(event: blockchain.ux.transaction.checkout.article.plain.navigation.bar.button.back.tap)
                }

            case .onPreviewTapped:
                transactionModel.process(action: .prepareTransaction)
                return .none

            case .onInputChanged(let text):
                state.fullInputText.appendAndFormat(text)
                if let currentEnteredMoneyValue = state.currentEnteredMoneyValue {
                    transactionModel.process(action: .fetchPrice(amount: currentEnteredMoneyValue))
                    app.post(value: state.finalSelectedMoneyValue?.minorString, of: blockchain.ux.transaction.enter.amount.input.value)
                }

                if let finalSelectedMoneyValue = state.finalSelectedMoneyValue {
                    transactionModel.process(action: .updateAmount(finalSelectedMoneyValue))
                    app.state.set(
                        blockchain.ux.transaction.enter.amount.output.value,
                        to: finalSelectedMoneyValue.displayMajorValue.doubleValue
                    )
                }
                return .none

            case .prefillButtonAction(let action):
                switch action {
                case .select(let moneyValue, _):
                    state.isEnteringFiat = true
                    state.amountFiatEntered = moneyValue.moneyValue
                    transactionModel.process(action: .updateAmount(moneyValue.moneyValue))
                    app.state.set(
                        blockchain.ux.transaction.enter.amount.output.value,
                        to: moneyValue.displayMajorValue.doubleValue
                    )
                default:
                    return .none
                }
                return .none

            case .binding:
                return .none


            case .onCloseTapped:
                return .none

            case .updateBalance:
                return .none

            }
        }
    }
}

private extension String {
    var digits: String {
        let both = CharacterSet.decimalDigits.union(CharacterSet (charactersIn: ".")).inverted
        return components(separatedBy: both)
            .joined()
    }

    mutating func appendAndFormat(_ other: String) {
        if other == "delete" {
            // Delete the last character
            if !isEmpty {
                removeLast()
            }

            // If the last remaining character is ".", delete it
            if last == "." {
                removeLast()
            }
        } else {
            let decimalIndex = firstIndex(of: ".")
            let shouldAppend = decimalIndex == nil || decimalIndex.map { self.distance(from: $0, to: self.endIndex) < 3 } ?? true

            if shouldAppend {
                append(other)
            }

            let regexPattern = "(\\.)(?=.*\\.)"
            let regex = try! NSRegularExpression(pattern: regexPattern, options: [])
            let range = NSRange(location: 0, length: utf16.count)

            let formattedString = regex.stringByReplacingMatches(in: self, options: [], range: range, withTemplate: "")
            self = formattedString
        }
    }
}
