// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainUI
import FeatureDexDomain
import SwiftUI

struct DexConfirmationTargetView: View {
    let value: CryptoValue
    let balance: DexBalance?
    @State var exchangeRate: MoneyValue?

    var body: some View {
        VStack(alignment: .center, spacing: 8) {
            HStack(alignment: .center, spacing: 8) {
                if let value = value.currency.network() {
                    pillButton(imageURL: value.logoURL, label: value.networkConfig.shortName)
                        .frame(maxWidth: .infinity)
                }
                pillButton(imageURL: value.currency.logoURL, label: value.currency.displayCode)
                    .frame(maxWidth: .infinity)
            }
            HStack(alignment: .center, spacing: 8) {
                Text(value.toDisplayString(includeSymbol: false))
                    .typography(.title2.slashedZero())
                    .foregroundColor(.semantic.title)
                    .lineLimit(1)
                    .minimumScaleFactor(0.1)
                Spacer()
            }
            HStack(alignment: .center, spacing: 0) {
                if let exchangeRate {
                    Text(value.convert(using: exchangeRate).displayString)
                        .typography(.body1)
                        .foregroundColor(.semantic.body)
                        .lineLimit(1)
                        .minimumScaleFactor(0.1)
                }
                Spacer()
                balanceLabel(balance)
            }
        }
        .padding([.leading, .trailing], 16)
        .padding([.top, .bottom], 18)
        .foregroundColor(.semantic.title)
        .background(Color.semantic.background)
        .cornerRadius(Spacing.padding2)
        .bindings {
            subscribe(
                $exchangeRate,
                to: blockchain.api.nabu.gateway.price.crypto[value.currency.code].fiat.quote.value
            )
        }
    }

    @ViewBuilder
    private func pillButton(
        imageURL: URL?,
        label: String
    ) -> some View {
        HStack(spacing: 8) {
            AsyncMedia(
                url: imageURL,
                placeholder: EmptyView.init
            )
            .frame(width: 24, height: 24)
            .padding(.leading, Spacing.padding1)
            .padding(.vertical, Spacing.textSpacing)
            Text(label)
                .typography(.caption2)
                .foregroundColor(.semantic.title)
            Spacer()
        }
        .background(Color.semantic.light)
        .cornerRadius(Spacing.padding3)
    }

    @ViewBuilder
    private func balancePill(_ currency: CryptoCurrency) -> some View {
        VStack(spacing: 4) {
            HStack {
                currency.logo(size: 16.pt)
                    .padding(.leading, 8.pt)
                    .padding(.vertical, 8.pt)
                Text(currency.displayCode)
                    .typography(.body1)
                    .foregroundColor(.semantic.title)
                    .padding(.trailing, 8.pt)
            }
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.semantic.light)
            )
        }
    }

    @ViewBuilder
    private func balanceLabel(_ balance: DexBalance?) -> some View {
        if let balance {
            HStack(spacing: 4) {
                Text(L10n.Main.balance)
                    .typography(.micro)
                    .foregroundColor(.semantic.body)
                Text(balance.value.displayString)
                    .typography(.micro)
                    .foregroundColor(.semantic.title)
            }
        }
    }
}

