// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation
import Localization

extension LocalizationConstants.SuperAppIntro {

    enum V1 {

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
        }

        enum ExistingUser {
            static let title = NSLocalizedString(
                "Welcome to\nBlockchain.com",
                comment: "SuperApp v1 Intro: existing user title"
            )

            static let subtitle = NSLocalizedString(
                "We've made some major improvements to our navigation and visual design.",
                comment: "SuperApp v1 Intro: existing user subtitle"
            )
        }

        enum TradingAccount {
            static let title = NSLocalizedString(
                "Buy, sell, and swap crypto",
                comment: "SuperApp v1 Intro: Blockchain.com Account title"
            )

            static let subtitle = NSLocalizedString(
                "Use a card or bank account to buy crypto.\nEarn rewards by putting your crypto to work.",
                comment: "SuperApp v1 Intro: Blockchain.com Account subtitle"
            )

            static let badge = NSLocalizedString(
                "Held by Blockchain.com",
                comment: "SuperApp v1 Intro: Blockchain.com Account badge"
            )
        }

        enum DefiWallet {
            static let title = NSLocalizedString(
                "Discover the world of DeFi",
                comment: "SuperApp v1 Intro: DeFi title"
            )

            static let subtitle = NSLocalizedString(
                "Self-custody your crypto, use decentralized applications, and collect NFTs.",
                comment: "SuperApp v1 Intro: DeFi subtitle"
            )

            static let badge = NSLocalizedString(
                "Held by You",
                comment: "SuperApp v1 Intro: DeFi badge"
            )
        }
    }
}
