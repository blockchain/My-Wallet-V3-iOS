import Localization

extension LocalizationConstants {

    enum ReceiveScreen {
        enum ReceiveEntry {
            static let title = NSLocalizedString("Receive", comment: "Receive")
            static let cancel = NSLocalizedString("Cancel", comment: "Cancel")
            static let search = NSLocalizedString("Search", comment: "Search")
            static let noResults = NSLocalizedString("😔 No Results", comment: "😔 No Results")
        }

        enum ReceiveAddressScreen {
            static let title = NSLocalizedString("Receive %@", comment: "Receive %@")

            static let memo = NSLocalizedString("Memo", comment: "Memo")

            static let tradingNetworkWarning = NSLocalizedString(
                "Only receive tokens on the %@ Network",
                comment: "Only receive tokens on the %@ Network, placeholder is replaced by a blockchain network such as Ethereum"
            )

            static let defiNetworkWarning = NSLocalizedString(
                "Only receive %@ on the %@ Network",
                comment: "First placeholder is replaced by a blockchain coin such as USDC, second by a blockchain network such as Ethereum"
            )

            static let defiNetworkInformation = NSLocalizedString(
                "This %@ is on the %@ network",
                comment: "First placeholder is replaced by a blockchain coin such as USDC, second by a blockchain network such as Ethereum"
            )

            static let copyAddressButton = NSLocalizedString(
                "Copy Address",
                comment: "Copy Address, button title that performs a copy action of the blockchain coin address"
            )

            static let pleaseSendXTo = NSLocalizedString(
                "Please send %@ to",
                comment: "Message when requesting payment to a given asset."
            )

            static let xPaymentRequest = NSLocalizedString(
                "%@ payment request.",
                comment: "Subject when requesting payment for a given asset."
            )

            static let addressCopied = NSLocalizedString(
                "Address copied",
                comment: "Address copied"
            )

            static let domainCopied = NSLocalizedString(
                "Domain copied",
                comment: "Domain copied"
            )
        }
    }
}
