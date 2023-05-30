// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation
import MetadataKit
import MoneyKit
import WalletConnectSwift
import Web3Wallet

public enum WalletConnectPairings: Codable, Equatable, Hashable {
    case v1(DAppPairingV1)
    case v2(DAppPairing)

    public var v1: DAppPairingV1? {
        switch self {
        case .v1(let dAppPairing):
            return dAppPairing
        case .v2:
            return nil
        }
    }

    public var v2: DAppPairing? {
        switch self {
        case .v1:
            return nil
        case .v2(let dAppPairing):
            return dAppPairing
        }
    }

    public var name: String {
        switch self {
        case .v1(let dAppPairing):
            return dAppPairing.name
        case .v2(let dAppPairing):
            return dAppPairing.name
        }
    }

    public var description: String {
        switch self {
        case .v1(let dAppPairing):
            return dAppPairing.description
        case .v2(let dAppPairing):
            return dAppPairing.description
        }
    }

    public var iconURL: URL? {
        switch self {
        case .v1(let dAppPairing):
            return dAppPairing.iconURL
        case .v2(let dAppPairing):
            return dAppPairing.iconURL
        }
    }

    public var url: String? {
        switch self {
        case .v1(let dAppPairing):
            return URL(string: dAppPairing.url)?.host
        case .v2(let dAppPairing):
            return URL(string: dAppPairing.url)?.host
        }
    }

    public var networks: [EVMNetwork] {
        switch self {
        case .v1(let dAppPairing):
            return dAppPairing.networks
        case .v2(let dAppPairing):
            return dAppPairing.networks
        }
    }
}
