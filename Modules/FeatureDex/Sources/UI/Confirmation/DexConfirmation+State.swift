// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import ComposableArchitecture
import MoneyKit
import SwiftUI

extension DexConfirmation {
    public struct State: Hashable {
        struct Target: Hashable {
            var value: CryptoValue
            @BindingState var toFiatExchangeRate: MoneyValue?
            var currency: CryptoCurrency { value.currency }
        }

        struct Fee: Hashable {
            var network: CryptoValue
            var product: CryptoValue
        }

        var enoughBalance: Bool = true
        var fee: Fee
        var from: Target
        var minimumReceivedAmount: CryptoValue
        var priceUpdated: Bool = false
        var slippage: Double
        var to: Target
        @BindingState var didConfirm: Bool = false
        @BindingState var pendingTransaction: PendingTransaction.State? = nil

        var exchangeRate: MoneyValuePair {
            MoneyValuePair(base: from.value.moneyValue, quote: to.value.moneyValue).exchangeRate
        }
    }
}

extension DexConfirmation.State {

    static var preview: Self = .init(
        fee: .init(
            network: .create(major: 0.005, currency: .ethereum),
            product: .create(major: 1.2, currency: .bitcoin)
        ),
        from: .init(value: .create(major: 0.05, currency: .ethereum)),
        minimumReceivedAmount: CryptoValue.create(major: 61.92, currency: .bitcoin),
        slippage: 0.0013,
        to: .init(value: .create(major: 62.23, currency: .bitcoin))
    )
}
