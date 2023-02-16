// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation
import Localization

extension LocalizationConstants.SuperAppIntro {

    enum V1 {

        static let swipeToContinue = NSLocalizedString(
            "Swipe to continue ->",
            comment: "SuperApp v1 Intro: swipe to continue ->"
        )

        enum Button {
            static let title = NSLocalizedString(
                "OK",
                comment: "SuperApp v1 Intro: button title"
            )
        }

        enum NewUser {
            static let title = NSLocalizedString(
                "Welcome to\nBlockchain.com",
                comment: "SuperApp v1 Intro: new user title"
            )

            static let subtitle = NSLocalizedString(
                "The only crypto app you'll ever need.",
                comment: "SuperApp v1 Intro: new user subtitle"
            )

            static let description = NSLocalizedString(
                "Join over 40M users who have transacted $1T+ since 2012 on Blockchain.com.",
                comment: "SuperApp v1 Intro: new user description"
            )
        }

        enum ExistingUser {
            static let title = NSLocalizedString(
                "Your app just got better",
                comment: "SuperApp v1 Intro: existing user title"
            )

            static let subtitle = NSLocalizedString(
                """
                Welcome to your new Blockchain.com app, a SuperApp for crypto. \
                Experience powerful crypto trading together with a self-custody wallet, all in one place.
                """,
                comment: "SuperApp v1 Intro: existing user subtitle"
            )
        }

        enum TradingAccount {
            static let title = NSLocalizedString(
                "Buy, sell, trade, and earn crypto",
                comment: "SuperApp v1 Intro: Blockchain.com Account title"
            )

            static let subtitle = NSLocalizedString(
                "Link a card or bank account to buy crypto.\nEarn rewards by putting your crypto to work.",
                comment: "SuperApp v1 Intro: Blockchain.com Account subtitle"
            )

            static let badge = NSLocalizedString(
                "Custodial",
                comment: "SuperApp v1 Intro: Blockchain.com Account badge"
            )

            static let description = NSLocalizedString(
                "Funds stored in your Blockchain.com Account are held in our custody system.",
                comment: "SuperApp v1 Intro: Blockchain.com Account description"
            )
        }

        enum DefiWallet {
            static let title = NSLocalizedString(
                "Control your crypto and use DeFi",
                comment: "SuperApp v1 Intro: DeFi title"
            )

            static let subtitle = NSLocalizedString(
                "Self-custody your crypto across multiple blockchains, use dapps, and collect NFTs.",
                comment: "SuperApp v1 Intro: DeFi subtitle"
            )

            static let badge = NSLocalizedString(
                "Self-Custody",
                comment: "SuperApp v1 Intro: DeFi badge"
            )

            static let description = NSLocalizedString(
                "With a DeFi Wallet, only you have access to your crypto assets. Blockchain.com cannot access your funds. Your keys, your crypto!",
                comment: "SuperApp v1 Intro: defi wallet description"
            )
        }
    }
}
