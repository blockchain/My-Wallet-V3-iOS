// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Blockchain
import ComposableArchitecture
import DIKit
import FeatureTransactionDomain
import Foundation
import Localization
import MoneyKit
import PlatformKit
import AnalyticsKit
import DIKit
import Combine

public struct SwapEnterAmount: ReducerProtocol {
    var defaultSwapPairsService: DefaultSwapCurrencyPairsServiceAPI
    var app: AppProtocol
    public var dismiss: () -> Void
    public var onAmountChanged: (MoneyValue) -> Void
    public var onPairsSelected: (String, String, MoneyValue?) -> Void
    public var onPreviewTapped: (MoneyValue) -> Void
    public var minMaxAmountsPublisher: AnyPublisher<TransactionMinMaxValues,Never>

    public init(
        app: AppProtocol,
        defaultSwaptPairsService: DefaultSwapCurrencyPairsServiceAPI,
        minMaxAmountsPublisher: AnyPublisher<TransactionMinMaxValues,Never>,
        dismiss: @escaping () -> Void,
        onPairsSelected: @escaping (String, String, MoneyValue?) -> Void,
        onAmountChanged: @escaping (MoneyValue) -> Void,
        onPreviewTapped: @escaping (MoneyValue) -> Void
    ) {
        self.defaultSwapPairsService = defaultSwaptPairsService
        self.app = app
        self.dismiss = dismiss
        self.onAmountChanged = onAmountChanged
        self.minMaxAmountsPublisher = minMaxAmountsPublisher
        self.onPreviewTapped = onPreviewTapped
        self.onPairsSelected = onPairsSelected
    }

    // MARK: - State

    public struct State: Equatable {
        @BindingState var sourceInformation: SelectionInformation?
        @BindingState var targetInformation: SelectionInformation?
        @BindingState var showAccountSelect: Bool = false
        @BindingState var sourceBalance: MoneyValue?
        @BindingState var sourceValuePrice: MoneyValue?
        @BindingState var defaultFiatCurrency: FiatCurrency?
        var transactionMinMaxValues: TransactionMinMaxValues?
        var isEnteringFiat: Bool = true
        var selectFromCryptoAccountState: SwapFromAccountSelect.State?
        var selectToCryptoAccountState: SwapToAccountSelect.State?
        var input = CurrencyInputFormatter() {
            didSet {
                updateAmounts()
            }
        }

        public init(
            sourceInformation: SelectionInformation? = nil,
            targetInformation: SelectionInformation? = nil
        ) {
            self.sourceInformation = sourceInformation
            self.targetInformation = targetInformation
        }

        var previewButtonDisabled: Bool {
            guard sourceInformation != nil, targetInformation != nil, let amountCryptoEntered else {
                return true
            }
            return amountCryptoEntered.isZero
        }

        var transactionDetails: (forbidden: Bool, ctaLabel: String) {
            guard let maxAmountToSwap,
                  let currentEnteredMoneyValue = amountCryptoEntered,
                  currentEnteredMoneyValue.isZero == false,
                  sourceInformation != nil, targetInformation != nil
            else {
                return (forbidden: false, ctaLabel: LocalizationConstants.Swap.previewSwap)
            }

            if let minAmountToSwap = minAmountToSwap,
               (try? currentEnteredMoneyValue < minAmountToSwap) ?? false {

                let displayString = isEnteringFiat ? transactionMinMaxValues?.minSpendableFiatValue.toDisplayString(includeSymbol: true) :
                transactionMinMaxValues?.minSpendableCryptoValue.toDisplayString(includeSymbol: true)

                return (
                    forbidden: true,
                    ctaLabel: String.localizedStringWithFormat(
                        LocalizationConstants.Swap.belowMinimumLimitCTA,
                        displayString ?? ""
                    )
                )
            }

            if (try? currentEnteredMoneyValue > maxAmountToSwap) ?? false {
                return (
                    forbidden: true,
                    ctaLabel: String.localizedStringWithFormat(
                        LocalizationConstants.Swap.notEnoughCoin,
                        sourceInformation?.currency.code ?? ""
                    )
                )
            }

            return (forbidden: false, ctaLabel: LocalizationConstants.Swap.previewSwap)
        }

        var mainFieldText: String {
            if isEnteringFiat {
                return [defaultFiatCurrency?.displaySymbol, input.suggestion].compacted().joined(separator: " ")
            } else {
                return [input.suggestion, sourceInformation?.currency.displayCode].compacted().joined(separator: " ")
            }
        }

        var projectedFiatValue: MoneyValue? {
            return amountCryptoEntered?
                .cryptoValue?
                .toFiatAmount(with: sourceValuePrice)?
                .moneyValue
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
            guard let currency = sourceInformation?.currency else {
                return ""
            }
            return CryptoValue(storeAmount: 0, currency: currency).toDisplayString(includeSymbol: true)
        }

        var maxAmountToSwapLabel: String? {
            guard sourceInformation != nil && targetInformation != nil else {
                return nil
            }
            let value = isEnteringFiat ? transactionMinMaxValues?.maxSpendableFiatValue : transactionMinMaxValues?.maxSpendableCryptoValue
            return value?.toDisplayString(includeSymbol: true)
        }

        var maxAmountToSwap: MoneyValue? {
            transactionMinMaxValues?.maxSpendableCryptoValue
        }

        var minAmountToSwap: MoneyValue? {
            transactionMinMaxValues?.minSpendableCryptoValue
        }

        var currentEnteredMoneyValue: MoneyValue? {
            if isEnteringFiat {
                return projectedFiatValue
            } else {
                return amountCryptoEntered
            }
        }

        var amountCryptoEntered: MoneyValue?

        mutating func updateAmounts() {
            guard let currency = defaultFiatCurrency else { return }
            guard let sourceCurrency = sourceInformation?.currency.currencyType.cryptoCurrency else { return }
            if isEnteringFiat {
                let fiatAmount = MoneyValue.create(major: input.suggestion, currency: currency.currencyType)
                amountCryptoEntered = fiatAmount?.toCryptoAmount(currency: sourceCurrency, cryptoPrice: sourceValuePrice)
            } else {
                amountCryptoEntered = MoneyValue.create(majorDisplay: input.suggestion, currency: sourceCurrency.currencyType)
            }
        }
    }

    // MARK: - Action

    public enum Action: BindableAction {
        case onAppear
        case didFetchPairs(SelectionInformation, SelectionInformation)
        case didFetchSourceBalance(MoneyValue?)
        case onPreviewTapped
        case onChangeInputTapped
        case onMaxButtonTapped
        case binding(BindingAction<SwapEnterAmount.State>)
        case onSelectFromCryptoAccountAction(SwapFromAccountSelect.Action)
        case onSelectToCryptoAccountAction(SwapToAccountSelect.Action)
        case onSelectSourceTapped
        case onSelectTargetTapped
        case updateSourceBalance
        case resetTarget
        case checkTarget
        case onCloseTapped
        case onInputChanged(String)
        case onBackspace
        case resetInput(newInput: String?)
        case onMinMaxAmountsFetched(TransactionMinMaxValues)
    }

    // MARK: - Reducer

    public var body: some ReducerProtocol<State, Action> {
        BindingReducer()

        Scope(state: \.self, action: /Action.self) {
            TransactionModelAdapterReducer(onPairsSelected: onPairsSelected,
                                           onPreviewTapped: onPreviewTapped)
        }

        Scope(state: \.self, action: /Action.self) {
            SwapEnterAmountAnalytics(app: app)
        }

        Reduce { state, action in
            switch action {
            case .onAppear:
                return .merge(
                    minMaxAmountsPublisher
                        .eraseToEffect()
                        .map(Action.onMinMaxAmountsFetched),

                        .run { [sourceInformation = state.sourceInformation, targetInformation = state.targetInformation] send in
                            guard targetInformation == nil else {
                                return
                            }
                            if let pairs = await defaultSwapPairsService.getDefaultPairs(sourceInformation: sourceInformation) {
                                await send(.didFetchPairs(pairs.0, pairs.1))
                                await send(.updateSourceBalance)
                            }
                        }
                )

            case .didFetchSourceBalance(let moneyValue):
                state.sourceBalance = moneyValue
                return .none

            case .updateSourceBalance:
                let sourceCurrencyCode = state.sourceInformation?.currency.code
                return .run { send in
                    let appMode = await app.mode()
                    switch appMode {
                    case .pkw:
                        let balance = try? await app.get(blockchain.user.pkw.asset[sourceCurrencyCode].balance, as: MoneyValue.self)
                        await send(.didFetchSourceBalance(balance))
                    case .trading, .universal:
                        let balance = try? await app.get(blockchain.user.trading.account[sourceCurrencyCode].balance.available, as: MoneyValue.self)
                        await send(.didFetchSourceBalance(balance))
                    }
                }

            case .didFetchPairs(let sourcePair, let targetPair):
                return .merge(
                    EffectTask(value: .binding(.set(\.$sourceInformation, sourcePair))),
                    EffectTask(value: .binding(.set(\.$targetInformation, targetPair))),
                    EffectTask(value: .resetInput(newInput: nil))
                )

            case .onInputChanged(let text):
                if text.isNotEmpty {
                    state.input.append(Character(text))
                }
                return .fireAndForget { [state] in
                    if let amount = state.amountCryptoEntered {
                        onAmountChanged(amount)
                    }
                }

            case .onBackspace:
                state.input.backspace()
                return .none

            case .onChangeInputTapped:
                let inputToFill = state.secondaryFieldText
                state.isEnteringFiat.toggle()
                if state.amountCryptoEntered?.isNotZero == true {
                    return EffectTask(value: .resetInput(newInput: inputToFill))
                } else {
                    return EffectTask(value: .resetInput(newInput: nil))
                }

            case .checkTarget:
                return .run { [source = state.sourceInformation?.currency, target = state.targetInformation?.currency] send in
                    if let tradingPairs = try? await app.get(blockchain.api.nabu.gateway.trading.swap.pairs, as: [TradingPair].self),
                       tradingPairs.filter({ $0.sourceCurrencyType.code == source?.code && $0.destinationCurrencyType.code == target?.code }).isEmpty {
                        await send(.resetTarget)
                    }
                }

            case .resetTarget:
                state.targetInformation = nil
                return .none

            case .onMaxButtonTapped:
                guard let minMax = state.transactionMinMaxValues else { return .none }
                let max = minMax.maxSpendableCryptoValue
                state.isEnteringFiat = false
                state.amountCryptoEntered = max
                return EffectTask(value: .resetInput(newInput: max.toDisplayString(includeSymbol: false)))

            case .onSelectSourceTapped:
                state.selectFromCryptoAccountState = SwapFromAccountSelect.State(appMode: app.currentMode)
                state.showAccountSelect.toggle()
                return .none

            case .onSelectTargetTapped:
                state.selectToCryptoAccountState = SwapToAccountSelect.State(
                    selectedSourceCrypto: state.sourceInformation?.currency,
                    appMode: app.currentMode
                )
                state.showAccountSelect.toggle()
                return .none

            case .binding(\.$showAccountSelect):
                if state.showAccountSelect == false {
                    state.selectFromCryptoAccountState = nil
                    state.selectToCryptoAccountState = nil
                }
                return .none

            case .binding:
                return .none

            case .onPreviewTapped:
                if let finalAmount = state.amountCryptoEntered {
                    onPreviewTapped(finalAmount)
                }
                return .none

            case .onCloseTapped:
                dismiss()
                return .none

            case .onSelectFromCryptoAccountAction(let action):
                switch action {
                case .onCloseTapped:
                    state.showAccountSelect = false
                    return .none

                case .accountRow(let id, let action):
                    guard action == .onAccountSelected else { return .none }
                    if let selectedAccountRow = state.selectFromCryptoAccountState?.swapAccountRows.filter({ $0.id == id }).first,
                       let currency = selectedAccountRow.currency
                    {
                        let sourceInformation = SelectionInformation (
                            accountId: id,
                            currency: currency
                        )
                        state.showAccountSelect.toggle()

                        return .merge(
                            currency == state.targetInformation?.currency ? EffectTask(value: .resetTarget) : .none,
                            EffectTask(value: .binding(.set(\.$sourceInformation, sourceInformation))),
                            EffectTask(value: .updateSourceBalance),
                            EffectTask(value: .checkTarget),
                            EffectTask(value: .resetInput(newInput: nil))
                        )
                    }
                    return .none
                default:
                    return .none
                }

            case .onSelectToCryptoAccountAction(let action):
                switch action {
                case .onCloseTapped:
                    state.showAccountSelect = false
                    return .none

                case .accountRow(_, .onAccountSelected(let accountId)):
                    state.showAccountSelect.toggle()
                    return .run { send in
                        if let currency = try? await app.get(blockchain.coin.core.account[accountId].currency, as: CryptoCurrency.self) {
                            await send(.binding(.set(\.$targetInformation, SelectionInformation(accountId: accountId, currency: currency))))
                        }
                    }

                case .accountRow:
                    return .none

                default:
                    return .none
                }

            case .onMinMaxAmountsFetched(let minMaxValues):
                state.transactionMinMaxValues = minMaxValues
                return .none


            case .resetInput(let input):
                let precision = state.isEnteringFiat ? state.defaultFiatCurrency?.precision : state.sourceInformation?.currency.precision
                if state.input.precision == precision {
                    state.input.reset()
                } else {
                    state.input = CurrencyInputFormatter(precision: precision ?? 8)
                }

                if let input {
                    state.input.reset(to: input)
                }
                return .none
            }
            
        }
        .ifLet(\.selectFromCryptoAccountState, action: /Action.onSelectFromCryptoAccountAction, then: {
            SwapFromAccountSelect(app: app,
                                  supportedPairsInteractorService: resolve())
        })
        .ifLet(\.selectToCryptoAccountState, action: /Action.onSelectToCryptoAccountAction, then: {
            SwapToAccountSelect(app: app)
        })
    }
}

struct TransactionModelAdapterReducer: ReducerProtocol {
    public typealias State = SwapEnterAmount.State
    public typealias Action = SwapEnterAmount.Action

    public var onPairsSelected: (String, String, MoneyValue?) -> Void
    public var onPreviewTapped: (MoneyValue) -> Void

    public var body: some ReducerProtocol<State,Action> {
        Reduce { state, action  in
            switch action {
            case .onAppear:
                return .none

            case .binding(\.$sourceInformation), .binding(\.$targetInformation):
                if let sourceAccountId = state.sourceInformation?.accountId,
                   let targetAccountId = state.targetInformation?.accountId
                {
                    onPairsSelected(sourceAccountId, targetAccountId, state.amountCryptoEntered)
                }


                return .none

            case .onPreviewTapped:
                if let finalAmount = state.amountCryptoEntered {
                    onPreviewTapped(finalAmount)
                }
                return .none

            default:
                return .none
            }
        }
    }
}

extension CryptoValue {
    func toFiatAmount(with sourceValuePrice: MoneyValue?) -> FiatValue? {
        guard let sourceValuePrice else {
            return nil
        }
        let moneyValuePair = MoneyValuePair(
            base: .one(currency: currency),
            quote: sourceValuePrice
        )
        return try? moneyValue
            .convert(using: moneyValuePair)
            .displayableRounding(roundingMode: .up)
            .fiatValue
    }
}
