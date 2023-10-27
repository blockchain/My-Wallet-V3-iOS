// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

enum L10n {
    enum Screen {
        enum List {}
        enum Empty {}
        enum Detail {}
    }

    enum NetworkPicker {}
}

extension L10n.Screen.List {
    static let fetchingYourNFTs = NSLocalizedString(
        "Fetching Your NFTs",
        comment: ""
    )
    static let shopOnOpenSea = NSLocalizedString(
        "Shop on OpenSea",
        comment: ""
    )
    static let title = NSLocalizedString(
        "Your Collectibles",
        comment: "Your Collectibles"
    )
}

extension L10n.NetworkPicker {
    static let title = NSLocalizedString(
        "Network",
        comment: ""
    )

    static let allNetworks = NSLocalizedString(
        "All",
        comment: ""
    )

    static let selectNetwork = NSLocalizedString(
        "Select network",
        comment: ""
    )
}

extension L10n.Screen.Empty {
    static let headline = NSLocalizedString(
        "Add NFTs to your DeFi Wallet",
        comment: ""
    )
    static let subheadline = NSLocalizedString(
        "Transfer from any wallet,\nor buy from a marketplace!",
        comment: ""
    )
    static let copyEthAddress = NSLocalizedString(
        "Copy Ethereum Address",
        comment: ""
    )
    static let copied = NSLocalizedString(
        "Copied!",
        comment: ""
    )
    static let receive = NSLocalizedString(
        "Receive",
        comment: ""
    )
    static let buy = NSLocalizedString(
        "Buy NFTs",
        comment: ""
    )
}

extension L10n.Screen.Detail {

    static let viewOnOpenSea = NSLocalizedString(
        "View on OpenSea",
        comment: ""
    )

    static let properties = NSLocalizedString(
        "Properties",
        comment: ""
    )

    static let network = NSLocalizedString(
        "Network",
        comment: ""
    )

    static let creator = NSLocalizedString("Creator", comment: "")

    static let about = NSLocalizedString("About", comment: "")

    static let descripton = NSLocalizedString("Description", comment: "")

    static let readMore = NSLocalizedString("Read More", comment: "")
}
