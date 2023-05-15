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

    public init(
        name: String,
        description: String,
        url: String,
        iconUrlString: String? = nil,
        networks: [EVMNetwork],
        activeSession: WalletConnectSwift.Session? = nil
    ) {
        self.name = name
        self.description = description
        self.url = url
        self.iconUrlString = iconUrlString
        self.networks = networks
        self.activeSession = activeSession
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

    public init(
        pairingTopic: String,
        name: String,
        description: String,
        url: String,
        iconUrlString: String? = nil,
        networks: [EVMNetwork],
        activeSession: WalletConnectSessionV2? = nil
    ) {
        self.pairingTopic = pairingTopic
        self.name = name
        self.description = description
        self.url = url
        self.iconUrlString = iconUrlString
        self.networks = networks
        self.activeSession = activeSession
    }
}
