// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainComponentLibrary
import BlockchainNamespace
import Combine
import FeatureCoinDomain
import Localization
import MoneyKit
import SwiftUI

struct AccountRow: View {

    @BlockchainApp var app
    @Environment(\.context) var context
    @State private var isVerified = true

    let account: Account.Snapshot
    let assetColor: Color
    let interestRate: Double?
    let actionEnabled: Bool

    var title: String {
        if account.accountType == .trading || account.accountType == .privateKey {
            return account.assetName
        }
        return account.name
    }

    var subtitle: String? {
        guard let subtitle = account.subtitle else {
            return nil
        }
        let interestRateDisplay = percentageFormatter
            .string(from: NSNumber(value: interestRate.or(0) / 100))
            .or("")
        return subtitle.interpolating(interestRateDisplay)
    }

    init(
        account: Account.Snapshot,
        assetColor: Color,
        interestRate: Double? = nil,
        actionEnabled: Bool = true
    ) {
        self.account = account
        self.assetColor = assetColor
        self.interestRate = interestRate
        self.actionEnabled = actionEnabled
    }

    var body: some View {
        TableRow(
            leading: {
                account
                    .icon(color: assetColor)
                    .frame(width: 24, height: 24)
            },
            title: {
                Text(title)
                    .typography(.paragraph2.slashedZero())
                    .foregroundColor(.semantic.title)
            },
            byline: {
                if let subtitle {
                    Text(subtitle)
                        .typography(.caption1.slashedZero())
                        .foregroundColor(.semantic.body)
                }
            },
            trailing: {
                VStack(alignment: .trailing, spacing: Spacing.textSpacing) {
                    trailingTitleView
                    trailingDescriptionView.padding(.top, 2)
                }
            }
        )
        .background(Color.semantic.background)
        .onTapGesture {
            if actionEnabled {
                withAnimation(.spring()) {
                    app.post(
                        event: blockchain.ux.asset.account.sheet[].ref(to: context),
                        context: context
                    )
                }
            }
        }
        .bindings {
            subscribe($isVerified, to: blockchain.user.is.verified)
        }
        .batch {
            set(
                blockchain.ux.asset.account.rewards.summary.then.enter.into,
                to: blockchain.ux.earn.portfolio.product["savings"].asset[account.cryptoCurrency.code].summary
            )
            set(
                blockchain.ux.asset.account.staking.summary.then.enter.into,
                to: blockchain.ux.earn.portfolio.product["staking"].asset[account.cryptoCurrency.code].summary
            )
            set(
                blockchain.ux.asset.account.active.rewards.summary.then.enter.into,
                to: blockchain.ux.earn.portfolio.product["earn_cc1w"].asset[account.cryptoCurrency.code].summary
            )
            if app.currentMode == .pkw {
                set(
                    blockchain.ux.asset.account[account.id].receive.then.enter.into,
                    to: blockchain.ux.currency.receive.address
                )
            } else {
                set(
                    blockchain.ux.asset.account[account.id].receive.then.enter.into,
                    to: isVerified ? blockchain.ux.currency.receive.address : blockchain.ux.kyc.trading.unlock.more
                )
            }
        }
    }

    @ViewBuilder
    private var trailingTitleView: some View {
        if let value = account.fiat?.displayString {
            Text(value)
                .typography(.paragraph2.slashedZero())
                .foregroundColor(.semantic.title)
        } else if account.crypto == nil {
            redactedView
        }
    }

    @ViewBuilder
    private var trailingDescriptionView: some View {
        if let value = account.crypto?.displayString {
            Text(value)
                .typography(.caption1.slashedZero())
                .foregroundColor(.semantic.body)
        } else if account.fiat == nil {
            redactedView
        }
    }

    @ViewBuilder
    private var redactedView: some View {
        Text("......").redacted(reason: .placeholder)
    }
}

extension Account.Snapshot {
    @ViewBuilder
    func icon(color: Color) -> some View {
        switch accountType {
        case .exchange:
            Icon
                .walletExchange
                .color(color)
        case .interest:
            Icon.interestCircle
                .color(color)
        case .trading, .privateKey:
            cryptoCurrency.logo()
        case .staking:
            Icon.walletStaking
                .color(color)
        case .activeRewards:
            Icon
                .prices
                .color(color)
        }
    }

    var subtitle: String? {
        switch accountType {
        case .exchange:
            return LocalizationConstants.Coin.Account.exchange.subtitle
        case .interest:
            return LocalizationConstants.Coin.Account.interest.subtitle
        case .privateKey:
            return receiveAddress?.obfuscate(keeping: 4)
        case .trading:
            return nil
        case .staking:
            return LocalizationConstants.Coin.Account.interest.subtitle
        case .activeRewards:
            return LocalizationConstants.Coin.Account.active.subtitle
        }
    }
}

// swiftlint:disable type_name
struct AccountRow_PreviewProvider: PreviewProvider {
    static var previews: some View {
        Group {
            VStack(spacing: 0) {
                PrimaryDivider()

                AccountRow(
                    account: .init(
                        id: "",
                        name: "DeFi Wallet",
                        assetName: "Bitcoin",
                        accountType: .privateKey,
                        cryptoCurrency: .bitcoin,
                        fiatCurrency: .USD,
                        actions: [],
                        crypto: .one(currency: .bitcoin),
                        fiat: .one(currency: .USD),
                        isComingSoon: false,
                        receiveAddress: nil
                    ),
                    assetColor: .orange,
                    interestRate: nil
                )

                PrimaryDivider()

                AccountRow(
                    account: .init(
                        id: "",
                        name: "Blockchain.com Account",
                        assetName: "Bitcoin",
                        accountType: .trading,
                        cryptoCurrency: .bitcoin,
                        fiatCurrency: .USD,
                        actions: [],
                        crypto: .one(currency: .bitcoin),
                        fiat: .one(currency: .USD),
                        isComingSoon: false,
                        receiveAddress: nil
                    ),
                    assetColor: .orange,
                    interestRate: nil
                )

                PrimaryDivider()

                AccountRow(
                    account: .init(
                        id: "",
                        name: "Rewards Account",
                        assetName: "Bitcoin",
                        accountType: .interest,
                        cryptoCurrency: .bitcoin,
                        fiatCurrency: .USD,
                        actions: [],
                        crypto: .one(currency: .bitcoin),
                        fiat: .one(currency: .USD),
                        isComingSoon: false,
                        receiveAddress: nil
                    ),
                    assetColor: .orange,
                    interestRate: 2.5
                )

                PrimaryDivider()

                AccountRow(
                    account: .init(
                        id: "",
                        name: "Staking Account",
                        assetName: "Bitcoin",
                        accountType: .staking,
                        cryptoCurrency: .ethereum,
                        fiatCurrency: .USD,
                        actions: [],
                        crypto: .one(currency: .ethereum),
                        fiat: .one(currency: .USD),
                        isComingSoon: false,
                        receiveAddress: nil
                    ),
                    assetColor: .orange,
                    interestRate: 2.5
                )

                PrimaryDivider()

                AccountRow(
                    account: .init(
                        id: "",
                        name: "Exchange Account",
                        assetName: "Bitcoin",
                        accountType: .exchange,
                        cryptoCurrency: .bitcoin,
                        fiatCurrency: .USD,
                        actions: [],
                        crypto: .one(currency: .bitcoin),
                        fiat: .one(currency: .USD),
                        isComingSoon: false,
                        receiveAddress: nil
                    ),
                    assetColor: .orange,
                    interestRate: nil
                )
            }
        }
    }
}

let percentageFormatter = {
    let formatter = NumberFormatter()
    formatter.numberStyle = .percent
    formatter.maximumFractionDigits = 2
    formatter.minimumFractionDigits = 1
    return formatter
}()
