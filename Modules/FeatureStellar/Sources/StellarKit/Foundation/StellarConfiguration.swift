// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import stellarsdk

struct StellarConfiguration: Equatable {

    let sdk: StellarSDK
    let network: Network

    init(sdk: StellarSDK, network: Network) {
        self.sdk = sdk
        self.network = network
    }

    init(horizonURL: String) {
        self.init(
            sdk: StellarSDK(withHorizonUrl: horizonURL),
            network: Network.public
        )
    }

    static func == (lhs: StellarConfiguration, rhs: StellarConfiguration) -> Bool {
        lhs.sdk.horizonURL == rhs.sdk.horizonURL
            && lhs.network == rhs.network
    }
}

extension StellarConfiguration {
    enum Blockchain {
        static let production = StellarConfiguration(
            sdk: StellarSDK(withHorizonUrl: "https://api.blockchain.info/stellar"),
            network: Network.public
        )
    }

    enum Stellar {
        static let production = StellarConfiguration(
            sdk: StellarSDK(withHorizonUrl: "https://horizon.stellar.org"),
            network: Network.public
        )
    }
}

extension stellarsdk.Network: Equatable {
    public static func == (lhs: Network, rhs: Network) -> Bool {
        switch (lhs, rhs) {
        case (.public, .public),
            (.futurenet, .futurenet),
            (.testnet, .testnet):
            true
        case (.custom(let lhs), .custom(let rhs)):
            lhs == rhs
        default:
            false
        }
    }
}
