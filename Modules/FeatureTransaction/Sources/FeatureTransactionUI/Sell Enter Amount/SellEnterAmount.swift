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

        var rawInput = CurrencyInputFormatter() {
            didSet {
                updateAmounts()
            }
        }
        @BindingState var showAccountSelect: Bool = false
        @BindingState var sourceBalance: MoneyValue?
        @BindingState var defaultFiatCurrency: FiatCurrency?
        @BindingState var exchangeRate: MoneyValuePair?
        var prefillButtonsState = PrefillButtons.State(action: .sell)

        public init() {}

        var previewButtonDisabled: Bool {
            finalSelectedMoneyValue == nil || finalSelectedMoneyValue?.isZero == true
        }

        var transactionDetails: (forbidden: Bool, ctaLabel: String) {
            guard let defaultFiatCurrency,
                  let maxAmountToSwap,
                  let currentEnteredMoneyValue = amountCryptoEntered,
                  currentEnteredMoneyValue.isZero == false,
                  let amountFiatEntered = projectedFiatValue?.fiatValue
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
            amountCryptoEntered
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
                print(amountCryptoEntered?.toDisplayString(includeSymbol: true) ?? "")
            } else {
                amountCryptoEntered = MoneyValue.create(majorDisplay: rawInput.suggestion, currency: sourceCurrency.currencyType)
            }
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
        case onBackspace
        case resetInput(newInput: String?)
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

                            if exchangeRate.base.isNotZero, exchangeRate.quote.isNotZero {
                                await send(.binding(.set(\.$exchangeRate, exchangeRate)))
                            }
                        } catch let error {
                            print(error.localizedDescription)
                            await send(.binding(.set(\.$exchangeRate, nil)))
                        }
                    }
                }

            case .onAppear:
                if let source = state.source {
                    let amount = state.amountCryptoEntered ?? .zero(currency: source)
                    transactionModel.process(action: .updateAmount(amount))
                }
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

            case .onSelectSourceTapped:
                return .run { _ in
                    app.post(event: blockchain.ux.transaction.select.source.entry, context: [
                        blockchain.ux.transaction.select.source.is.first.in.flow: false
                    ])
                }

            case .onPreviewTapped:
                transactionModel.process(action: .prepareTransaction)
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

            case .onBackspace:
                state.rawInput.backspace()
                return .fireAndForget { [state] in
                    if let amount = state.amountCryptoEntered {
                        transactionModel.process(action: .updateAmount(amount))
                    }
                }

            case .prefillButtonAction(let action):
                switch action {
                case .select(let moneyValue, let size):
                    state.isEnteringFiat = false
                    state.amountCryptoEntered = size == .max ? state.maxAmountToSwapCryptoValue : moneyValue.moneyValue.toCryptoAmount(currency: state.source, cryptoPrice: state.exchangeRate?.quote)

                    if let amountCryptoEntered = state.amountCryptoEntered {
                        state.rawInput.reset(to: amountCryptoEntered.toDisplayString(includeSymbol: false))
                        transactionModel.process(action: .updateAmount(amountCryptoEntered))
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
