// Copyright © Blockchain Luxembourg S.A. All rights reserved.

// swiftlint:disable all

import Foundation

extension LocalizationConstants {
    public enum Receive {
        public enum Header {}
        public enum Text {}
        public enum Button {}
    }
}

extension LocalizationConstants.Receive.Header {

    public static let receiveCryptoNow = NSLocalizedString(
        "Receive Crypto Now",
        comment: "Section header where wallet address is displayed."
    )

}

extension LocalizationConstants.Receive.Text {

    public static let request = NSLocalizedString(
        "Request",
        comment: "Screen title."
    )

    public static let receive = NSLocalizedString(
        "Receive",
        comment: "Screen title."
    )

    public static let domainName = NSLocalizedString(
        "Domain Name",
        comment: "Section header where domain name is displayed."
    )

    public static let walletAddress = NSLocalizedString(
        "Wallet Address",
        comment: "Section header where wallet address is displayed."
    )

    public static let memo = NSLocalizedString(
        "Memo",
        comment: "Section header where memo is displayed."
    )

    public static func alertTitle(displayCode: String, networkName: String) -> String {
        let string = NSLocalizedString(
            "%@ on %@ Network",
            comment: "EVM Alert title: 'USDC on Ethereum Network'"
        )
        return String(format: string, displayCode, networkName)
    }

    public static func alertBody(displayCode: String, networkName: String) -> String {
        let string = NSLocalizedString(
            "Please send %@ on %@ Network to this address only. We cannot recover lost funds.",
            comment: "EVM Alert body: 'Please send USDC on Ethereum Network to...'"
        )
        return String(format: string, displayCode, networkName)
    }

    public static let memoNote = NSLocalizedString(
        "If you send funds without the XLM Memo Text, your funds will be lost and not credited to your account. Please send only XLM to this address.",
        comment: "Note about Stellar Memos"
    )

    public static let learnMore = NSLocalizedString(
        " Learn more.",
        comment: "Learn more"
    )

    public static let copiedToClipboard = NSLocalizedString(
        "Copied to clipboard",
        comment: "Text displayed when a crypto address has been copied to the users clipboard."
    )

    public static let pleaseSendXTo = NSLocalizedString(
        "Please send %@ to",
        comment: "Message when requesting payment to a given asset."
    )

    public static let xPaymentRequest = NSLocalizedString(
        "%@ payment request.",
        comment: "Subject when requesting payment for a given asset."
    )
}

extension LocalizationConstants.Receive.Button {
    public static let copy = NSLocalizedString(
        "Copy Address",
        comment: "Button CTA to copy address to pasteboard."
    )
    public static let copied = NSLocalizedString(
        "Copied!",
        comment: "Copy address button title after copy was made"
    )
    public static let share = NSLocalizedString(
        "Share Address",
        comment: "Button CTA to share address."
    )
}
