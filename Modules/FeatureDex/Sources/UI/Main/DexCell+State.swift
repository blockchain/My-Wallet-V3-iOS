// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import MoneyKit

extension DexCell {
    init(
        _ value: DexMain.State.Source,
        defaultFiatCurrency: FiatCurrency,
        didTapCurrency: @escaping () -> Void,
        didTapBalance: @escaping () -> Void
    ) {
        self.init(
            amount: value.amount,
            amountFiat: value.amountFiat,
            balance: value.balance,
            isMaxEnabled: true,
            defaultFiatCurrency: defaultFiatCurrency,
            didTapCurrency: didTapCurrency,
            didTapBalance: didTapBalance
        )
    }

    init(
        _ value: DexMain.State.Destination?,
        defaultFiatCurrency: FiatCurrency,
        didTapCurrency: @escaping () -> Void
    ) {
        self.init(
            amount: value?.amount,
            amountFiat: value?.amountFiat,
            balance: value?.balance,
            isMaxEnabled: false,
            defaultFiatCurrency: defaultFiatCurrency,
            didTapCurrency: didTapCurrency,
            didTapBalance: {}
        )
    }
}
