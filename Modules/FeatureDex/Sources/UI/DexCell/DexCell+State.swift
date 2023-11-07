// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainUI
import DelegatedSelfCustodyDomain
import FeatureDexDomain

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

        var parentNetwork: EVMNetwork?

        let style: Style
        var overrideAmount: CryptoValue?
        var currentNetwork: EVMNetwork?
        var supportedTokens: [CryptoCurrency]
        var bannedToken: CryptoCurrency?
        var balance: DexBalance?
        @BindingState var textFieldIsFocused: Bool = false
        @BindingState var isCurrentInput: Bool = false
        @BindingState var quoteByOutputEnabled: Bool = false
        @BindingState var crossChainEnabled: Bool = false

        var textFieldDisabled: Bool {
            style.isDestination && quoteByOutputEnabled.isNo
        }

        var networkPickerDisabled: Bool {
            style.isDestination && crossChainEnabled.isNo
        }

        var availableBalances: [DexBalance]
        var filteredBalances: [DexBalance] {
            guard let currentNetwork else { return [] }
            return availableBalances
                .filter { $0.network == currentNetwork }
        }

        var price: FiatValue?
        @BindingState var defaultFiatCurrency: FiatCurrency?
        @BindingState var inputText: String = ""

        var assetPicker: AssetPicker.State?
        @BindingState var showAssetPicker: Bool = false
        var networkPicker: NetworkPicker.State?
        @BindingState var showNetworkPicker: Bool = false

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
            overrideAmount ?? inputAmount
        }

        var inputAmountIsPositive: Bool {
            inputAmount?.isPositive ?? false
        }

        private var inputAmount: CryptoValue? {
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
