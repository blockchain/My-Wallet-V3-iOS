// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BigInt

/// A product of an `AssetModel`.
public enum AssetModelProduct: String, Hashable, CaseIterable {

    case privateKey = "PrivateKey"

    case mercuryDeposits = "MercuryDeposits"

    case mercuryWithdrawals = "MercuryWithdrawals"

    case interestBalance = "InterestBalance"

    case custodialWalletBalance = "CustodialWalletBalance"

    case stakingBalance = "StakingBalance"

    case activeRewardsBalance = "EarnCC1W"
}

public struct EVMNetworkConfig: Hashable {

    public static let ethereum: EVMNetworkConfig = EVMNetworkConfig(
        name: "Ethereum",
        chainID: 1,
        nativeAsset: "ETH",
        explorerUrl: "https://www.blockchain.com/eth/tx/",
        networkTicker: "ETH",
        nodeURL: "https://api.blockchain.info/eth/nodes/rpc"
    )

    public let name: String
    public let chainID: BigUInt
    public let nativeAsset: String
    public let explorerUrl: String
    public let networkTicker: String
    public let nodeURL: String

    public func hash(into hasher: inout Hasher) {
        hasher.combine(chainID)
    }

    public static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.chainID == rhs.chainID
    }

    public init(name: String, chainID: BigUInt, nativeAsset: String, explorerUrl: String, networkTicker: String, nodeURL: String) {
        self.name = name
        self.chainID = chainID
        self.nativeAsset = nativeAsset
        self.explorerUrl = explorerUrl
        self.networkTicker = networkTicker
        self.nodeURL = nodeURL
    }
}

public struct EVMNetwork: Hashable {

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
