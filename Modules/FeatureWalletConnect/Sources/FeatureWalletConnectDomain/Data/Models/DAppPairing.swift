// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation
import MetadataKit
import MoneyKit
import WalletConnectSwift
import Web3Wallet

public struct DAppPairingV1: Codable, Equatable, Hashable {
    public let name: String
    public let description: String
    public let url: String
    public let iconUrlString: String?
    public let networks: [EVMNetwork]

    public let activeSession: WalletConnectSwift.Session?

    public var iconURL: URL? {
        guard let iconUrlString else {
            return nil
        }
        return URL(string: iconUrlString)
    }
}

public struct DAppPairing: Codable, Equatable, Hashable {
    public let pairingTopic: String
    public let name: String
    public let description: String
    public let url: String
    public let iconUrlString: String?
    public let networks: [EVMNetwork]

    public let activeSession: WalletConnectSessionV2?

    public var iconURL: URL? {
        guard let iconUrlString else {
            return nil
        }
        return URL(string: iconUrlString)
    }
}
