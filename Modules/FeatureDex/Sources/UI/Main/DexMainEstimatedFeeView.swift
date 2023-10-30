// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainUI
import FeatureDexData
import FeatureDexDomain
import SwiftUI

struct DexMainEstimatedFeeView: View {

    let isFetching: Bool
    let value: CryptoValue?
    @State var defaultFiatCurrency: FiatCurrency?
    @State var exchangeRate: MoneyValue?

    var body: some View {
        HStack {
            HStack {
                estimatedFeeIcon
                estimatedFeeTitle
            }
            Spacer()
            estimatedFeeLabel
        }
        .padding(Spacing.padding2)
        .background(Color.semantic.background)
        .cornerRadius(Spacing.padding2)
        .bindings {
            subscribe(
                $defaultFiatCurrency,
                to: blockchain.user.currency.preferred.fiat.trading.currency
            )
        }
        .bindings {
            subscribe(
                $exchangeRate,
                to: blockchain.api.nabu.gateway.price.crypto[value?.code].fiat.quote.value
            )
        }
    }

    private var estimatedFeeString: String {
        guard let value else {
            return defaultFiatCurrency
                .flatMap(FiatValue.zero(currency:))?
                .displayString ?? ""
        }
        guard let exchangeRate else {
            return value.displayString
        }
        return value.convert(using: exchangeRate).displayString
    }

    @ViewBuilder
    private var estimatedFeeIcon: some View {
        if isFetching {
            ProgressView()
                .progressViewStyle(.indeterminate)
                .frame(width: 16.pt, height: 16.pt)
        } else {
            Icon.gas
                .color(.semantic.title)
                .micro()
        }
    }

    @ViewBuilder
    private var estimatedFeeLabel: some View {
        if isFetching.isNo {
            Text("~ \(estimatedFeeString)")
                .typography(.paragraph2)
                .foregroundColor(
                    value.isNil ? .semantic.body : .semantic.title
                )
        }
    }

    @ViewBuilder
    private var estimatedFeeTitle: some View {
        if isFetching {
            Text(L10n.Main.fetchingPrice)
                .typography(.paragraph2)
                .foregroundColor(.semantic.title)
        } else {
            Text(L10n.Main.estimatedFee)
                .typography(.paragraph2)
                .foregroundColor(.semantic.title)
        }
    }
}
