// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import ComposableArchitecture
import MoneyKit
import SwiftUI

extension DexConfirmation {
    public struct State: Hashable {
        var quote: Quote
        var newQuote: Quote?
        var priceUpdated: Bool { newQuote != nil }
        @BindingState var didConfirm: Bool = false
        @BindingState var pendingTransaction: PendingTransaction.State?
        @BindingState var fromFiatExchangeRate: MoneyValue?
        @BindingState var toFiatExchangeRate: MoneyValue?
    }
}

extension DexConfirmation.State {
    public struct Quote: Hashable {
        var enoughBalance: Bool
        var from: Target
        var minimumReceivedAmount: CryptoValue
        var networkFee: CryptoValue
        var productFee: CryptoValue
        var slippage: Double
        var to: Target
        var exchangeRate: MoneyValuePair {
            MoneyValuePair(base: from.value.moneyValue, quote: to.value.moneyValue).exchangeRate
        }
    }

    struct Target: Hashable {
        var value: CryptoValue
        var currency: CryptoCurrency { value.currency }
    }
}

extension DexConfirmation.State.Quote {
    static var preview: DexConfirmation.State.Quote {
        DexConfirmation.State.Quote(
            enoughBalance: true,
            from: DexConfirmation.State.Target(value: CryptoValue.create(major: 0.05, currency: .ethereum)),
            minimumReceivedAmount: CryptoValue.create(major: 61.92, currency: .bitcoin),
            networkFee: CryptoValue.create(major: 0.005, currency: .ethereum),
            productFee: CryptoValue.create(major: 1.2, currency: .bitcoin),
            slippage: 0.0013,
            to: DexConfirmation.State.Target(value: .create(major: 62.23, currency: .bitcoin))
        )
    }
}

extension DexConfirmation.State {

    static var preview: DexConfirmation.State = DexConfirmation.State(
        quote: .preview
    )
}
