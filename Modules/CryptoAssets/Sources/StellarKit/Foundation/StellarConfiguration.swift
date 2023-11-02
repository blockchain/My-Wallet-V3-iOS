// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import stellarsdk

private enum HorizonServer {
    fileprivate enum Blockchain {
        fileprivate static let production = "https://api.blockchain.info/stellar"
    }

    fileprivate enum Stellar {
        fileprivate static let production = "https://horizon.stellar.org"
        fileprivate static let testnet = "https://horizon-testnet.stellar.org"
    }
}

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
            sdk: StellarSDK(withHorizonUrl: HorizonServer.Blockchain.production),
            network: Network.public
        )
    }

    enum Stellar {
        static let production = StellarConfiguration(
            sdk: StellarSDK(withHorizonUrl: HorizonServer.Stellar.production),
            network: Network.public
        )

        static let test = StellarConfiguration(
            sdk: StellarSDK(withHorizonUrl: HorizonServer.Stellar.testnet),
            network: Network.testnet
        )
    }
}

extension stellarsdk.Network: Equatable {
    public static func == (lhs: Network, rhs: Network) -> Bool {
        switch (lhs, rhs) {
        case (.public, .public),
             (.testnet, .testnet):
            true
        case (.custom(let lhs), .custom(let rhs)) where lhs == rhs:
            true
        default:
            false
        }
    }
}
