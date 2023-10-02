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
                "If you prefer to custody your own funds, use the DeFi Wallet.",
                comment: "SuperApp Intro V2: Footer"
            )
            static let button = NSLocalizedString(
                "View my account",
                comment: "SuperApp Intro V2: Button"
            )
        }

        enum External {
            static let tag = NSLocalizedString(
                "Custodial",
                comment: "SuperApp Intro External: Custodial"
            )
            static let title = NSLocalizedString(
                "Welcome to your Account",
                comment: "SuperApp Intro External: Title"
            )
            static let row1 = NSLocalizedString(
                "Hold crypto without worrying about private keys",
                comment: "SuperApp Intro External: Row 1"
            )
            static let row2 = NSLocalizedString(
                "Buy and sell crypto",
                comment: "SuperApp Intro External: Row 2"
            )
            static let row3 = NSLocalizedString(
                "Fund your account with a bank account",
                comment: "SuperApp Intro External: Row 3"
            )
            static let footer = NSLocalizedString(
                "If you prefer to custody your own funds, use the DeFi Wallet.",
                comment: "SuperApp Intro V2: Footer"
            )
            static let button = NSLocalizedString(
                "View my account",
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
                "If you would like us to hold your crypto, use our Blockchain.com Account.",
                comment: "SuperApp Intro V2: DeFi Footer"
            )
            static let externalFooter = NSLocalizedString(
                "If you would like us to hold your crypto, use the Account.",
                comment: "SuperApp Intro V2: DeFi Footer for External"
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
}
