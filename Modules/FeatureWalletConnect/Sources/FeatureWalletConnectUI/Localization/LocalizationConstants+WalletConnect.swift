// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Localization

extension LocalizationConstants {
    enum WalletConnect {
        enum ChangeChain {}
        enum Connection {}
        enum List {}
    }
}

extension LocalizationConstants.WalletConnect {
    static let confirm = NSLocalizedString("Confirm", comment: "confirm")

    static var ok: String {
        LocalizationConstants.okString
    }

    static var cancel: String {
        LocalizationConstants.cancel
    }
}

extension LocalizationConstants.WalletConnect.Connection {

    static let wallet = NSLocalizedString(
        "Wallet",
        comment: "WalletConnect: wallet title"
    )

    static let networks = NSLocalizedString(
        "Networks",
        comment: "WalletConnect: networks"
    )

    static let dAppWantsToConnect = NSLocalizedString(
        "%@ wants to connect.",
        comment: "WalletConnect: connection authorization with dApp name"
    )

    static let dAppConnectionSuccess = NSLocalizedString(
        "%@ is now connected to your wallet.",
        comment: "WalletConnect: connection confirmation with dApp name"
    )

    static let dAppConnectionFail = NSLocalizedString(
        "%@ connection was rejected.",
        comment: "WalletConnect: connection failed with dApp name"
    )

    static let dAppConnectionFailure = NSLocalizedString(
        "Connection with %@ failed.",
        comment: "WalletConnect: connection failed with dApp name"
    )


    static let dAppConnectionFailMessage = NSLocalizedString(
        "Go back to your browser and try again.",
        comment: "WalletConnect: connection fail instruction message"
    )
}

extension LocalizationConstants.WalletConnect.List {
    static let connectedAppsCount = NSLocalizedString(
        "%@ Connected Apps",
        comment: "WalletConnect: number of connected dApps"
    )

    static let connectedAppCount = NSLocalizedString(
        "1 Connected App",
        comment: "WalletConnect: 1 connected dApp"
    )

    static let disconnect = NSLocalizedString(
        "Disconnect",
        comment: "WalletConnect: disconnect button title"
    )
}

extension LocalizationConstants.WalletConnect.ChangeChain {

    static func title(dAppName: String, networkName: String) -> String {
        let format = NSLocalizedString(
            "%@ wants to switch to %@ network.",
            comment: "WalletConnect: switch network with dApp name"
        )
        return String(format: format, dAppName, networkName)
    }
}
