// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BigInt

public struct EVMNetworkConfig: Hashable, Codable {

    public static let ethereum: EVMNetworkConfig = EVMNetworkConfig(
        name: "Ethereum",
        chainID: 1,
        nativeAsset: "ETH",
        explorerUrl: "https://www.blockchain.com/eth/tx",
        networkTicker: "ETH",
        nodeURL: "https://api.blockchain.info/eth/nodes/rpc",
        shortName: "Ethereum"
    )

    public let name: String
    public let chainID: BigUInt
    public let nativeAsset: String
    public let explorerUrl: String
    public let networkTicker: String
    public let nodeURL: String?
    public let shortName: String

    public func hash(into hasher: inout Hasher) {
        hasher.combine(networkTicker)
        hasher.combine(chainID)
    }

    public static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.chainID == rhs.chainID
    }

    public init(
        name: String,
        chainID: BigUInt,
        nativeAsset: String,
        explorerUrl: String,
        networkTicker: String,
        nodeURL: String?,
        shortName: String
    ) {
        self.name = name
        self.chainID = chainID
        self.nativeAsset = nativeAsset
        self.explorerUrl = explorerUrl
        self.networkTicker = networkTicker
        self.nodeURL = nodeURL
        self.shortName = shortName
    }
}

public struct EVMNetwork: Hashable, Equatable, Codable {
    public let networkConfig: EVMNetworkConfig
    public let nativeAsset: CryptoCurrency

    public init(networkConfig: EVMNetworkConfig, nativeAsset: CryptoCurrency) {
        self.networkConfig = networkConfig
        self.nativeAsset = nativeAsset
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(networkConfig)
    }

    public static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.networkConfig == rhs.networkConfig
    }
}
