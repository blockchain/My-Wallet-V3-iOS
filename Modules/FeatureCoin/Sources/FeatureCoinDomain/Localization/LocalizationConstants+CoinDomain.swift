// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Localization

extension LocalizationConstants {

    enum CoinDomain {
        enum Button {
            enum Title {

                enum Rewards {
                    static let summary = NSLocalizedString(
                        "Summary",
                        comment: "Account Actions: Rewards summary CTA title"
                    )
                }

                static let buy = NSLocalizedString(
                    "Buy",
                    comment: "Account Actions: Buy CTA title"
                )
                static let sell = NSLocalizedString(
                    "Sell",
                    comment: "Account Actions: Sell CTA title"
                )
                static let send = NSLocalizedString(
                    "Send",
                    comment: "Account Actions: Send CTA title"
                )
                static let receive = NSLocalizedString(
                    "Receive",
                    comment: "Account Actions: Receive CTA title"
                )
                static let swap = NSLocalizedString(
                    "Swap",
                    comment: "Account Actions: Swap CTA title"
                )
                static let activity = NSLocalizedString(
                    "Activity",
                    comment: "Account Actions: Activity CTA title"
                )
                static let withdraw = NSLocalizedString(
                    "Withdraw",
                    comment: "Account Actions: Withdraw CTA title"
                )
                static let deposit = NSLocalizedString(
                    "Deposit",
                    comment: "Account Actions: Deposit CTA title"
                )
            }

            enum Description {

                enum ActiveRewards {
                    static let summary = NSLocalizedString(
                        "View Rewards %@",
                        comment: "Account Actions: Rewards summary CTA description"
                    )
                    static let withdraw = NSLocalizedString(
                        "Withdraw %@ from Rewards Account",
                        comment: "Account Actions: Rewards withdraw CTA description"
                    )
                    static let deposit = NSLocalizedString(
                        "Deposit %@",
                        comment: "Account Actions: Rewards deposit CTA description"
                    )
                }

                enum Staking {
                    static let summary = NSLocalizedString(
                        "View Staked %@",
                        comment: "Account Actions: Rewards summary CTA description"
                    )
                    static let deposit = NSLocalizedString(
                        "Stake %@",
                        comment: "Account Actions: Rewards deposit CTA description"
                    )
                }

                enum Rewards {
                    static let summary = NSLocalizedString(
                        "View Accrued %@ Rewards",
                        comment: "Account Actions: Rewards summary CTA description"
                    )
                    static let withdraw = NSLocalizedString(
                        "Withdraw %@ from Rewards Account",
                        comment: "Account Actions: Rewards withdraw CTA description"
                    )
                    static let deposit = NSLocalizedString(
                        "Add %@ to Rewards Account",
                        comment: "Account Actions: Rewards deposit CTA description"
                    )
                }

                enum Exchange {
                    static let withdraw = NSLocalizedString(
                        "Withdraw %@ from Exchange",
                        comment: "Account Actions: Exchange withdraw CTA description"
                    )
                    static let deposit = NSLocalizedString(
                        "Add %@ to Exchange",
                        comment: "Account Actions: Exchange deposit CTA description"
                    )
                }

                static let buy = NSLocalizedString(
                    "Use Your Cash or Card",
                    comment: "Account Actions: Buy CTA description"
                )
                static let sell = NSLocalizedString(
                    "Convert Your Crypto to Cash",
                    comment: "Account Actions: Sell CTA description"
                )
                static let send = NSLocalizedString(
                    "Transfer %@ to Other Wallets",
                    comment: "Account Actions: Send CTA description"
                )
                static let receive = NSLocalizedString(
                    "Receive %@ to your account",
                    comment: "Account Actions: Receive CTA description"
                )
                static let swap = NSLocalizedString(
                    "Exchange %@ for Another Crypto",
                    comment: "Account Actions: Swap CTA description"
                )
                static let activity = NSLocalizedString(
                    "View all transactions",
                    comment: "Account Actions: Activity CTA description"
                )
            }
        }
    }
}
