// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation
import MetadataKit
import MoneyKit
import Web3Wallet

public enum WalletConnectPairings: Codable, Equatable, Hashable {
    case v2(DAppPairing)

    public var v2: DAppPairing? {
        switch self {
        case .v2(let dAppPairing):
            return dAppPairing
        }
    }

    public var name: String {
        switch self {
        case .v2(let dAppPairing):
            return dAppPairing.name
        }
    }

    public var description: String {
        switch self {
        case .v2(let dAppPairing):
            return dAppPairing.description
        }
    }

    public var iconURL: URL? {
        switch self {
        case .v2(let dAppPairing):
            return dAppPairing.iconURL
        }
    }

    public var url: String? {
        switch self {
        case .v2(let dAppPairing):
            return URL(string: dAppPairing.url)?.host
        }
    }

    public var networks: [EVMNetwork] {
        switch self {
        case .v2(let dAppPairing):
            return dAppPairing.networks
        }
    }
}
