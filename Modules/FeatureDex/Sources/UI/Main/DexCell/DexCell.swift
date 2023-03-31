// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainComponentLibrary
import BlockchainNamespace
import Combine
import ComposableArchitecture
import DelegatedSelfCustodyDomain
import Foundation
import Localization
import MoneyKit
import SwiftUI

@available(iOS 15, *)
public struct DexCell: ReducerProtocol {

    let app: AppProtocol
    let balances: () -> AnyPublisher<DelegatedCustodyBalances, Error>

    public var body: some ReducerProtocol<State, Action> {
        BindingReducer()
        Reduce { state, action in
            switch action {
            case .onAppear:
                if state.balance == nil, state.style == .source, state.availableBalances.isNotEmpty {
                    return EffectTask(value: .preselectCurrency)
                }
                return .none
            case .onTapBalance:
                return .none
            case .onTapCurrencySelector:
                return .none
            case .preselectCurrency:
                if state.balance == nil, state.style == .source, let first = state.availableBalances.first {
                    return EffectTask(value: .didSelectCurrency(first))
                }
                return .none
            case .didSelectCurrency(let balance):
                state.amount = nil
                state.price = nil
                state.balance = balance
                return .none
            case .binding:
                return .none
            }
        }
    }
}

@available(iOS 15, *)
extension DexCell {

    public struct State: Equatable {

        public typealias Balance = DexMain.State.Balance

        public enum Style {
            case source
            case destination
        }

        let style: Style
        @BindingState var availableBalances: [Balance]
        var supportedTokens: [CryptoCurrency]
        var amount: CryptoValue?
        var balance: Balance?
        @BindingState var price: MoneyValue?
        @BindingState var defaultFiatCurrency: FiatCurrency?

        public init(
            style: DexCell.State.Style,
            availableBalances: [Balance] = [],
            supportedTokens: [CryptoCurrency] = [],
            amount: CryptoValue? = nil,
            balance: Balance? = nil,
            price: MoneyValue? = nil,
            defaultFiatCurrency: FiatCurrency? = nil
        ) {
            self.style = style
            self.availableBalances = availableBalances
            self.supportedTokens = supportedTokens
            self.amount = amount
            self.balance = balance
            self.price = price
            self.defaultFiatCurrency = defaultFiatCurrency
        }

        var currency: CryptoCurrency? {
            balance?.currency
        }

        var isMaxEnabled: Bool {
            style == .source
        }

        var amountFiat: FiatValue? {
            guard let price, let amount else {
                return defaultFiatCurrency.flatMap(FiatValue.zero(currency:))
            }
            let moneyValuePair = MoneyValuePair(
                base: .one(currency: amount.currency),
                quote: price
            )
            return try? amount
                .moneyValue
                .convert(using: moneyValuePair)
                .fiatValue
        }
    }
}

@available(iOS 15, *)
extension DexCell {
    public enum Action: BindableAction, Equatable {
        case onAppear
        case binding(BindingAction<State>)
        case preselectCurrency
        case didSelectCurrency(State.Balance)
        case onTapBalance
        case onTapCurrencySelector
    }
}
