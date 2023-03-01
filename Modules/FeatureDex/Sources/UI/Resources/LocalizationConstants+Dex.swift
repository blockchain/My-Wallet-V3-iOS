// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation
import Localization

extension LocalizationConstants {
    enum Dex {
        enum Onboarding {}
    }
}

extension LocalizationConstants.Dex.Onboarding {
    static let button = NSLocalizedString(
        "Start Trading",
        comment: "Dex: Intro button"
    )

    enum Welcome {
        static let title = NSLocalizedString(
            "Welcome to the DEX",
            comment: "Dex: Intro Step 1 title"
        )
        static let description = NSLocalizedString(
            "A decentralized exchange (DEX) is a peer-to-peer marketplace that lets you swap cryptocurrencies.",
            comment: "Dex: Intro Step 1 description"
        )
    }

    enum SwapTokens {
        static let title = NSLocalizedString(
            "Swap 1000+ tokens",
            comment: "Dex: Intro Step 2 title"
        )
        static let description = NSLocalizedString(
            "Swap ETH, UNI, USDT, DAI, and more.",
            comment: "Dex: Intro Step 2 description"
        )
    }

    enum KeepControl {
        static let title = NSLocalizedString(
            "Keep control of your funds",
            comment: "Dex: Intro Step 3 title"
        )
        static let description = NSLocalizedString(
            "When you trade on a DEX, you keep access to your private keys––it’s \"your keys, your crypto.\" Blockchain.com doesn’t hold these funds.",
            comment: "Dex: Intro Step 3 description"
        )
    }
}
