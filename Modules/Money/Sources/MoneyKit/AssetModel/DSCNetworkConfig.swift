// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

public struct DSCNetworkConfig: Hashable, Codable {

    public struct Derivation: Codable, Hashable {
        let purpose: Int
        let coinType: Int
        public let style: String
        public var path: String {
            "m/\(purpose)'/\(coinType)'/0'/0/0"
        }
    }

    public let name: String
    public let nativeAsset: String
    public let explorerUrl: String
    public let logoURL: URL?
    public let networkTicker: String
    public let shortName: String
    public let memos: Bool
    public let derivation: Derivation

    init(
        name: String,
        nativeAsset: String,
        explorerUrl: String,
        logoURL: URL?,
        networkTicker: String,
        shortName: String,
        memos: Bool,
        derivation: DSCNetworkConfig.Derivation
    ) {
        self.name = name
        self.nativeAsset = nativeAsset
        self.explorerUrl = explorerUrl
        self.logoURL = logoURL
        self.networkTicker = networkTicker
        self.shortName = shortName
        self.memos = memos
        self.derivation = derivation
    }
}

extension DSCNetworkConfig {

    static func validType(_ value: NetworkConfigResponse.NetworkType) -> Bool {
        switch value {
        case .bch, .btc, .evm, .xlm:
            false
        default:
            true
        }
    }

    static func validSupport(_ value: [NetworkConfigResponse.NetworkProduct]) -> Bool {
        value.contains(.dscData) && value.contains(.dscTransactions)
    }

    static func from(response: NetworkConfigResponse) -> [DSCNetworkConfig] {
        response.networks
            .compactMap { Self(response: $0, types: response.types) }
    }

    init?(response: NetworkConfigResponse.Network, types: [NetworkConfigResponse.TypeEntry]) {
        guard Self.validType(response.type) else {
            return nil
        }
        guard Self.validSupport(response.supportedBy) else {
            return nil
        }
        guard let typeEntry = types.first(where: { $0.type == response.type }) else {
            return nil
        }
        guard typeEntry.derivations.count == 1, let derivation = typeEntry.derivations.first else {
            return nil
        }
        self.init(
            name: response.name,
            nativeAsset: response.nativeAsset,
            explorerUrl: response.explorerUrl,
            logoURL: response.logoPngUrl.flatMap(URL.init),
            networkTicker: response.networkTicker,
            shortName: response.shortName,
            memos: response.memos,
            derivation: .init(
                purpose: derivation.purpose,
                coinType: derivation.coinType,
                style: typeEntry.style.value
            )
        )
    }
}
