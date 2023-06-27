// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation
import MetadataKit
import MoneyKit
import Web3Wallet

public struct DAppPairing: Codable, Equatable, Hashable {
    public let pairingTopic: String
    public let name: String
    public let description: String
    public let url: String
    public let iconUrlString: String?
    public let networks: [EVMNetwork]

    public let activeSession: WalletConnectSession?

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
        activeSession: WalletConnectSession? = nil
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
