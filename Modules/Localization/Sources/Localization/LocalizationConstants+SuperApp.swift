// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

extension LocalizationConstants {
    public enum AppMode {}
}

extension LocalizationConstants {
    public enum DefiBuyCryptoSheet {}
}

extension LocalizationConstants {
    public enum SuperAppIntro {}
}

extension LocalizationConstants.AppMode {
    public static let privateKeyWallet = NonLocalizedConstants.defiWalletTitle

    public static let tradingAccount = NSLocalizedString(
        "Accounts",
        comment: "Accounts"
    )
}

extension LocalizationConstants.SuperAppIntro {
    public static let getStartedButton = NSLocalizedString(
        "Get Started",
        comment: "Get Started"
    )
}

extension LocalizationConstants.DefiBuyCryptoSheet {
    public static let message = NSLocalizedString(
        "We don’t support buying crypto into your %@ at this time. You can buy from your Blockchain.com Account and send to your %@.",
        comment: "We don’t support buying crypto into your DeFi Wallet at this time. You can buy from your Blockchain.com Account and send to your DeFi Wallet."
    )

    public static let ctaButton = NSLocalizedString(
        "Open Blockchain.com Account",
        comment: "Open Blockchain.com Account"
    )
}
