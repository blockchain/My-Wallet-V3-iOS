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
        VStack(spacing: Spacing.padding2) {
            HStack {
                Text(
                    String(
                        format: LocalizationIds.onHoldTitle,
                        withdrawalLocks.amount
                    )
                )
                .typography(.body2)
                .foregroundColor(.semantic.title)
                Spacer()
                Button {
                    presentationMode.wrappedValue.dismiss()
                } label: {
                    Icon.closeCircle
                        .color(.semantic.muted)
                        .frame(height: 24.pt)
                }
            }
            .padding(.top, Spacing.padding3)
            .padding([.horizontal, .bottom])

            VStack(alignment: .leading, spacing: 4) {
                Text(LocalizationIds.totalOnHoldTitle)
                    .typography(.caption1)
                    .foregroundColor(.semantic.title)
                    .frame(
                        maxWidth: .infinity,
                        alignment: .leading
                    )

                Text(withdrawalLocks.amount)
                    .typography(.title2.slashedZero())
                    .foregroundColor(.semantic.title)
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
                List {
                    Section {
                        ForEach(withdrawalLocks.items) { item in
                            TableRow(
                                leading: {
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
                                },
                                title: .init(rowTitle(item: item)),
                                byline: .init(
                                    String(
                                        format: LocalizationIds.availableOnTitle,
                                        item.date
                                    )
                                ),
                                trailing: {
                                    VStack(alignment: .trailing, spacing: Spacing.textSpacing) {
                                        Text(item.amount)
                                            .typography(.paragraph2.slashedZero())
                                            .foregroundColor(.semantic.title)
                                        if let boughtAmount = item.boughtAmount {
                                            Text(boughtAmount)
                                                .typography(.caption1.slashedZero())
                                                .foregroundColor(.semantic.body)
                                        }
                                    }
                                }
                            )
                            .tableRowBackground(Color.clear)
                            .listRowBackground(Color.semantic.background)
                            .listRowSeparatorTint(Color.semantic.light)
                            .tableRowHorizontalInset(0)
                            .background(Color.semantic.background)
                        }
                    } footer: {
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
                        .padding([.top], 3)
                    }
                }
                .listStyle(.insetGrouped)
                .hideScrollContentBackground()
            }

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
        .background(
            Color.semantic.light
                .ignoresSafeArea()
        )
    }

    private func rowTitle(item: WithdrawalLocks.Item) -> String {
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
