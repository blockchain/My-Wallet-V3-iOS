// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Localization

extension LocalizationConstants {
    public enum SweepImportedAddress {}
    public enum NoSweepNeeded {}
}

extension LocalizationConstants.SweepImportedAddress {
    static let title = NSLocalizedString(
        "Security Notice",
        comment: "Security Notice"
    )

    static let notice = NSLocalizedString(
        "The following legacy addresses have been identified as possibly to be vulnerable to a security issue.\n\nTo secure your funds, click the ‘Transfer Funds’ button below.\n\nThis will move the funds from the legacy addresses into new, secure addresses in your DeFi Wallet.",
        comment: "Security Notice"
    )

    static let transferFunds = NSLocalizedString(
        "Transfer Funds",
        comment: "Button title: Transfer Funds"
    )

    static let success = NSLocalizedString(
        "Success",
        comment: "Success title"
    )

    static let successNotice = NSLocalizedString(
        "All funds held in legacy addresses have been successfully transferred to new addresses in your DeFi Wallet. Please discontinue the use of the legacy addresses in your wallet for receiving funds. Should you receive funds into these addresses in the future, you will be prompted again to transfer them to a new, secure address. You can now continue using your wallet normally.",
        comment: "Success message"
    )

    static let failure = NSLocalizedString(
        "Failure",
        comment: "Failure title"
    )

    static let failureNotice = NSLocalizedString(
        "There was an issue moving your funds. Please contact Support.",
        comment: "Failure message"
    )

    static let okButton = NSLocalizedString(
        "OK",
        comment: "OK button title"
    )
}

extension LocalizationConstants.NoSweepNeeded {
    static let title = NSLocalizedString(
        "Security Notice",
        comment: "Security Notice"
    )

    static let subtitle = NSLocalizedString(
        "Your wallet does not contain any funds affected by the identified security issue.",
        comment: "Subtitle Security notice"
    )

    static let subtitle2 = NSLocalizedString(
        "You can continue using your wallet normally.",
        comment: "Subtitle Security notice"
    )

    static let thanks = NSLocalizedString(
        "Thanks!",
        comment: "Button title: thanks"
    )
}
