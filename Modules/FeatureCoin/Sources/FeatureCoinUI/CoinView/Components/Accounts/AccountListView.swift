// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainComponentLibrary
import BlockchainNamespace
import Combine
import ComposableArchitecture
import FeatureCoinDomain
import Foundation
import Localization
import MoneyKit
import SwiftUI

public struct AccountListView: View {
    private typealias Localization = LocalizationConstants.Coin.Accounts

    @BlockchainApp var app
    @Environment(\.context) var context

    let accounts: [Account.Snapshot]
    let currency: CryptoCurrency

    let earnRates: EarnRates?
    let kycStatus: KYCStatus?

    var __accounts: [Account.Snapshot] {
        switch kycStatus {
        case .none, .unverified, .inReview:
            return accounts.filter(\.isPrivateKey)
        case .silver, .silverPlus, .gold:
            return accounts
        }
    }

    var isDefiMode: Bool {
        accounts.count == 1 && accounts.first?.accountType == .privateKey
    }

    public var body: some View {
        VStack(spacing: 0) {
            if accounts.isEmpty {
                loading()
            } else {
                ForEach(__accounts) { account in
                    AccountRow(
                        account: account,
                        assetColor: currency.color,
                        interestRate: earnRates?.rate(accountType: account.accountType)
                    )
                    .context(
                        [
                            blockchain.ux.asset.account.id: account.id,
                            blockchain.ux.asset.account: account
                        ]
                    )

                    if __accounts.last != account {
                        PrimaryDivider()
                    }
                }
                switch kycStatus {
                case .none, .unverified, .inReview:
                    locked()
                case .silver, .silverPlus, .gold:
                    EmptyView()
                }
            }
        }
        .cornerRadius(16)
        .padding(.horizontal, Spacing.padding2)
    }

    @ViewBuilder func loading() -> some View {
        Group {
            ForEach(1...3, id: \.self) { _ in
                LockedAccountRow(
                    title: Localization.tradingAccountTitle,
                    subtitle: Localization.tradingAccountSubtitle,
                    icon: .trade
                )
                PrimaryDivider()
            }
        }
        .disabled(true)
        .redacted(reason: .placeholder)
    }

    @ViewBuilder func locked() -> some View {
        if currency.supports(product: .custodialWalletBalance) {
            LockedAccountRow(
                title: Localization.tradingAccountTitle,
                subtitle: Localization.tradingAccountSubtitle,
                icon: .trade
            )
            .context([blockchain.ux.asset.account.type: Account.AccountType.trading])
            PrimaryDivider()
        }
        if currency.supports(product: .interestBalance) {
            LockedAccountRow(
                title: Localization.rewardsAccountTitle,
                subtitle: Localization.rewardsAccountSubtitle.interpolating(earnRates.or(.zero).interestRate.or(0)),
                icon: .interestCircle
            )
            .context([blockchain.ux.asset.account.type: Account.AccountType.interest])
            PrimaryDivider()
        }
        if currency.supports(product: .stakingBalance) {
            LockedAccountRow(
                title: Localization.stakingAccountTitle,
                subtitle: Localization.stakingAccountSubtitle.interpolating(earnRates.or(.zero).stakingRate.or(0)),
                icon: .lockClosed.circle()
            )
            .context([blockchain.ux.asset.account.type: Account.AccountType.staking])
            PrimaryDivider()
        }
        if currency.supports(product: .activeRewardsBalance) {
            LockedAccountRow(
                title: Localization.activeRewardsAccountTitle,
                subtitle: Localization.activeRewardsAccountSubtitle.interpolating(earnRates.or(.zero).stakingRate.or(0)),
                icon: .lockClosed.circle()
            )
            .context([blockchain.ux.asset.account.type: Account.AccountType.activeRewards])
            PrimaryDivider()
        }
    }
}

// swiftlint:disable type_name
struct AccountListView_PreviewProvider: PreviewProvider {
    static var previews: some View {
        AccountListView(
            accounts: [
                .preview.privateKey,
                .preview.trading,
                .preview.rewards
            ],
            currency: .bitcoin,
            earnRates: nil,
            kycStatus: .gold
        )
        .previewDisplayName("Gold")
        AccountListView(
            accounts: [
                .preview.privateKey,
                .preview.trading,
                .preview.rewards
            ],
            currency: .bitcoin,
            earnRates: nil,
            kycStatus: .silver
        )
        .previewDisplayName("Silver")
        AccountListView(
            accounts: [
                .preview.privateKey,
                .preview.trading,
                .preview.rewards
            ],
            currency: .bitcoin,
            earnRates: nil,
            kycStatus: .unverified
        )
        .previewDisplayName("Unverified")

        AccountListView(
            accounts: [
                .preview.privateKey
            ],
            currency: .bitcoin,
            earnRates: nil,
            kycStatus: .unverified
        )
        .previewDisplayName("Single Account Defi")

        AccountListView(
            accounts: [
                .preview.privateKey,
                .preview.privateKey
            ],
            currency: .bitcoin,
            earnRates: nil,
            kycStatus: .unverified
        )
        .previewDisplayName("Double Account Defi")
    }
}

extension Account.Snapshot {
    var isPrivateKey: Bool { accountType == .privateKey }
}
