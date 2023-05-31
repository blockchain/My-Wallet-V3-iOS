// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainUI
import DelegatedSelfCustodyDomain
import FeatureDexDomain

public struct DexCell: ReducerProtocol {

    public var body: some ReducerProtocol<State, Action> {
        BindingReducer()
        Reduce { state, action in
            switch action {
            case .binding(\.$inputText):
                return .none
            case .onAppear:
                if state.balance == nil, state.style == .source, state.availableBalances.isNotEmpty {
                    return EffectTask(value: .preselectCurrency)
                }
                return .none
            case .onTapBalance:
                if let balance = state.balance {
                    state.inputText = balance.value.toDisplayString(includeSymbol: false)
                }
                return .none
            case .onTapCurrencySelector:
                state.assetPicker = AssetPicker.State(
                    balances: state.availableBalances,
                    tokens: state.supportedTokens,
                    denylist: state.bannedToken.flatMap { [$0] } ?? [],
                    currentNetwork: state.currentNetwork! // TODO: @audrea
                    searchText: "",
                    isSearching: false
                )
                state.showAssetPicker = true
                return .none
            case .preselectCurrency:
                // TODO: @audrea will depend on currentNetwork, default to native currency if balance for it is available, else use the first of the balances array.
                if state.balance == nil, state.style == .source, let first = state.availableBalances.first {
                    return EffectTask(value: .didSelectCurrency(first))
                }
                return .none
            case .didSelectCurrency(let balance):
                state.balance = balance
                state.price = nil
                state.inputText = ""
                return .none
            case .assetPicker(.onDismiss):
                state.showAssetPicker = false
                state.assetPicker = nil
                return .none
            case .assetPicker(.onAssetTapped(let row)):
                state.showAssetPicker = false

                let dexBalance: DexBalance = {
                    switch row.content {
                    case .balance(let dexBalance):
                        return dexBalance
                    case .token(let cryptoCurrency):
                        return DexBalance(value: .zero(currency: cryptoCurrency))
                    }
                }()

                return EffectTask(value: .didSelectCurrency(dexBalance))
            case .assetPicker:
                return .none
            case .binding:
                return .none
            }
        }
        .ifLet(\.assetPicker, action: /Action.assetPicker) {
            AssetPicker()
        }
    }
}

extension DexCell {

    public struct State: Equatable {

        public enum Style {
            case source
            case destination

            var isSource: Bool {
                self == .source
            }

            var isDestination: Bool {
                self == .destination
            }
        }

        let style: Style
        var overrideAmount: CryptoValue?
        @BindingState var availableBalances: [DexBalance]
        var currentNetwork: EVMNetwork? = nil
        var supportedTokens: [CryptoCurrency]
        var bannedToken: CryptoCurrency?
        var balance: DexBalance?
        @BindingState var price: FiatValue?
        @BindingState var defaultFiatCurrency: FiatCurrency?
        @BindingState var inputText: String = ""

        var assetPicker: AssetPicker.State?
        @BindingState var showAssetPicker: Bool = false

        public init(
            style: DexCell.State.Style,
            availableBalances: [DexBalance] = [],
            supportedTokens: [CryptoCurrency] = []
        ) {
            self.style = style
            self.availableBalances = availableBalances
            self.supportedTokens = supportedTokens
        }

        var currency: CryptoCurrency? {
            balance?.currency
        }

        var isMaxEnabled: Bool {
            style.isSource && currency?.isERC20 == true
        }

        var amount: CryptoValue? {
            if let overrideAmount {
                return overrideAmount
            }
            guard let currency = balance?.currency else {
                return nil
            }
            guard inputText.isNotEmpty else {
                return nil
            }
            return CryptoValue.create(
                majorDisplay: inputText,
                currency: currency
            )
        }

        var amountFiat: FiatValue? {
            guard let price else {
                return defaultFiatCurrency.flatMap(FiatValue.zero(currency:))
            }
            guard let amount else {
                return defaultFiatCurrency.flatMap(FiatValue.zero(currency:))
            }
            let moneyValuePair = MoneyValuePair(
                base: .one(currency: amount.currency),
                quote: price.moneyValue
            )
            return try? amount
                .moneyValue
                .convert(using: moneyValuePair)
                .fiatValue
        }
    }
}

extension DexCell {
    public enum Action: BindableAction, Equatable {
        case onAppear
        case binding(BindingAction<State>)
        case preselectCurrency
        case didSelectCurrency(DexBalance)
        case onTapBalance
        case onTapCurrencySelector
        case assetPicker(AssetPicker.Action)
    }
}
