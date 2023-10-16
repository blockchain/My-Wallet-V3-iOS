// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BigInt
import Foundation

public struct EVMNetworkConfig: Hashable, Codable {

    public static let ethereum: EVMNetworkConfig = EVMNetworkConfig(
        name: "Ethereum",
        chainID: 1,
        nativeAsset: "ETH",
        logoURL: "https://raw.githubusercontent.com/blockchain/coin-definitions/master/extensions/blockchains/ethereum/info/logo.png",
        explorerUrl: "https://www.blockchain.com/eth/tx",
        networkTicker: "ETH",
        nodeURL: "https://api.blockchain.info/eth/nodes/rpc",
        shortName: "Ethereum"
    )

    public let name: String
    public let chainID: BigUInt
    public let nativeAsset: String
    public let explorerUrl: String
    public let logoURL: URL?
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
        logoURL: URL?,
        explorerUrl: String,
        networkTicker: String,
        nodeURL: String?,
        shortName: String
    ) {
        self.chainID = chainID
        self.explorerUrl = explorerUrl
        self.logoURL = logoURL
        self.name = name
        self.nativeAsset = nativeAsset
        self.networkTicker = networkTicker
        self.nodeURL = nodeURL
        self.shortName = shortName
    }
}

public struct EVMNetwork: Hashable, Equatable, Codable {
    public let networkConfig: EVMNetworkConfig
    public let nativeAsset: CryptoCurrency

    public var logoURL: URL? {
        networkConfig.logoURL ?? nativeAsset.logoURL
    }

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

extension EVMNetworkConfig {

    static func validType(_ value: NetworkConfigResponse.NetworkType) -> Bool {
        value == .evm
    }

    static func from(response: NetworkConfigResponse) -> [EVMNetworkConfig] {
        response.networks
            .compactMap { Self(response: $0) }
    }

    init?(response: NetworkConfigResponse.Network) {
        guard Self.validType(response.type) else {
            return nil
        }
        guard case .dictionary(let identifiers) = response.identifiers else {
            return nil
        }
        guard case .number(let chainID) = identifiers["chainId"] else {
            return nil
        }
        self.init(
            name: response.name,
            chainID: BigUInt(chainID),
            nativeAsset: response.nativeAsset, 
            logoURL: response.logoPngUrl.flatMap(URL.init),
            explorerUrl: response.explorerUrl,
            networkTicker: response.networkTicker,
            nodeURL: response.nodeUrls?.first,
            shortName: response.shortName
        )
    }
}
