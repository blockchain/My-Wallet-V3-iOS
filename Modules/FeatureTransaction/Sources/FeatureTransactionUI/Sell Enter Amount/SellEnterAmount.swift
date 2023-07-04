//Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Blockchain
import BlockchainUI
import FeatureTransactionDomain
import PlatformKit
import AnalyticsKit
import PlatformUIKit


public struct SellEnterAmount: ReducerProtocol {
    var app: AppProtocol
    public var onAmountChanged: (MoneyValue) -> Void
    public var onPreviewTapped: (MoneyValue) -> Void
    var maxLimitPublisher: AnyPublisher<FiatValue,Never> {
        minMaxAmountsPublisher
            .compactMap(\.maxSpendableFiatValue.fiatValue)
            .eraseToAnyPublisher()
    }
    public var minMaxAmountsPublisher: AnyPublisher<TransactionMinMaxValues,Never>

    public init(
        app: AppProtocol,
        onAmountChanged: @escaping (MoneyValue) -> Void,
        onPreviewTapped: @escaping (MoneyValue) -> Void,
        minMaxAmountsPublisher: AnyPublisher<TransactionMinMaxValues,Never>
    ) {
        self.app = app
        self.onAmountChanged = onAmountChanged
        self.onPreviewTapped = onPreviewTapped
        self.minMaxAmountsPublisher = minMaxAmountsPublisher
    }

    // MARK: - State

    public struct State: Equatable {
        var isEnteringFiat: Bool = true
        var source: CryptoCurrency? {
            sourceBalance?.currency.cryptoCurrency
        }

        var rawInput = CurrencyInputFormatter() {
            didSet {
                updateAmounts()
            }
        }
        @BindingState var showAccountSelect: Bool = false
        @BindingState var sourceBalance: MoneyValue?
        @BindingState var defaultFiatCurrency: FiatCurrency?
        @BindingState var exchangeRate: MoneyValuePair?
        var transactionMinMaxValues: TransactionMinMaxValues?
        var prefillButtonsState = PrefillButtons.State(action: .sell)

        public init() {}

        var previewButtonDisabled: Bool {
            amountCryptoEntered == nil || amountCryptoEntered?.isZero == true
        }

        var transactionDetails: (forbidden: Bool, ctaLabel: String) {
            guard let maxAmountToSwap,
                  let currentEnteredMoneyValue = amountCryptoEntered,
                  currentEnteredMoneyValue.isZero == false
            else {
                return (forbidden: false, ctaLabel: LocalizationConstants.Transaction.Sell.Amount.previewButton)
            }

            if let minAmountToSwap = minAmountToSwap,
               let currentEnteredMoneyValue = amountCryptoEntered,
             (try? currentEnteredMoneyValue < minAmountToSwap) ?? false {

                let displayString = isEnteringFiat ? transactionMinMaxValues?.minSpendableFiatValue.toDisplayString(includeSymbol: true) :
                transactionMinMaxValues?.minSpendableCryptoValue.toDisplayString(includeSymbol: true)

                return (
                    forbidden: true,
                    ctaLabel: String.localizedStringWithFormat(
                        LocalizationConstants.Transaction.Sell.Amount.belowMinimumLimitCTA,
                        displayString ?? ""
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

        var mainFieldText: String {
            if isEnteringFiat {
                return [defaultFiatCurrency?.displaySymbol, rawInput.suggestion].compacted().joined(separator: " ")
            } else {
                return [rawInput.suggestion, source?.displayCode].compacted().joined(separator: " ")
            }
        }


        var secondaryFieldText: String {
            if isEnteringFiat {
                return amountCryptoEntered?
                    .toDisplayString(includeSymbol: true) ?? defaultZeroCryptoCurrency
            } else {
                return projectedFiatValue?
                    .displayString
                ?? defaultZeroFiat
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

        var maxAmountToSwap: MoneyValue? {
            transactionMinMaxValues?.maxSpendableCryptoValue
        }

        var minAmountToSwap: MoneyValue? {
            transactionMinMaxValues?.minSpendableCryptoValue
        }

        var projectedFiatValue: MoneyValue? {
            amountCryptoEntered?
                .cryptoValue?
                .toFiatAmount(with: exchangeRate?.quote)?
                .moneyValue
        }


        var amountCryptoEntered: MoneyValue?

        mutating func updateAmounts() {
            guard let currency = defaultFiatCurrency else { return }
            guard let sourceCurrency = source?.currencyType.cryptoCurrency else { return }
            if isEnteringFiat {
                let fiatAmount = MoneyValue.create(majorDisplay: rawInput.suggestion, currency: currency.currencyType)
                amountCryptoEntered = fiatAmount?.toCryptoAmount(currency: sourceCurrency, cryptoPrice: exchangeRate?.quote)
            } else {
                amountCryptoEntered = MoneyValue.create(majorDisplay: rawInput.suggestion, currency: sourceCurrency.currencyType)
            }
        }
    }

    // MARK: - Action

    public enum Action: BindableAction {
        case streamData
        case onAppear
        case didFetchSourceBalance(MoneyValue?)
        case onChangeInputTapped
        case onSelectSourceTapped
        case updateBalance
        case binding(BindingAction<SellEnterAmount.State>)
        case onCloseTapped
        case onPreviewTapped
        case prefillButtonAction(PrefillButtons.Action)
        case onInputChanged(String)
        case onBackspace
        case resetInput(newInput: String?)
        case onMinMaxAmountsFetched(TransactionMinMaxValues)
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
            case .streamData:
                return .merge(
                    // streaming quote prices
                    .run { send in
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

                                if exchangeRate.base.isNotZero, exchangeRate.quote.isNotZero {
                                    await send(.binding(.set(\.$exchangeRate, exchangeRate)))
                                }
                            } catch let error {
                                print(error.localizedDescription)
                                await send(.binding(.set(\.$exchangeRate, nil)))
                            }
                        }
                    },

                    // streaming source balances
                    .run { send in
                        for await result in app.stream(blockchain.coin.core.account[{blockchain.ux.transaction.source.account.id}].balance.available, as: MoneyValue.self) {
                            do {
                                let balance = try result.get()
                                await send(.didFetchSourceBalance(balance))
                            } catch {
                                app.post(error: error)
                            }
                        }
                    },

                    minMaxAmountsPublisher
                        .eraseToEffect()
                        .map(Action.onMinMaxAmountsFetched)
                )

            case .onAppear:
                if let source = state.source {
                    let amount = state.amountCryptoEntered ?? .zero(currency: source)
                    onAmountChanged(amount)
//                    transactionModel.process(action: .updateAmount(amount))
                }
                return .none

            case .didFetchSourceBalance(let moneyValue):
                if state.sourceBalance?.currency.code != moneyValue?.currency.cryptoCurrency?.code {
                    state.sourceBalance = moneyValue

                    if let moneyValue = moneyValue {
                        state.isEnteringFiat = true
                        onAmountChanged(moneyValue)
//                        transactionModel.process(action: .fetchPrice(amount: moneyValue))
                    }

                    return EffectTask(value: .resetInput(newInput: nil))
                }

                return .none

            case .binding(\.$exchangeRate):
                return .none

            case .onSelectSourceTapped:
                return .run { _ in
                    app.post(event: blockchain.ux.transaction.select.source.entry, context: [
                        blockchain.ux.transaction.select.source.is.first.in.flow: false
                    ])
                }

            case .onMinMaxAmountsFetched(let minMaxValues):
                state.transactionMinMaxValues = minMaxValues
                return .none

            case .onPreviewTapped:
                if let amountEntered = state.amountCryptoEntered {
                    onPreviewTapped(amountEntered)
                }
//                transactionModel.process(action: .prepareTransaction)
                return .none

            case .onChangeInputTapped:
                let inputToFill = state.secondaryFieldText
                state.isEnteringFiat.toggle()
                app.state.set(blockchain.ux.transaction.enter.amount.active.input,
                              to: state.isEnteringFiat ?
                              blockchain.ux.transaction.enter.amount.active.input.crypto[] : blockchain.ux.transaction.enter.amount.active.input.fiat[]
                )

                if state.amountCryptoEntered?.isNotZero == true {
                    return EffectTask(value: .resetInput(newInput: inputToFill))
                } else {
                    return EffectTask(value: .resetInput(newInput: nil))
                }

            case .resetInput(let input):
                let precision = state.isEnteringFiat ? state.defaultFiatCurrency?.precision : state.source?.precision
                if state.rawInput.precision == precision {
                    state.rawInput.reset()
                } else {
                    state.rawInput = CurrencyInputFormatter(precision: precision ?? 8)
                }

                if let input {
                    state.rawInput.reset(to: input)
                }
                return .none

            case .onInputChanged(let text):
                if text.isNotEmpty {
                    state.rawInput.append(Character(text))
                }

                if let currentEnteredMoneyValue = state.amountCryptoEntered {
                    onAmountChanged(currentEnteredMoneyValue)
//                    transactionModel.process(action: .fetchPrice(amount: currentEnteredMoneyValue))
//                    app.post(value: state.amountCryptoEntered?.minorString, of: blockchain.ux.transaction.enter.amount.input.value)
                }

                if let amountCryptoEntered = state.amountCryptoEntered {
//                    transactionModel.process(action: .updateAmount(amountCryptoEntered))
//                    app.state.set(
//                        blockchain.ux.transaction.enter.amount.output.value,
//                        to: amountCryptoEntered.displayMajorValue.doubleValue
//                    )
                }
                return .none

            case .onBackspace:
                state.rawInput.backspace()
                return .fireAndForget { [state] in
                    if let amount = state.amountCryptoEntered {
                        onAmountChanged(amount)
//                        transactionModel.process(action: .updateAmount(amount))
                    }
                }

            case .prefillButtonAction(let action):
                switch action {
                case .select(let moneyValue, let size):
                    state.isEnteringFiat = false
                    state.amountCryptoEntered = size == .max ? state.transactionMinMaxValues?.maxSpendableCryptoValue : moneyValue.moneyValue.toCryptoAmount(currency: state.source, cryptoPrice: state.exchangeRate?.quote)

                    if let amountCryptoEntered = state.amountCryptoEntered {
                        onAmountChanged(amountCryptoEntered)
//                        transactionModel.process(action: .updateAmount(amountCryptoEntered))
                    }

                    app.state.set(
                        blockchain.ux.transaction.enter.amount.output.value,
                        to: moneyValue.displayMajorValue.doubleValue
                    )

                    return EffectTask(value: .resetInput(newInput: state.amountCryptoEntered?.toDisplayString(includeSymbol: false)))

                default:
                    return .none
                }

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
