// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

extension LocalizationConstants {
    public enum Referrals {
        public enum SettingsScreen {}
        public enum ReferralScreen {}
    }
}

extension LocalizationConstants.Referrals.SettingsScreen {
    public static let buttonTitle = NSLocalizedString(
        "Referral program",
        comment: "Referral program"
    )
}

extension LocalizationConstants.Referrals.ReferralScreen {
    public static let shareButton = NSLocalizedString(
        "Share",
        comment: "Share"
    )

    public static let stepsTitleLabel = NSLocalizedString(
        "To qualify, your friends must:",
        comment: "To qualify, your friends must:"
    )

    public static let referralCodeLabel = NSLocalizedString(
        "Your referral code",
        comment: "Your referral code"
    )

    public static let copyLabel = NSLocalizedString(
        "Copy",
        comment: "Copy"
    )

    public static let copiedLabel = NSLocalizedString(
        "Copied",
        comment: "Copied"
    )

    public static let shareTitle = NSLocalizedString(
        "Join me on Blockchain.com",
        comment: "Join me on Blockchain.com"
    )

    public static func shareMessage(_ code: String) -> String {
        NSLocalizedString(
            "Join me and sign up to a Blockchain.com Wallet with referral code \(code), and get a bonus in crypto!\n\nFind the app here: https://blockchainwallet.page.link/join",
            comment: "Join me and sign up to a Blockchain.com Wallet with referral code \(code), and get a bonus in crypto!\n\nFind the app here: https://blockchainwallet.page.link/join"
        )
    }
}
