// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation
import Localization

extension LocalizationConstants.SuperAppIntro {

    enum V2 {

        enum Trading {
            static let tag = NSLocalizedString(
                "Custodial",
                comment: "SuperApp Intro V2: Custodial"
            )
            static let title = NSLocalizedString(
                "Welcome to your Blockchain.com Account",
                comment: "SuperApp Intro V2: Title"
            )
            static let byline = NSLocalizedString(
                "With the Blockchain.com Account, your funds are held in **our custody system**.",
                comment: "SuperApp Intro V2: Byline"
            )
            static let row1 = NSLocalizedString(
                "Buy, sell and trade crypto",
                comment: "SuperApp Intro V2: Row 1"
            )
            static let row2 = NSLocalizedString(
                "Fund your account with a card or bank account",
                comment: "SuperApp Intro V2: Row 2"
            )
            static let row3 = NSLocalizedString(
                "Earn rewards by putting your crypto to work",
                comment: "SuperApp Intro V2: Row 3"
            )
            static let footer = NSLocalizedString(
                "If you prefer to custody your own funds, use our DeFi Wallet.",
                comment: "SuperApp Intro V2: Footer"
            )
            static let button = NSLocalizedString(
                "Get started",
                comment: "SuperApp Intro V2: Button"
            )
        }

        enum DeFi {
            static let tag = NSLocalizedString(
                "Self-Custody",
                comment: "SuperApp Intro V2: DeFi"
            )
            static let title = NSLocalizedString(
                "Introducing the\nDeFi Wallet",
                comment: "SuperApp Intro V2: DeFi Title"
            )
            static let byline = NSLocalizedString(
                "With a DeFi Wallet, only you have access to your crypto assets - not us.\n**Your keys, your crypto.**",
                comment: "SuperApp Intro V2: DeFi Byline"
            )
            static let row1 = NSLocalizedString(
                "Self-custody your assets",
                comment: "SuperApp Intro V2: DeFi Row 1"
            )
            static let row2 = NSLocalizedString(
                "Use multiple chains",
                comment: "SuperApp Intro V2: DeFi Row 2"
            )
            static let row3 = NSLocalizedString(
                "Connect to Dapps and sign transactions",
                comment: "SuperApp Intro V2: DeFi Row 3"
            )
            static let footer = NSLocalizedString(
                "If you would like Blockchain.com to custody your funds, use our Blockchain.com Account.",
                comment: "SuperApp Intro V2: DeFi Footer"
            )
            static let button = NSLocalizedString(
                "View my DeFi Wallet",
                comment: "SuperApp Intro V2: DeFi Button"
            )
            static let secondaryButton = NSLocalizedString(
                "Learn More",
                comment: "SuperApp Intro V2: DeFi Secondary Button"
            )
        }
    }

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
