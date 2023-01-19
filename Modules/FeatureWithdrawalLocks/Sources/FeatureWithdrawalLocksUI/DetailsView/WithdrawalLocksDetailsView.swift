// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainComponentLibrary
import FeatureWithdrawalLocksDomain
import Localization
import MoneyKit
import PlatformUIKit
import SwiftUI

private typealias LocalizationIds = LocalizationConstants.WithdrawalLocks

public struct WithdrawalLocksDetailsView: View {

    let withdrawalLocks: WithdrawalLocks

    public init(withdrawalLocks: WithdrawalLocks) {
        self.withdrawalLocks = withdrawalLocks
    }

    @Environment(\.presentationMode) private var presentationMode
    @Environment(\.openURL) private var openURL

    public var body: some View {
        ZStack(alignment: .top) {
            VStack {
                HStack {
                    Text(
                        String(
                            format: LocalizationIds.onHoldTitle,
                            withdrawalLocks.amount
                        )
                    )
                    .typography(.body2)
                    Spacer()
                    Button {
                        presentationMode.wrappedValue.dismiss()
                    } label: {
                        Icon.closeCircle
                            .color(.semantic.muted)
                            .frame(height: 24.pt)
                    }
                }
                .padding([.horizontal, .bottom])

                VStack(alignment: .leading, spacing: 4) {
                    Text(LocalizationIds.totalOnHoldTitle)
                    .typography(.caption2)
                    .frame(
                        maxWidth: .infinity,
                        alignment: .leading
                    )

                    Text(withdrawalLocks.amount)
                    .typography(.title3)
                    .frame(
                        maxWidth: .infinity,
                        alignment: .leading
                    )
                }.padding([.horizontal])

                if withdrawalLocks.items.isEmpty {
                    Spacer()

                    Text(LocalizationIds.noLocks)
                        .typography(.paragraph1)
                        .foregroundColor(.semantic.muted)
                        .padding()
                } else {
                    HStack {
                        Text(LocalizationIds.heldUntilTitle.uppercased())
                        Spacer()
                        Text(LocalizationIds.amountTitle.uppercased())
                    }
                    .padding(.top, Spacing.padding1)
                    .padding([.leading, .trailing])
                    .foregroundColor(.semantic.muted)
                    .typography(.overline)

                    PrimaryDivider()

                    ScrollView {
                        ForEach(withdrawalLocks.items) { item in
                            WithdrawalLockItemView(item: item)
                        }
                    }
                }

                Spacer()
                VStack(alignment: .leading, spacing: 16) {
                    Text(LocalizationIds.holdingPeriodDescription)
                    if !withdrawalLocks.items.isEmpty {
                        SmallMinimalButton(title: LocalizationConstants.WithdrawalLocks.learnMoreButtonTitle) {
                            openURL(Constants.withdrawalLocksSupportUrl)
                        }
                    }
                }
                .multilineTextAlignment(.leading)
                .typography(.caption1)
                .foregroundColor(.semantic.muted)
                .padding([.horizontal])
                .padding([.top], 3)
                .background(
                    Rectangle()
                        .fill(.white)
                        .backgroundWithWhiteShadow
                )

                Spacer()

                VStack(spacing: 16) {
                    MinimalButton(
                        title: LocalizationIds.contactSupportTitle
                    ) {
                        openURL(Constants.contactSupportUrl)
                    }
                    PrimaryButton(
                        title: LocalizationIds.okButtonTitle
                    ) {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
                .padding()
            }
        }
        .padding(.top, 24.pt)
        .navigationBarHidden(true)
    }
}

struct WithdrawalLockItemView: View {
    let item: WithdrawalLocks.Item

    var body: some View {
        HStack(spacing: 2) {
            HStack {
                if let boughtCryptoCurrency = item.boughtCryptoCurrency,
                   let boughtCryptoCurrencyType = try? CurrencyType(code: boughtCryptoCurrency)
                {
                    boughtCryptoCurrencyType.image
                        .resizable()
                        .frame(width: 26, height: 26)
                } else if let depositedCurrencyType = try? CurrencyType(code: item.amountCurrency) {
                    depositedCurrencyType
                        .image
                        .resizable()
                        .background(Color.semantic.fiatGreen)
                        .frame(width: 26, height: 26)
                        .cornerRadius(4)
                }
                VStack(alignment: .leading, spacing: 4) {
                    let title: String = {
                        if let boughtCryptoCurrency = item.boughtCryptoCurrency {
                            let boughtCryptoCurrencyType = try? CurrencyType(code: boughtCryptoCurrency)
                            return String(
                                format: LocalizationIds.boughtCryptoTitle,
                                boughtCryptoCurrencyType?.name ?? boughtCryptoCurrency
                            )
                        } else {
                            let depositedCurrencyType = try? CurrencyType(code: item.amountCurrency)
                            return String(
                                format: LocalizationIds.depositedTitle,
                                depositedCurrencyType?.name ?? item.amountCurrency
                            )
                        }
                    }()
                    Text(title)
                    Text(
                        String(
                            format: LocalizationIds.availableOnTitle,
                            item.date
                        )
                    )
                    .foregroundColor(.semantic.muted)
                }
            }
            Spacer()
            VStack(alignment: .trailing, spacing: 4) {
                Text(item.amount)
                if let boughtAmount = item.boughtAmount {
                    Text(boughtAmount)
                        .foregroundColor(.semantic.muted)
                }
            }
        }
        .foregroundColor(.semantic.body)
        .typography(.paragraph2)
        .frame(height: 44)
        .padding([.leading, .trailing])

        PrimaryDivider()
    }
}

// swiftlint:disable type_name
struct WithdrawalLockDetailsView_PreviewProvider: PreviewProvider {
    static var previews: some View {
        Group {
            WithdrawalLocksDetailsView(
                withdrawalLocks: .init(items: [], amount: "$0")
            )
            WithdrawalLocksDetailsView(
                withdrawalLocks: .init(items: [
                    .init(
                        date: "28 September, 2032",
                        amount: "$100",
                        amountCurrency: "USD",
                        boughtAmount: "0.0728476 ETH",
                        boughtCryptoCurrency: "ETH"
                    )
                ], amount: "$100")
            )
        }
    }
}
