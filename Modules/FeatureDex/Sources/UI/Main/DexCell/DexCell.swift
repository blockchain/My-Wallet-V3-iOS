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
                state.amount = nil
                state.price = nil
                state.balance = balance
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

@available(iOS 15, *)
extension DexCell {

    public struct State: Equatable {

        public enum Style {
            case source
            case destination
        }

        let style: Style
        @BindingState var availableBalances: [DexBalance]
        var supportedTokens: [CryptoCurrency]
        var amount: CryptoValue?
        var balance: DexBalance?
        @BindingState var price: FiatValue?
        @BindingState var defaultFiatCurrency: FiatCurrency?

        var assetPicker: AssetPicker.State = .init(balances: [], tokens: [])
        @BindingState var showAssetPicker: Bool = false

        public init(
            style: DexCell.State.Style,
            availableBalances: [DexBalance] = [],
            supportedTokens: [CryptoCurrency] = [],
            amount: CryptoValue? = nil,
            balance: DexBalance? = nil,
            price: FiatValue? = nil,
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
                quote: price.moneyValue
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
        case didSelectCurrency(DexBalance)
        case onTapBalance
        case onTapCurrencySelector
        case assetPicker(AssetPicker.Action)
    }
}
