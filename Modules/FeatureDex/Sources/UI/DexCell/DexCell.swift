// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainComponentLibrary
import BlockchainNamespace
import Combine
import ComposableArchitecture
import DelegatedSelfCustodyDomain
import FeatureDexDomain
import Foundation
import MoneyKit
import SwiftUI

public struct DexCell: ReducerProtocol {

    public var body: some ReducerProtocol<State, Action> {
        BindingReducer()
        Reduce { state, action in
            switch action {
            case .binding(\.$inputText):
                print("binding(inputText): \(state.inputText)")
                return .none
            case .onAppear:
                if state.balance == nil, state.style == .source, state.availableBalances.isNotEmpty {
                    return EffectTask(value: .preselectCurrency)
                }
                return .none
            case .onTapBalance:
                return .none
            case .onTapCurrencySelector:
                state.assetPicker = .init(
                    balances: state.availableBalances,
                    tokens: state.supportedTokens
                )
                state.showAssetPicker = true
                return .none
            case .preselectCurrency:
                if state.balance == nil, state.style == .source, let first = state.availableBalances.first {
                    return EffectTask(value: .didSelectCurrency(first))
                }
                return .none
            case .didSelectCurrency(let balance):
                print("didSelectCurrency")
                state.balance = balance
                state.price = nil
                state.inputText = ""
                return .none
            case .assetPicker(.onDismiss):
                state.showAssetPicker = false
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
        var supportedTokens: [CryptoCurrency]
        var balance: DexBalance?
        @BindingState var price: FiatValue?
        @BindingState var defaultFiatCurrency: FiatCurrency?
        @BindingState var inputText: String = ""

        var assetPicker: AssetPicker.State = .init(balances: [], tokens: [])
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
            style.isSource
        }

        var amount: CryptoValue? {
            if let overrideAmount {
                return overrideAmount
            }
            guard let currency = balance?.currency else {
                print("amount: no balance.currency")
                return nil
            }
            guard inputText.isNotEmpty else {
                print("amount: input text is empty")
                return nil
            }
            return CryptoValue.create(
                majorDisplay: inputText,
                currency: currency
            )
        }

        var amountFiat: FiatValue? {
            guard let price else {
                print("amountFiat: no price")
                return defaultFiatCurrency.flatMap(FiatValue.zero(currency:))
            }
            guard let amount else {
                print("amountFiat: no amount")
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
